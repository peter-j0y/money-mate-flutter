import 'package:money_mate/data/local/ledger_record_local_data_source.dart';
import 'package:money_mate/data/repositories/ledger_record_repository.dart';

import '../model/entities/ledger_record.dart';

class LedgerRecordRepositoryImpl implements LedgerRecordRepository {
  LedgerRecordRepositoryImpl({LedgerRecordLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? LedgerRecordLocalDataSource();

  final LedgerRecordLocalDataSource _localDataSource;

  @override
  Future<int> addRecord(LedgerEntryDraft draft) {
    return _localDataSource.addRecord(draft);
  }

  @override
  Future<List<LedgerEntry>> fetchMonthlyRecords(DateTime month) {
    return _localDataSource.fetchMonthlyRecords(month);
  }

  @override
  Stream<List<LedgerEntry>> watchMonthlyRecords(DateTime month) {
    return _localDataSource.watchMonthlyRecords(month);
  }
}
