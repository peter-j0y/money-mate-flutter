import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/data/model/entities/statistics_preferences.dart';
import 'package:money_mate/data/repositories/ledger_record_repository.dart';
import 'package:money_mate/data/repositories/statistics_preferences_repository.dart';

LedgerEntry statisticsTestEntry({
  required LedgerRecordType type,
  required int amount,
  required DateTime date,
  String category = '식비',
  String currency = 'KRW',
}) {
  return LedgerEntry(
    type: type,
    category: category,
    amount: amount,
    currencyCode: currency,
    date: date,
  );
}

class FakeLedgerRecordRepository implements LedgerRecordRepository {
  FakeLedgerRecordRepository(this.records);

  final List<LedgerEntry> records;

  List<LedgerEntry> _between(DateTime start, DateTime end) => [
    for (final record in records)
      if (!record.date.isBefore(start) && record.date.isBefore(end)) record,
  ];

  @override
  Stream<List<LedgerEntry>> watchRecordsBetween(DateTime start, DateTime end) =>
      Stream.value(_between(start, end));

  @override
  Stream<List<LedgerEntry>> watchMonthlyRecords(DateTime month) =>
      Stream.value(_between(month, DateTime(month.year, month.month + 1)));

  @override
  Future<List<LedgerEntry>> fetchMonthlyRecords(DateTime month) async =>
      _between(month, DateTime(month.year, month.month + 1));

  @override
  Future<int> addRecord(LedgerEntryDraft draft) => throw UnimplementedError();

  @override
  Future<bool> replaceRecord(int id, LedgerEntryDraft draft) =>
      throw UnimplementedError();

  @override
  Future<bool> deleteRecord(int id) => throw UnimplementedError();

  @override
  Future<List<LedgerEntry>> fetchRecordsPage({
    required int limit,
    required int offset,
  }) => throw UnimplementedError();
}

class FakeStatisticsPreferencesRepository
    implements StatisticsPreferencesRepository {
  FakeStatisticsPreferencesRepository([
    this.stored = const StatisticsPreferences(),
  ]);

  StatisticsPreferences stored;
  int saveCount = 0;

  @override
  Future<StatisticsPreferences> load() async => stored;

  @override
  Future<void> save(StatisticsPreferences preferences) async {
    stored = preferences;
    saveCount++;
  }
}
