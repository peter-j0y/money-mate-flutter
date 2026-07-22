import 'ledger_record.dart';

class FavoriteLedgerEntry {
  const FavoriteLedgerEntry({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    this.paymentMethod,
    this.memo,
    required this.createdAt,
  });

  final int id;
  final LedgerRecordType type;
  final String category;
  final int amount;
  final ExpensePaymentMethod? paymentMethod;
  final String? memo;
  final DateTime createdAt;
}

class FavoriteLedgerEntryDraft {
  const FavoriteLedgerEntryDraft({
    required this.type,
    required this.category,
    required this.amount,
    this.paymentMethod,
    this.memo,
  });

  final LedgerRecordType type;
  final String category;
  final int amount;
  final ExpensePaymentMethod? paymentMethod;
  final String? memo;
}