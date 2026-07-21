import 'package:money_mate/data/local/favorite_ledger_record_local_data_source.dart';
import 'package:money_mate/data/repositories/favorite_ledger_record_repository.dart';

import '../model/entities/ledger_record.dart';

class FavoriteLedgerRecordRepositoryImpl
    implements FavoriteLedgerRecordRepository {
  FavoriteLedgerRecordRepositoryImpl({
    FavoriteLedgerRecordLocalDataSource? localDataSource,
  }) : _localDataSource =
           localDataSource ?? FavoriteLedgerRecordLocalDataSource();

  final FavoriteLedgerRecordLocalDataSource _localDataSource;

  @override
  Future<void> addFavorite(int ledgerRecordId) {
    return _localDataSource.addFavorite(ledgerRecordId);
  }

  @override
  Future<void> removeFavorite(int ledgerRecordId) {
    return _localDataSource.removeFavorite(ledgerRecordId);
  }

  @override
  Stream<Set<int>> watchFavoriteRecordIds() {
    return _localDataSource.watchFavoriteRecordIds();
  }

  @override
  Stream<List<LedgerEntry>> watchFavoriteRecords() {
    return _localDataSource.watchFavoriteRecords();
  }
}