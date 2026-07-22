import '../model/entities/ledger_record.dart';

String ledgerRecordTypeToDto(LedgerRecordType type) {
  return type == LedgerRecordType.income ? 'income' : 'expense';
}

LedgerRecordType ledgerRecordTypeFromDto(String value) {
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

String? expensePaymentMethodToDto(ExpensePaymentMethod? value) {
  return value?.code;
}

ExpensePaymentMethod? expensePaymentMethodFromDto(String? value) {
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