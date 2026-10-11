import 'dart:async';

import 'package:flutter/foundation.dart' show mapEquals;

import 'package:money_mate/data/local/app_database.dart';
import 'package:money_mate/data/model/entities/net_worth_snapshot.dart';
import 'package:money_mate/data/repositories/asset_repository.dart';
import 'package:money_mate/data/repositories/asset_repository_impl.dart';
import 'package:money_mate/data/repositories/net_worth_snapshot_repository.dart';
import 'package:money_mate/data/repositories/net_worth_snapshot_repository_impl.dart';

/// 자산 목록을 감시하다가 직전 스냅샷과 값이 달라진 날에만 순자산 스냅샷을 저장한다.
///
/// 앱 시작 시 한 번 [start]하면 첫 방출(현재 자산)로 기준 스냅샷이 생기고, 이후 자산을
/// 추가·수정·삭제할 때마다 오늘 행만 교체된다. 오늘 값이 이전 날짜의 마지막 스냅샷과 같아지면
/// (예: 고쳤다가 되돌림) 오늘 행을 지운다. 그래서 행이 없는 날은 "직전 스냅샷과 같음"을 뜻하고,
/// 조회할 때는 그 날짜 이전의 가장 최근 스냅샷을 이어 쓰면 된다.
///
/// 자산 금액은 사용자가 고칠 때만 바뀌므로 변경일만 저장해도 히스토리가 정확하다.
/// 시세 자동 갱신이 생기면 매일 저장하는 방식으로 바꾸는 것을 검토한다.
class NetWorthSnapshotRecorder {
  NetWorthSnapshotRecorder({
    AssetRepository? assetRepository,
    NetWorthSnapshotRepository? snapshotRepository,
    DateTime Function()? now,
  }) : _assetRepository = assetRepository ?? AssetRepositoryImpl(),
       _snapshotRepository =
           snapshotRepository ?? NetWorthSnapshotRepositoryImpl(),
       _now = now ?? DateTime.now;

  final AssetRepository _assetRepository;
  final NetWorthSnapshotRepository _snapshotRepository;
  final DateTime Function() _now;
  StreamSubscription<List<Asset>>? _subscription;

  /// 연속 방출 시 저장 순서가 뒤바뀌지 않도록 이전 저장이 끝난 뒤 다음 저장을 실행한다.
  Future<void> _pending = Future.value();

  void start() {
    _subscription ??= _assetRepository.watchAssets().listen(
      (assets) => _pending = _pending.then((_) => _record(assets)),
      // DB 에러는 data source에서 Crashlytics에 기록된다. 스냅샷 때문에 앱이 멈추면 안 된다.
      onError: (Object _) {},
    );
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    await _pending;
  }

  Future<void> _record(List<Asset> assets) async {
    final now = _now();
    final today = DateTime(now.year, now.month, now.day);
    try {
      final previous = await _snapshotRepository.fetchLatestSnapshotBefore(
        today,
      );
      await _snapshotRepository.replaceSnapshotOn(
        today,
        diffAgainst(previous, summarize(assets)),
      );
    } catch (_) {
      // Crashlytics 기록은 data source에서 처리한다. 다음 자산 변경 때 다시 시도된다.
    }
  }

  /// 자산을 (유형, 통화)별로 합산한다. 포트폴리오 포함 여부와 무관하게 전체 자산이 대상이다.
  /// 합계가 0인 항목은 "없음"과 같으므로 넣지 않는다.
  static List<NetWorthSnapshotItem> summarize(List<Asset> assets) {
    final totals = <(String, String), int>{};
    for (final asset in assets) {
      final key = (asset.assetType, asset.currencyCode);
      totals[key] = (totals[key] ?? 0) + asset.amount;
    }
    return [
      for (final entry in totals.entries)
        if (entry.value != 0)
          NetWorthSnapshotItem(
            assetType: entry.key.$1,
            currencyCode: entry.key.$2,
            amount: entry.value,
          ),
    ];
  }

  /// 오늘 저장할 행을 정한다. [current]가 [previous]와 같으면 빈 목록(저장 안 함)이다.
  /// 달라졌다면 [current]에, [previous]에 있었지만 사라진 항목을 금액 0으로 덧붙인다.
  /// 그래야 자산을 모두 지운 날이 "행 없음(변화 없음)"과 구분된다.
  static List<NetWorthSnapshotItem> diffAgainst(
    List<NetWorthSnapshotItem> previous,
    List<NetWorthSnapshotItem> current,
  ) {
    final previousAmounts = {
      for (final item in previous)
        if (item.amount != 0) (item.assetType, item.currencyCode): item.amount,
    };
    final currentAmounts = {
      for (final item in current)
        (item.assetType, item.currencyCode): item.amount,
    };
    if (mapEquals(previousAmounts, currentAmounts)) return const [];
    return [
      ...current,
      for (final key in previousAmounts.keys)
        if (!currentAmounts.containsKey(key))
          NetWorthSnapshotItem(
            assetType: key.$1,
            currencyCode: key.$2,
            amount: 0,
          ),
    ];
  }
}
