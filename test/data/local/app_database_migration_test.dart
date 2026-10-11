import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_mate/data/local/app_database.dart';

// 릴리즈된 앱의 옛 스키마. drift가 실제로 만들었던 CREATE 문과 같다.
const _createLedgerRecordsV1 =
    'CREATE TABLE "ledger_records" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    '"type" TEXT NOT NULL, "category" TEXT NOT NULL, "amount" INTEGER NOT NULL, '
    '"date" INTEGER NOT NULL, "payment_method" TEXT NULL, "memo" TEXT NULL, '
    '"created_at" INTEGER NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)))';
const _createAssetsV2 =
    'CREATE TABLE "assets" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    '"asset_type" TEXT NOT NULL, "asset_name" TEXT NOT NULL, "amount" INTEGER NOT NULL, '
    '"shares" REAL NULL, "include_in_portfolio" INTEGER NOT NULL DEFAULT 1 '
    'CHECK ("include_in_portfolio" IN (0, 1)), '
    '"created_at" INTEGER NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)))';
const _createPortfolioTargetsV3 =
    'CREATE TABLE "portfolio_targets" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    '"asset_type" TEXT NOT NULL UNIQUE, "is_enabled" INTEGER NOT NULL DEFAULT 1 '
    'CHECK ("is_enabled" IN (0, 1)), "target_ratio" INTEGER NOT NULL DEFAULT 0, '
    '"updated_at" INTEGER NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)))';
const _createFavoritesV6 =
    'CREATE TABLE "favorite_ledger_records" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
    '"type" TEXT NOT NULL, "category" TEXT NOT NULL, "amount" INTEGER NOT NULL, '
    '"payment_method" TEXT NULL, "memo" TEXT NULL, '
    '"created_at" INTEGER NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)))';

const _insertLedger =
    'INSERT INTO ledger_records (type, category, amount, date) '
    "VALUES ('expense', '식비', 12000, 1790000000)";

/// [statements]로 옛 스키마를 만든 DB를 열고 마이그레이션을 실행한다.
Future<AppDatabase> _openMigrated(List<String> statements) async {
  final database = AppDatabase.forTesting(
    NativeDatabase.memory(
      setup: (db) {
        for (final statement in statements) {
          db.execute(statement);
        }
      },
    ),
  );
  // 첫 쿼리에서 마이그레이션이 실행된다.
  await database.customSelect('SELECT 1').get();
  return database;
}

Future<Set<String>> _columns(AppDatabase database, String table) async {
  final rows = await database.customSelect('PRAGMA table_info("$table")').get();
  return {for (final row in rows) row.read<String>('name')};
}

Future<int> _userVersion(AppDatabase database) async {
  final row = await database.customSelect('PRAGMA user_version').getSingle();
  return row.read<int>('user_version');
}

void main() {
  test('v1.0.0(schema 5)에서 현재 버전으로 올라와도 기존 기록이 유지된다', () async {
    final database = await _openMigrated([
      _createLedgerRecordsV1,
      _createAssetsV2,
      _createPortfolioTargetsV3,
      _insertLedger,
      'PRAGMA user_version = 5',
    ]);
    addTearDown(database.close);

    expect(await _userVersion(database), 8);
    expect(
      await _columns(database, 'favorite_ledger_records'),
      contains('currency_code'),
    );
    final records = await database.fetchMonthlyRecords(DateTime(2026, 9));
    expect(records.single.currencyCode, 'KRW');
    expect(records.single.amount, 12000);
  });

  test('schema 1(가계부 테이블만 있던 버전)에서도 올라온다', () async {
    final database = await _openMigrated([
      _createLedgerRecordsV1,
      _insertLedger,
      'PRAGMA user_version = 1',
    ]);
    addTearDown(database.close);

    expect(await _userVersion(database), 8);
    expect(await _columns(database, 'assets'), contains('currency_code'));
    expect(
      await _columns(database, 'ledger_records'),
      contains('currency_code'),
    );
  });

  test('v1.1~v1.2(schema 6)에서 올라오면 즐겨찾기에 통화 컬럼이 추가된다', () async {
    final database = await _openMigrated([
      _createLedgerRecordsV1,
      _createAssetsV2,
      _createPortfolioTargetsV3,
      _createFavoritesV6,
      'PRAGMA user_version = 6',
    ]);
    addTearDown(database.close);

    expect(await _userVersion(database), 8);
    expect(
      await _columns(database, 'favorite_ledger_records'),
      contains('currency_code'),
    );
    expect(
      await _columns(database, 'ledger_records'),
      contains('currency_code'),
    );
  });

  test('이전 버그로 마이그레이션이 중간에 멈춘 DB도 복구된다', () async {
    // 실제 기기에서 관찰된 상태: user_version은 5인데 7·8단계 일부가 이미 적용돼 있다.
    final database = await _openMigrated([
      _createLedgerRecordsV1,
      _createAssetsV2,
      _createPortfolioTargetsV3,
      'ALTER TABLE ledger_records ADD COLUMN "currency_code" TEXT NOT NULL DEFAULT \'KRW\'',
      'ALTER TABLE assets ADD COLUMN "currency_code" TEXT NOT NULL DEFAULT \'KRW\'',
      _createFavoritesV6.replaceFirst(
        '"payment_method"',
        '"currency_code" TEXT NOT NULL DEFAULT \'KRW\', "payment_method"',
      ),
      _insertLedger,
      'PRAGMA user_version = 5',
    ]);
    addTearDown(database.close);

    expect(await _userVersion(database), 8);
    final records = await database.fetchMonthlyRecords(DateTime(2026, 9));
    expect(records.single.currencyCode, 'KRW');
  });
}
