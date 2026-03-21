import 'package:drift/drift.dart';
import 'package:money_mate/data/local/app_database.dart';
import '../model/entities/ledger_record.dart';

class LedgerRecordLocalDataSource {
  LedgerRecordLocalDataSource({AppDatabase? database})
    : _database = database ?? AppDatabase();

  final AppDatabase _database;

  Future<int> addRecord(LedgerEntryDraft draft) {
    return _database.insertLedgerRecord(
      LedgerRecordsCompanion.insert(
        type: _typeToText(draft.type),
        category: draft.category,
        amount: draft.amount,
        date: draft.date,
        memo: Value(draft.memo),
      ),
    );
  }

  Future<List<LedgerEntry>> fetchMonthlyRecords(DateTime month) async {
    final rows = await _database.fetchMonthlyRecords(month);
    return _mapToLedgerEntries(rows);
  }

  Stream<List<LedgerEntry>> watchMonthlyRecords(DateTime month) {
    return _database.watchMonthlyRecords(month).map(_mapToLedgerEntries);
  }

  List<LedgerEntry> _mapToLedgerEntries(List<LedgerRecord> rows) {
    return rows
        .map(
          (row) => LedgerEntry(
            id: row.id,
            type: _typeFromText(row.type),
            category: row.category,
            amount: row.amount,
            date: row.date,
            memo: row.memo,
            createdAt: row.createdAt,
          ),
        )
        .toList(growable: false);
  }

  LedgerRecordType _typeFromText(String value) {
    return value == 'income'
        ? LedgerRecordType.income
        : LedgerRecordType.expense;
  }

  String _typeToText(LedgerRecordType type) {
    return type == LedgerRecordType.income ? 'income' : 'expense';
  }
}
