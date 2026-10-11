import '../model/entities/ledger_record.dart';

abstract class LedgerRecordRepository {
  Future<int> addRecord(LedgerEntryDraft draft);
  Future<bool> replaceRecord(int id, LedgerEntryDraft draft);
  Future<bool> deleteRecord(int id);
  Future<List<LedgerEntry>> fetchMonthlyRecords(DateTime month);
  Stream<List<LedgerEntry>> watchMonthlyRecords(DateTime month);

  /// [start] 이상 [end] 미만 기간의 기록을 감시한다.
  Stream<List<LedgerEntry>> watchRecordsBetween(DateTime start, DateTime end);
  Future<List<LedgerEntry>> fetchRecordsPage({
    required int limit,
    required int offset,
  });

  Future<int> countRecords();

  /// 가장 먼저 입력된 기록의 `createdAt`. 기록이 없으면 null.
  Future<DateTime?> fetchOldestCreatedAt();
}
