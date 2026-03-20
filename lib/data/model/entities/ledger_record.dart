enum LedgerRecordType { income, expense }

class LedgerEntry {
  const LedgerEntry({
    this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.memo,
    this.createdAt,
  });

  final int? id;
  final LedgerRecordType type;
  final String category;
  final int amount;
  final DateTime date;
  final String? memo;
  final DateTime? createdAt;
}

class LedgerEntryDraft {
  const LedgerEntryDraft({
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.memo,
  });

  final LedgerRecordType type;
  final String category;
  final int amount;
  final DateTime date;
  final String? memo;
}
