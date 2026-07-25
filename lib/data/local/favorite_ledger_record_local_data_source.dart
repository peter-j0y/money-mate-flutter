import 'package:drift/drift.dart';
import 'package:money_mate/data/local/app_database.dart';
import 'package:money_mate/data/local/db_crashlytics_logger.dart';
import 'package:money_mate/data/local/ledger_record_codec.dart';
import '../model/entities/favorite_ledger_record.dart';

class FavoriteLedgerRecordLocalDataSource {
  FavoriteLedgerRecordLocalDataSource({AppDatabase? database})
    : _database = database ?? AppDatabase();

  final AppDatabase _database;

  Future<int> addFavorite(FavoriteLedgerEntryDraft draft) {
    return logDbErrors(
      'FavoriteLedgerRecord.add',
      () => _database.insertFavoriteLedgerRecord(
        FavoriteLedgerRecordsCompanion.insert(
          type: ledgerRecordTypeToDto(draft.type),
          category: draft.category,
          amount: draft.amount,
          paymentMethod: Value(expensePaymentMethodToDto(draft.paymentMethod)),
          memo: Value(draft.memo),
        ),
      ),
      context: {'type': draft.type, 'category': draft.category},
    );
  }

  Future<bool> deleteFavorite(int id) {
    return logDbErrors(
      'FavoriteLedgerRecord.delete',
      () => _database.deleteFavoriteLedgerRecord(id),
      context: {'id': id},
    );
  }

  Stream<List<FavoriteLedgerEntry>> watchFavoriteRecords() {
    return logDbStreamErrors(
      'FavoriteLedgerRecord.watch',
      () => _database.watchFavoriteLedgerRecords(),
    ).map(_mapToFavoriteEntries);
  }

  Future<int> countFavorites() {
    return logDbErrors(
      'FavoriteLedgerRecord.count',
      () => _database.countFavoriteLedgerRecords(),
    );
  }

  List<FavoriteLedgerEntry> _mapToFavoriteEntries(
    List<FavoriteLedgerRecord> rows,
  ) {
    return rows.map(mapRow).toList(growable: false);
  }

  FavoriteLedgerEntry mapRow(FavoriteLedgerRecord row) {
    return FavoriteLedgerEntry(
      id: row.id,
      type: ledgerRecordTypeFromDto(row.type),
      category: row.category,
      amount: row.amount,
      paymentMethod: expensePaymentMethodFromDto(row.paymentMethod),
      memo: row.memo,
      createdAt: row.createdAt,
    );
  }
}