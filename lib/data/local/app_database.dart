import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class LedgerRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get type => text()();

  TextColumn get category => text()();

  IntColumn get amount => integer()();

  DateTimeColumn get date => dateTime()();

  TextColumn get paymentMethod => text().nullable()();

  TextColumn get memo => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Assets extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get assetType => text()();

  TextColumn get assetName => text()();

  IntColumn get amount => integer()();

  RealColumn get shares => real().nullable()();

  BoolColumn get includeInPortfolio =>
      boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class PortfolioTargets extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get assetType => text().unique()();

  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();

  IntColumn get targetRatio => integer().withDefault(const Constant(0))();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class AppSettings extends Table {
  IntColumn get id => integer()();

  TextColumn get themeMode => text().withDefault(const Constant('system'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [LedgerRecords, Assets, PortfolioTargets, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;

  static const int _settingsRowId = 0;

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(assets);
      }
      if (from < 3) {
        await m.createTable(portfolioTargets);
      }
      if (from < 4) {
        await m.createTable(appSettings);
      }
    },
  );

  Future<String?> getThemeMode() async {
    final row =
        await (select(appSettings)
          ..where((tbl) => tbl.id.equals(_settingsRowId))).getSingleOrNull();
    return row?.themeMode;
  }

  Stream<String?> watchThemeMode() {
    return (select(appSettings)..where(
      (tbl) => tbl.id.equals(_settingsRowId),
    )).watchSingleOrNull().map((row) => row?.themeMode);
  }

  Future<void> setThemeMode(String themeMode) {
    return into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(
        id: const Value(_settingsRowId),
        themeMode: Value(themeMode),
      ),
    );
  }

  Future<int> insertLedgerRecord(LedgerRecordsCompanion entry) {
    return into(ledgerRecords).insert(entry);
  }

  Future<int> insertAsset(AssetsCompanion entry) {
    return into(assets).insert(entry);
  }

  Stream<List<Asset>> watchAssets() {
    return (select(assets)..orderBy([
      (tbl) => OrderingTerm.desc(tbl.createdAt),
      (tbl) => OrderingTerm.desc(tbl.id),
    ])).watch();
  }

  Future<bool> replaceAsset(int id, AssetsCompanion updatedEntry) async {
    final affectedRows = await (update(assets)
      ..where((tbl) => tbl.id.equals(id))).write(updatedEntry);
    return affectedRows > 0;
  }

  Future<bool> deleteAsset(int id) async {
    final affectedRows =
        await (delete(assets)..where((tbl) => tbl.id.equals(id))).go();
    return affectedRows > 0;
  }

  Future<void> upsertPortfolioTarget(PortfolioTargetsCompanion entry) {
    return into(portfolioTargets).insert(
      entry,
      onConflict: DoUpdate(
        (old) => entry,
        target: [portfolioTargets.assetType],
      ),
    );
  }

  Future<List<PortfolioTarget>> getPortfolioTargets() {
    return select(portfolioTargets).get();
  }

  Stream<List<PortfolioTarget>> watchPortfolioTargets() {
    return select(portfolioTargets).watch();
  }

  Future<bool> replaceLedgerRecord(
    int id,
    LedgerRecordsCompanion updatedEntry,
  ) async {
    final affectedRows = await (update(ledgerRecords)
      ..where((tbl) => tbl.id.equals(id))).write(updatedEntry);
    return affectedRows > 0;
  }

  Future<bool> deleteLedgerRecord(int id) async {
    final affectedRows =
        await (delete(ledgerRecords)..where((tbl) => tbl.id.equals(id))).go();
    return affectedRows > 0;
  }

  Future<List<LedgerRecord>> fetchMonthlyRecords(DateTime month) {
    final query = _monthlyRecordsQuery(month);
    return query.get();
  }

  Stream<List<LedgerRecord>> watchMonthlyRecords(DateTime month) {
    final query = _monthlyRecordsQuery(month);
    return query.watch();
  }

  SimpleSelectStatement<$LedgerRecordsTable, LedgerRecord> _monthlyRecordsQuery(
    DateTime month,
  ) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    return select(ledgerRecords)
      ..where(
        (tbl) =>
            tbl.date.isBiggerOrEqualValue(start) &
            tbl.date.isSmallerThanValue(end),
      )
      ..orderBy([
        (tbl) => OrderingTerm.desc(tbl.date),
        (tbl) => OrderingTerm.desc(tbl.id),
      ]);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(appDir.path, 'money_mate.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
