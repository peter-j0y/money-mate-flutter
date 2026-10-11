import '../model/entities/net_worth_snapshot.dart';

abstract class NetWorthSnapshotRepository {
  /// [date](로컬 자정)의 스냅샷을 [items]로 교체한다.
  Future<void> replaceSnapshotOn(
    DateTime date,
    List<NetWorthSnapshotItem> items,
  );

  /// [date]보다 이전 날짜 중 가장 최근 스냅샷. 없으면 빈 목록.
  Future<List<NetWorthSnapshotItem>> fetchLatestSnapshotBefore(DateTime date);
}
