import '../model/entities/ledger_record.dart';

abstract class LedgerRecordRepository {
  Future<int> addRecord(LedgerEntryDraft draft);
  Future<bool> replaceRecord(int id, LedgerEntryDraft draft);
  Future<bool> deleteRecord(int id);
  Future<List<LedgerEntry>> fetchMonthlyRecords(DateTime month);
  Stream<List<LedgerEntry>> watchMonthlyRecords(DateTime month);
}
