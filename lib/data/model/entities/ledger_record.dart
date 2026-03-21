enum LedgerRecordType { income, expense }

enum ExpensePaymentMethod {
  cash,
  creditCard,
  debitCard,
  bankTransfer,
  points,
  other,
}

extension ExpensePaymentMethodX on ExpensePaymentMethod {
  String get code {
    switch (this) {
      case ExpensePaymentMethod.cash:
        return 'cash';
      case ExpensePaymentMethod.creditCard:
        return 'credit_card';
      case ExpensePaymentMethod.debitCard:
        return 'debit_card';
      case ExpensePaymentMethod.bankTransfer:
        return 'bank_transfer';
      case ExpensePaymentMethod.points:
        return 'points';
      case ExpensePaymentMethod.other:
        return 'other';
    }
  }

  static ExpensePaymentMethod? fromCode(String? code) {
    switch (code) {
      case 'cash':
        return ExpensePaymentMethod.cash;
      case 'credit_card':
        return ExpensePaymentMethod.creditCard;
      case 'debit_card':
        return ExpensePaymentMethod.debitCard;
      case 'bank_transfer':
        return ExpensePaymentMethod.bankTransfer;
      case 'points':
        return ExpensePaymentMethod.points;
      case 'other':
        return ExpensePaymentMethod.other;
      default:
        return null;
    }
  }
}

class LedgerEntry {
  const LedgerEntry({
    this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.paymentMethod,
    this.memo,
    this.createdAt,
  });

  final int? id;
  final LedgerRecordType type;
  final String category;
  final int amount;
  final DateTime date;
  final ExpensePaymentMethod? paymentMethod;
  final String? memo;
  final DateTime? createdAt;
}

class LedgerEntryDraft {
  const LedgerEntryDraft({
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.paymentMethod,
    this.memo,
  });

  final LedgerRecordType type;
  final String category;
  final int amount;
  final DateTime date;
  final ExpensePaymentMethod? paymentMethod;
  final String? memo;
}
