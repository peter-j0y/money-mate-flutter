import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class LedgerRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get type => text()();

  TextColumn get category => text()();

  IntColumn get amount => integer()();

  TextColumn get currencyCode => text().withDefault(const Constant('KRW'))();

  DateTimeColumn get date => dateTime()();

  TextColumn get paymentMethod => text().nullable()();

  TextColumn get memo => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Assets extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get assetType => text()();

  TextColumn get assetName => text()();

  IntColumn get amount => integer()();

  TextColumn get currencyCode => text().withDefault(const Constant('KRW'))();

  RealColumn get shares => real().nullable()();

  BoolColumn get includeInPortfolio =>
      boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class PortfolioTargets extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get assetType => text().unique()();

  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();

  IntColumn get targetRatio => integer().withDefault(const Constant(0))();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class FavoriteLedgerRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get type => text()();

  TextColumn get category => text()();

  IntColumn get amount => integer()();

  TextColumn get currencyCode => text().withDefault(const Constant('KRW'))();

  TextColumn get paymentMethod => text().nullable()();

  TextColumn get memo => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [LedgerRecords, Assets, PortfolioTargets, FavoriteLedgerRecords],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  /// 마이그레이션 테스트에서 옛 스키마 DB를 주입할 때만 사용한다.
  @visibleForTesting
  AppDatabase.forTesting(super.executor);

  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(assets);
      }
      if (from < 3) {
        await m.createTable(portfolioTargets);
      }
      if (from >= 4 && from < 5) {
        await m.deleteTable('app_settings');
      }
      if (from < 6) {
        await m.createTable(favoriteLedgerRecords);
      }
      if (from < 7) {
        await _addColumnIfMissing(m, ledgerRecords, ledgerRecords.currencyCode);
        await _addColumnIfMissing(m, assets, assets.currencyCode);
      }
      if (from < 8) {
        await _addColumnIfMissing(
          m,
          favoriteLedgerRecords,
          favoriteLedgerRecords.currencyCode,
        );
      }
    },
  );

  /// 컬럼이 아직 없을 때만 추가한다.
  /// `createTable`은 그 시점이 아니라 현재 코드의 스키마로 테이블을 만들기 때문에,
  /// 여러 버전을 한 번에 올라오면(예: 5 → 8) 뒤 단계에서 추가할 컬럼이 이미 있을 수 있다.
  /// 또 이전 실행에서 마이그레이션이 중간에 실패해 일부 컬럼만 추가된 DB도 복구할 수 있다.
  Future<void> _addColumnIfMissing(
    Migrator m,
    TableInfo<Table, dynamic> table,
    GeneratedColumn<Object> column,
  ) async {
    final columns =
        await customSelect(
          'PRAGMA table_info("${table.actualTableName}")',
        ).get();
    final exists = columns.any(
      (row) => row.read<String>('name') == column.name,
    );
    if (!exists) {
      await m.addColumn(table, column);
    }
  }

  /// 기기 지역 기반 주 통화 추론 시, 기존 기록이 있는 사용자는 KRW를 유지하기 위한 판별용.
  Future<bool> hasAnyLedgerOrAssetRecords() async {
    final ledgerRows = await (select(ledgerRecords)..limit(1)).get();
    if (ledgerRows.isNotEmpty) return true;
    final assetRows = await (select(assets)..limit(1)).get();
    return assetRows.isNotEmpty;
  }

  Future<int> insertLedgerRecord(LedgerRecordsCompanion entry) {
    return into(ledgerRecords).insert(entry);
  }

  Future<int> insertAsset(AssetsCompanion entry) {
    return into(assets).insert(entry);
  }

  Stream<List<Asset>> watchAssets() {
    return (select(assets)..orderBy([
      (tbl) => OrderingTerm.desc(tbl.createdAt),
      (tbl) => OrderingTerm.desc(tbl.id),
    ])).watch();
  }

  Future<bool> replaceAsset(int id, AssetsCompanion updatedEntry) async {
    final affectedRows = await (update(assets)
      ..where((tbl) => tbl.id.equals(id))).write(updatedEntry);
    return affectedRows > 0;
  }

  Future<bool> deleteAsset(int id) async {
    final affectedRows =
        await (delete(assets)..where((tbl) => tbl.id.equals(id))).go();
    return affectedRows > 0;
  }

  Future<void> upsertPortfolioTarget(PortfolioTargetsCompanion entry) {
    return into(portfolioTargets).insert(
      entry,
      onConflict: DoUpdate(
        (old) => entry,
        target: [portfolioTargets.assetType],
      ),
    );
  }

  Future<List<PortfolioTarget>> getPortfolioTargets() {
    return select(portfolioTargets).get();
  }

  Stream<List<PortfolioTarget>> watchPortfolioTargets() {
    return select(portfolioTargets).watch();
  }

  Future<bool> replaceLedgerRecord(
    int id,
    LedgerRecordsCompanion updatedEntry,
  ) async {
    final affectedRows = await (update(ledgerRecords)
      ..where((tbl) => tbl.id.equals(id))).write(updatedEntry);
    return affectedRows > 0;
  }

  Future<bool> deleteLedgerRecord(int id) async {
    final affectedRows =
        await (delete(ledgerRecords)..where((tbl) => tbl.id.equals(id))).go();
    return affectedRows > 0;
  }

  Future<List<LedgerRecord>> fetchMonthlyRecords(DateTime month) {
    final query = _monthlyRecordsQuery(month);
    return query.get();
  }

  Future<List<LedgerRecord>> fetchLedgerRecordsPage({
    required int limit,
    required int offset,
  }) {
    return (select(ledgerRecords)
          ..orderBy([
            (tbl) => OrderingTerm.desc(tbl.createdAt),
            (tbl) => OrderingTerm.desc(tbl.id),
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  Stream<List<LedgerRecord>> watchMonthlyRecords(DateTime month) {
    final query = _monthlyRecordsQuery(month);
    return query.watch();
  }

  /// [start] 이상 [end] 미만 기간의 가계부 기록을 감시한다.
  Stream<List<LedgerRecord>> watchRecordsBetween(DateTime start, DateTime end) {
    return _recordsBetweenQuery(start, end).watch();
  }

  SimpleSelectStatement<$LedgerRecordsTable, LedgerRecord> _monthlyRecordsQuery(
    DateTime month,
  ) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    return _recordsBetweenQuery(start, end);
  }

  SimpleSelectStatement<$LedgerRecordsTable, LedgerRecord> _recordsBetweenQuery(
    DateTime start,
    DateTime end,
  ) {
    return select(ledgerRecords)
      ..where(
        (tbl) =>
            tbl.date.isBiggerOrEqualValue(start) &
            tbl.date.isSmallerThanValue(end),
      )
      ..orderBy([
        (tbl) => OrderingTerm.desc(tbl.date),
        (tbl) => OrderingTerm.desc(tbl.id),
      ]);
  }

  Future<int> insertFavoriteLedgerRecord(FavoriteLedgerRecordsCompanion entry) {
    return into(favoriteLedgerRecords).insert(entry);
  }

  Future<bool> deleteFavoriteLedgerRecord(int id) async {
    final affectedRows =
        await (delete(favoriteLedgerRecords)
          ..where((tbl) => tbl.id.equals(id))).go();
    return affectedRows > 0;
  }

  Stream<List<FavoriteLedgerRecord>> watchFavoriteLedgerRecords() {
    return (select(favoriteLedgerRecords)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])).watch();
  }

  Future<int> countFavoriteLedgerRecords() async {
    final rows = await select(favoriteLedgerRecords).get();
    return rows.length;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(appDir.path, 'money_mate.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
