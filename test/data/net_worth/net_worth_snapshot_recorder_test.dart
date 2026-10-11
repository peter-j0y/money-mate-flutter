import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_mate/data/local/app_database.dart';
import 'package:money_mate/data/local/asset_local_data_source.dart';
import 'package:money_mate/data/local/net_worth_snapshot_local_data_source.dart';
import 'package:money_mate/data/model/entities/asset_entry.dart';
import 'package:money_mate/data/net_worth/net_worth_snapshot_recorder.dart';
import 'package:money_mate/data/repositories/asset_repository_impl.dart';
import 'package:money_mate/data/repositories/net_worth_snapshot_repository_impl.dart';

void main() {
  late AppDatabase database;
  late AssetRepositoryImpl assetRepository;
  late DateTime now;
  late NetWorthSnapshotRecorder recorder;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    assetRepository = AssetRepositoryImpl(
      localDataSource: AssetLocalDataSource(database: database),
    );
    now = DateTime(2026, 10, 11, 23, 30);
    recorder = NetWorthSnapshotRecorder(
      assetRepository: assetRepository,
      snapshotRepository: NetWorthSnapshotRepositoryImpl(
        localDataSource: NetWorthSnapshotLocalDataSource(database: database),
      ),
      now: () => now,
    );
  });

  tearDown(() async {
    await recorder.stop();
    await database.close();
  });

  Future<int> addAsset(
    AssetType type,
    int amount, {
    String currencyCode = 'KRW',
    bool includeInPortfolio = true,
  }) {
    return assetRepository.addAsset(
      AssetEntryDraft(
        assetType: type,
        assetName: type.code,
        amount: amount,
        currencyCode: currencyCode,
        includeInPortfolio: includeInPortfolio,
      ),
    );
  }

  /// watch 스트림 방출과 직렬화된 저장이 끝날 때까지 기다린다.
  Future<List<(DateTime, String, String, int)>> snapshots() async {
    await pumpEventQueue();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final rows = await database.fetchNetWorthSnapshots();
    return [
      for (final row in rows)
        (row.snapshotDate, row.assetType, row.currencyCode, row.amount),
    ];
  }

  final oct11 = DateTime(2026, 10, 11);
  final oct12 = DateTime(2026, 10, 12);

  test('시작하면 현재 자산을 유형·통화별로 합산해 오늘 날짜로 저장한다', () async {
    await addAsset(AssetType.stock, 1000000);
    await addAsset(AssetType.stock, 500000);
    await addAsset(AssetType.stock, 200, currencyCode: 'USD');
    // 포트폴리오에서 제외한 자산도 순자산에는 포함한다.
    await addAsset(AssetType.cash, 300000, includeInPortfolio: false);

    recorder.start();

    expect(await snapshots(), [
      (oct11, 'cash', 'KRW', 300000),
      (oct11, 'stock', 'KRW', 1500000),
      (oct11, 'stock', 'USD', 200),
    ]);
  });

  test('같은 날 자산이 바뀌면 오늘 행만 교체되어 하루의 마지막 상태가 남는다', () async {
    final cashId = await addAsset(AssetType.cash, 300000);
    recorder.start();
    await snapshots();

    await addAsset(AssetType.crypto, 50000);
    await assetRepository.deleteAsset(cashId);

    expect(await snapshots(), [(oct11, 'crypto', 'KRW', 50000)]);
  });

  test('자정이 지난 뒤의 변경은 새 날짜로 쌓이고 지난 날짜 행은 보존된다', () async {
    await addAsset(AssetType.cash, 300000);
    recorder.start();
    await snapshots();

    now = DateTime(2026, 10, 12, 0, 10);
    await addAsset(AssetType.savings, 1000000);

    expect(await snapshots(), [
      (oct11, 'cash', 'KRW', 300000),
      (oct12, 'cash', 'KRW', 300000),
      (oct12, 'savings', 'KRW', 1000000),
    ]);
  });

  test('자산을 모두 지우면 오늘 행도 비워진다', () async {
    final id = await addAsset(AssetType.cash, 300000);
    recorder.start();
    await snapshots();

    await assetRepository.deleteAsset(id);

    expect(await snapshots(), isEmpty);
  });

  /// 하루를 넘겨 앱을 다시 연 상황: 새 날짜에서 감시를 다시 시작한다.
  Future<void> reopenAppOn(DateTime at) async {
    await recorder.stop();
    now = at;
    recorder.start();
  }

  test('다음 날 앱을 열어도 자산이 그대로면 새 행을 저장하지 않는다', () async {
    await addAsset(AssetType.cash, 300000);
    recorder.start();
    await snapshots();

    await reopenAppOn(DateTime(2026, 10, 12, 9));

    expect(await snapshots(), [(oct11, 'cash', 'KRW', 300000)]);
  });

  test('다음 날 고쳤다가 이전 값으로 되돌리면 그날 행이 지워진다', () async {
    final id = await addAsset(AssetType.cash, 300000);
    recorder.start();
    await snapshots();
    await reopenAppOn(DateTime(2026, 10, 12, 9));

    final draft = AssetEntryDraft(
      assetType: AssetType.cash,
      assetName: 'cash',
      amount: 400000,
      currencyCode: 'KRW',
      includeInPortfolio: true,
    );
    await assetRepository.replaceAsset(id, draft);
    expect(await snapshots(), [
      (oct11, 'cash', 'KRW', 300000),
      (oct12, 'cash', 'KRW', 400000),
    ]);

    await assetRepository.replaceAsset(
      id,
      AssetEntryDraft(
        assetType: draft.assetType,
        assetName: draft.assetName,
        amount: 300000,
        currencyCode: draft.currencyCode,
        includeInPortfolio: draft.includeInPortfolio,
      ),
    );
    expect(await snapshots(), [(oct11, 'cash', 'KRW', 300000)]);
  });

  test('이전 스냅샷에 있던 항목이 사라지면 금액 0으로 남겨 "변화 없음"과 구분한다', () async {
    final cashId = await addAsset(AssetType.cash, 300000);
    final usdId = await addAsset(AssetType.stock, 200, currencyCode: 'USD');
    recorder.start();
    await snapshots();
    await reopenAppOn(DateTime(2026, 10, 12, 9));

    await assetRepository.deleteAsset(cashId);
    await assetRepository.deleteAsset(usdId);

    expect(await snapshots(), [
      (oct11, 'cash', 'KRW', 300000),
      (oct11, 'stock', 'USD', 200),
      (oct12, 'cash', 'KRW', 0),
      (oct12, 'stock', 'USD', 0),
    ]);

    // 0원 상태가 기준이 되므로, 그다음 날 열어도 다시 저장하지 않는다.
    await reopenAppOn(DateTime(2026, 10, 13, 9));
    expect((await snapshots()).length, 4);
  });
}
