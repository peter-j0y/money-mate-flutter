import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_mate/data/local/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  Future<void> insert({required DateTime date, required DateTime createdAt}) {
    return database.insertLedgerRecord(
      LedgerRecordsCompanion.insert(
        type: 'expense',
        category: 'food',
        amount: 1000,
        date: date,
        createdAt: Value(createdAt),
      ),
    );
  }

  test('기록이 없으면 개수는 0, 가장 오래된 createdAt은 null이다', () async {
    expect(await database.countLedgerRecords(), 0);
    expect(await database.fetchOldestLedgerRecordCreatedAt(), isNull);
  });

  test('개수를 세고, 사용자가 고른 date가 아니라 가장 이른 createdAt을 돌려준다', () async {
    final earliestCreatedAt = DateTime(2026, 9, 1, 9);
    // 나중에 입력했지만 과거 날짜로 기록한 경우: date는 가장 이르지만 createdAt은 늦다.
    await insert(date: DateTime(2025, 1, 1), createdAt: DateTime(2026, 10, 1));
    await insert(date: DateTime(2026, 9, 1), createdAt: earliestCreatedAt);
    await insert(date: DateTime(2026, 9, 15), createdAt: DateTime(2026, 9, 15));

    expect(await database.countLedgerRecords(), 3);
    expect(
      await database.fetchOldestLedgerRecordCreatedAt(),
      earliestCreatedAt,
    );
  });
}
