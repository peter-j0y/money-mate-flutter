import '../model/entities/ledger_record.dart';

abstract class LedgerRecordRepository {
  Future<int> addRecord(LedgerEntryDraft draft);
  Future<List<LedgerEntry>> fetchMonthlyRecords(DateTime month);
}
