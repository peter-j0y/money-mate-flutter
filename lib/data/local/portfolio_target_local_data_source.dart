import 'package:drift/drift.dart';
import 'package:money_mate/data/local/app_database.dart';
import 'package:money_mate/data/model/entities/asset_entry.dart';

class PortfolioTargetLocalDataSource {
  PortfolioTargetLocalDataSource({AppDatabase? database})
    : _database = database ?? AppDatabase();

  final AppDatabase _database;

  Future<void> upsertTarget({
    required AssetType assetType,
    required bool isEnabled,
    required int targetRatio,
  }) {
    return _database.upsertPortfolioTarget(
      PortfolioTargetsCompanion.insert(
        assetType: assetType.code,
        isEnabled: Value(isEnabled),
        targetRatio: Value(targetRatio),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> upsertAllTargets(List<PortfolioTargetData> targets) async {
    for (final target in targets) {
      await upsertTarget(
        assetType: target.assetType,
        isEnabled: target.isEnabled,
        targetRatio: target.targetRatio,
      );
    }
  }

  Future<List<PortfolioTarget>> getTargets() {
    return _database.getPortfolioTargets();
  }

  Stream<List<PortfolioTarget>> watchTargets() {
    return _database.watchPortfolioTargets();
  }
}

class PortfolioTargetData {
  const PortfolioTargetData({
    required this.assetType,
    required this.isEnabled,
    required this.targetRatio,
  });

  final AssetType assetType;
  final bool isEnabled;
  final int targetRatio;
}