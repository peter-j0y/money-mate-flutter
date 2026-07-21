import '../model/entities/ledger_record.dart';

abstract class FavoriteLedgerRecordRepository {
  Future<void> addFavorite(int ledgerRecordId);
  Future<void> removeFavorite(int ledgerRecordId);
  Stream<Set<int>> watchFavoriteRecordIds();
  Stream<List<LedgerEntry>> watchFavoriteRecords();
}