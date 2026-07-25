import '../model/entities/favorite_ledger_record.dart';

const int maxFavoriteLedgerRecordCount = 5;

class FavoriteLedgerRecordLimitExceededException implements Exception {
  const FavoriteLedgerRecordLimitExceededException();
}

abstract class FavoriteLedgerRecordRepository {
  Future<int> addFavorite(FavoriteLedgerEntryDraft draft);
  Future<bool> deleteFavorite(int id);
  Stream<List<FavoriteLedgerEntry>> watchFavoriteRecords();
  Future<int> countFavorites();
}