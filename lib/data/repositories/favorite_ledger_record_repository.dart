import '../model/entities/favorite_ledger_record.dart';

abstract class FavoriteLedgerRecordRepository {
  Future<int> addFavorite(FavoriteLedgerEntryDraft draft);
  Future<bool> deleteFavorite(int id);
  Stream<List<FavoriteLedgerEntry>> watchFavoriteRecords();
}