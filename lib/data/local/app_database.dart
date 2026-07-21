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

class FavoriteLedgerRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get ledgerRecordId =>
      integer().references(LedgerRecords, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {ledgerRecordId},
  ];
}

@DriftDatabase(
  tables: [LedgerRecords, Assets, PortfolioTargets, FavoriteLedgerRecords],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() => _instance;

  @override
  int get schemaVersion => 6;

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
      if (from >= 4 && from < 5) {
        await m.deleteTable('app_settings');
      }
      if (from < 6) {
        await m.createTable(favoriteLedgerRecords);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

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

  Future<void> addFavoriteLedgerRecord(int ledgerRecordId) {
    return into(favoriteLedgerRecords).insert(
      FavoriteLedgerRecordsCompanion.insert(ledgerRecordId: ledgerRecordId),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> removeFavoriteLedgerRecord(int ledgerRecordId) async {
    await (delete(favoriteLedgerRecords)
      ..where((tbl) => tbl.ledgerRecordId.equals(ledgerRecordId))).go();
  }

  Stream<Set<int>> watchFavoriteLedgerRecordIds() {
    final query = selectOnly(favoriteLedgerRecords)
      ..addColumns([favoriteLedgerRecords.ledgerRecordId]);
    return query.watch().map(
      (rows) =>
          rows
              .map((row) => row.read(favoriteLedgerRecords.ledgerRecordId)!)
              .toSet(),
    );
  }

  Stream<List<LedgerRecord>> watchFavoriteLedgerRecords() {
    final query =
        select(ledgerRecords).join([
            innerJoin(
              favoriteLedgerRecords,
              favoriteLedgerRecords.ledgerRecordId.equalsExp(
                ledgerRecords.id,
              ),
            ),
          ])
          ..orderBy([OrderingTerm.desc(favoriteLedgerRecords.createdAt)]);

    return query.watch().map(
      (rows) =>
          rows.map((row) => row.readTable(ledgerRecords)).toList(
            growable: false,
          ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(appDir.path, 'money_mate.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
