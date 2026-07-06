import 'package:money_mate/data/local/portfolio_target_local_data_source.dart';
import 'package:money_mate/data/model/entities/asset_entry.dart';

abstract class PortfolioTargetRepository {
  Future<List<PortfolioTargetEntry>> getTargets();
  Stream<List<PortfolioTargetEntry>> watchTargets();
  Future<void> upsertTarget({
    required AssetType assetType,
    required bool isEnabled,
    required int targetRatio,
  });
  Future<void> upsertAllTargets(List<PortfolioTargetData> targets);
}

class PortfolioTargetEntry {
  const PortfolioTargetEntry({
    required this.assetType,
    required this.isEnabled,
    required this.targetRatio,
  });

  final AssetType assetType;
  final bool isEnabled;
  final int targetRatio;
}