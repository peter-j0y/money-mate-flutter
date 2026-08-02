import 'package:drift/drift.dart';
import 'package:money_mate/data/local/app_database.dart';
import 'package:money_mate/data/local/db_crashlytics_logger.dart';
import 'package:money_mate/data/local/ledger_record_codec.dart';
import '../model/entities/ledger_record.dart';

class LedgerRecordLocalDataSource {
  LedgerRecordLocalDataSource({AppDatabase? database})
    : _database = database ?? AppDatabase();

  final AppDatabase _database;

  Future<int> addRecord(LedgerEntryDraft draft) {
    return logDbErrors(
      'LedgerRecord.add',
      () => _database.insertLedgerRecord(
        LedgerRecordsCompanion.insert(
          type: ledgerRecordTypeToDto(draft.type),
          category: draft.category,
          amount: draft.amount,
          currencyCode: Value(draft.currencyCode),
          date: draft.date,
          paymentMethod: Value(expensePaymentMethodToDto(draft.paymentMethod)),
          memo: Value(draft.memo),
        ),
      ),
      context: {'type': draft.type, 'category': draft.category},
    );
  }

  Future<bool> replaceRecord(int id, LedgerEntryDraft draft) {
    return logDbErrors(
      'LedgerRecord.replace',
      () => _database.replaceLedgerRecord(
        id,
        LedgerRecordsCompanion(
          type: Value(ledgerRecordTypeToDto(draft.type)),
          category: Value(draft.category),
          amount: Value(draft.amount),
          currencyCode: Value(draft.currencyCode),
          date: Value(draft.date),
          paymentMethod: Value(expensePaymentMethodToDto(draft.paymentMethod)),
          memo: Value(draft.memo),
        ),
      ),
      context: {'id': id, 'type': draft.type, 'category': draft.category},
    );
  }

  Future<bool> deleteRecord(int id) {
    return logDbErrors(
      'LedgerRecord.delete',
      () => _database.deleteLedgerRecord(id),
      context: {'id': id},
    );
  }

  Future<List<LedgerEntry>> fetchMonthlyRecords(DateTime month) async {
    final rows = await logDbErrors(
      'LedgerRecord.fetchMonthly',
      () => _database.fetchMonthlyRecords(month),
      context: {'month': month.toIso8601String()},
    );
    return _mapToLedgerEntries(rows);
  }

  Stream<List<LedgerEntry>> watchMonthlyRecords(DateTime month) {
    return logDbStreamErrors(
      'LedgerRecord.watchMonthly',
      () => _database.watchMonthlyRecords(month),
      context: {'month': month.toIso8601String()},
    ).map(_mapToLedgerEntries);
  }

  Future<List<LedgerEntry>> fetchRecordsPage({
    required int limit,
    required int offset,
  }) async {
    final rows = await logDbErrors(
      'LedgerRecord.fetchPage',
      () => _database.fetchLedgerRecordsPage(limit: limit, offset: offset),
      context: {'limit': limit, 'offset': offset},
    );
    return _mapToLedgerEntries(rows);
  }

  List<LedgerEntry> _mapToLedgerEntries(List<LedgerRecord> rows) {
    return rows.map(mapRow).toList(growable: false);
  }

  LedgerEntry mapRow(LedgerRecord row) {
    return LedgerEntry(
      id: row.id,
      type: ledgerRecordTypeFromDto(row.type),
      category: row.category,
      amount: row.amount,
      currencyCode: row.currencyCode,
      date: row.date,
      paymentMethod: expensePaymentMethodFromDto(row.paymentMethod),
      memo: row.memo,
      createdAt: row.createdAt,
    );
  }
}
