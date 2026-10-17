import 'package:money_mate/data/local/net_worth_snapshot_local_data_source.dart';
import 'package:money_mate/data/repositories/net_worth_snapshot_repository.dart';

import '../model/entities/net_worth_snapshot.dart';

class NetWorthSnapshotRepositoryImpl implements NetWorthSnapshotRepository {
  NetWorthSnapshotRepositoryImpl({
    NetWorthSnapshotLocalDataSource? localDataSource,
  }) : _localDataSource = localDataSource ?? NetWorthSnapshotLocalDataSource();

  final NetWorthSnapshotLocalDataSource _localDataSource;

  @override
  Future<void> replaceSnapshotOn(
    DateTime date,
    List<NetWorthSnapshotItem> items,
  ) {
    return _localDataSource.replaceSnapshotOn(date, items);
  }

  @override
  Future<List<NetWorthSnapshotItem>> fetchLatestSnapshotBefore(DateTime date) {
    return _localDataSource.fetchLatestSnapshotBefore(date);
  }
}
