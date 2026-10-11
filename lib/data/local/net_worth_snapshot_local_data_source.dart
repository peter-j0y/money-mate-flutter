import 'package:money_mate/data/local/app_database.dart';
import 'package:money_mate/data/local/db_crashlytics_logger.dart';
import 'package:money_mate/data/model/entities/net_worth_snapshot.dart';

class NetWorthSnapshotLocalDataSource {
  NetWorthSnapshotLocalDataSource({AppDatabase? database})
    : _database = database ?? AppDatabase();

  final AppDatabase _database;

  Future<void> replaceSnapshotOn(
    DateTime date,
    List<NetWorthSnapshotItem> items,
  ) {
    return logDbErrors(
      'NetWorthSnapshot.replace',
      () => _database.replaceNetWorthSnapshotsOn(
        date,
        items
            .map(
              (item) => NetWorthSnapshotsCompanion.insert(
                snapshotDate: date,
                assetType: item.assetType,
                currencyCode: item.currencyCode,
                amount: item.amount,
              ),
            )
            .toList(growable: false),
      ),
      context: {'date': date.toIso8601String(), 'count': items.length},
    );
  }

  Future<List<NetWorthSnapshotItem>> fetchLatestSnapshotBefore(DateTime date) {
    return logDbErrors(
      'NetWorthSnapshot.fetchLatestBefore',
      () async {
        final rows = await _database.fetchLatestNetWorthSnapshotBefore(date);
        return rows
            .map(
              (row) => NetWorthSnapshotItem(
                assetType: row.assetType,
                currencyCode: row.currencyCode,
                amount: row.amount,
              ),
            )
            .toList(growable: false);
      },
      context: {'date': date.toIso8601String()},
    );
  }
}
