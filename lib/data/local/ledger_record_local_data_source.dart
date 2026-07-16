import 'package:drift/drift.dart';
import 'package:money_mate/data/local/app_database.dart';
import 'package:money_mate/data/local/db_crashlytics_logger.dart';
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
          type: _typeToDto(draft.type),
          category: draft.category,
          amount: draft.amount,
          date: draft.date,
          paymentMethod: Value(_paymentMethodToDto(draft.paymentMethod)),
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
          type: Value(_typeToDto(draft.type)),
          category: Value(draft.category),
          amount: Value(draft.amount),
          date: Value(draft.date),
          paymentMethod: Value(_paymentMethodToDto(draft.paymentMethod)),
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

  List<LedgerEntry> _mapToLedgerEntries(List<LedgerRecord> rows) {
    return rows
        .map(
          (row) => LedgerEntry(
            id: row.id,
            type: _typeToUi(row.type),
            category: row.category,
            amount: row.amount,
            date: row.date,
            paymentMethod: _paymentMethodToUi(row.paymentMethod),
            memo: row.memo,
            createdAt: row.createdAt,
          ),
        )
        .toList(growable: false);
  }

  LedgerRecordType _typeToUi(String value) {
    switch (value.toLowerCase()) {
      case 'income':
      case '수입':
        return LedgerRecordType.income;
      case 'expense':
      case '지출':
      default:
        return LedgerRecordType.expense;
    }
  }

  String _typeToDto(LedgerRecordType type) {
    return type == LedgerRecordType.income ? 'income' : 'expense';
  }

  String? _paymentMethodToDto(ExpensePaymentMethod? value) {
    return value?.code;
  }

  ExpensePaymentMethod? _paymentMethodToUi(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final normalizedCode = _legacyPaymentMethodKoreanToCode(value);
    return ExpensePaymentMethodX.fromCode(normalizedCode);
  }

  String _legacyPaymentMethodKoreanToCode(String value) {
    switch (value) {
      case '현금':
        return 'cash';
      case '신용카드':
        return 'credit_card';
      case '체크카드':
        return 'debit_card';
      case '계좌이체':
        return 'bank_transfer';
      case '포인트':
        return 'points';
      case '기타':
        return 'other';
      default:
        return value;
    }
  }
}
