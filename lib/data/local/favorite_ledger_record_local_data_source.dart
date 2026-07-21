import 'package:money_mate/data/local/app_database.dart';
import 'package:money_mate/data/local/db_crashlytics_logger.dart';
import 'package:money_mate/data/local/ledger_record_local_data_source.dart';
import '../model/entities/ledger_record.dart';

class FavoriteLedgerRecordLocalDataSource {
  FavoriteLedgerRecordLocalDataSource({
    AppDatabase? database,
    LedgerRecordLocalDataSource? ledgerRecordLocalDataSource,
  }) : _database = database ?? AppDatabase(),
       _ledgerRecordLocalDataSource =
           ledgerRecordLocalDataSource ?? LedgerRecordLocalDataSource();

  final AppDatabase _database;
  final LedgerRecordLocalDataSource _ledgerRecordLocalDataSource;

  Future<void> addFavorite(int ledgerRecordId) {
    return logDbErrors(
      'FavoriteLedgerRecord.add',
      () => _database.addFavoriteLedgerRecord(ledgerRecordId),
      context: {'ledgerRecordId': ledgerRecordId},
    );
  }

  Future<void> removeFavorite(int ledgerRecordId) {
    return logDbErrors(
      'FavoriteLedgerRecord.remove',
      () => _database.removeFavoriteLedgerRecord(ledgerRecordId),
      context: {'ledgerRecordId': ledgerRecordId},
    );
  }

  Stream<Set<int>> watchFavoriteRecordIds() {
    return logDbStreamErrors(
      'FavoriteLedgerRecord.watchIds',
      () => _database.watchFavoriteLedgerRecordIds(),
    );
  }

  Stream<List<LedgerEntry>> watchFavoriteRecords() {
    return logDbStreamErrors(
      'FavoriteLedgerRecord.watchRecords',
      () => _database.watchFavoriteLedgerRecords(),
    ).map((rows) => rows.map(_ledgerRecordLocalDataSource.mapRow).toList(growable: false));
  }
}