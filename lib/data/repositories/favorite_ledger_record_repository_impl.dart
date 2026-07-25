import 'package:money_mate/data/local/favorite_ledger_record_local_data_source.dart';
import 'package:money_mate/data/repositories/favorite_ledger_record_repository.dart';

import '../model/entities/favorite_ledger_record.dart';

class FavoriteLedgerRecordRepositoryImpl
    implements FavoriteLedgerRecordRepository {
  FavoriteLedgerRecordRepositoryImpl({
    FavoriteLedgerRecordLocalDataSource? localDataSource,
  }) : _localDataSource =
           localDataSource ?? FavoriteLedgerRecordLocalDataSource();

  final FavoriteLedgerRecordLocalDataSource _localDataSource;

  @override
  Future<int> addFavorite(FavoriteLedgerEntryDraft draft) async {
    final currentCount = await _localDataSource.countFavorites();
    if (currentCount >= maxFavoriteLedgerRecordCount) {
      throw const FavoriteLedgerRecordLimitExceededException();
    }
    return _localDataSource.addFavorite(draft);
  }

  @override
  Future<bool> deleteFavorite(int id) {
    return _localDataSource.deleteFavorite(id);
  }

  @override
  Stream<List<FavoriteLedgerEntry>> watchFavoriteRecords() {
    return _localDataSource.watchFavoriteRecords();
  }

  @override
  Future<int> countFavorites() {
    return _localDataSource.countFavorites();
  }
}