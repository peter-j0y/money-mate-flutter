import 'package:money_mate/data/local/portfolio_target_local_data_source.dart';
import 'package:money_mate/data/model/entities/asset_entry.dart';
import 'package:money_mate/data/repositories/portfolio_target_repository.dart';

class PortfolioTargetRepositoryImpl implements PortfolioTargetRepository {
  PortfolioTargetRepositoryImpl({
    PortfolioTargetLocalDataSource? localDataSource,
  }) : _localDataSource = localDataSource ?? PortfolioTargetLocalDataSource();

  final PortfolioTargetLocalDataSource _localDataSource;

  @override
  Future<List<PortfolioTargetEntry>> getTargets() async {
    final targets = await _localDataSource.getTargets();
    return targets
        .map((t) {
          final type = AssetTypeFromCode.fromCode(t.assetType);
          if (type == null) return null;
          return PortfolioTargetEntry(
            assetType: type,
            isEnabled: t.isEnabled,
            targetRatio: t.targetRatio,
          );
        })
        .whereType<PortfolioTargetEntry>()
        .toList();
  }

  @override
  Stream<List<PortfolioTargetEntry>> watchTargets() {
    return _localDataSource.watchTargets().map((targets) {
      return targets
          .map((t) {
            final type = AssetTypeFromCode.fromCode(t.assetType);
            if (type == null) return null;
            return PortfolioTargetEntry(
              assetType: type,
              isEnabled: t.isEnabled,
              targetRatio: t.targetRatio,
            );
          })
          .whereType<PortfolioTargetEntry>()
          .toList();
    });
  }

  @override
  Future<void> upsertTarget({
    required AssetType assetType,
    required bool isEnabled,
    required int targetRatio,
  }) {
    return _localDataSource.upsertTarget(
      assetType: assetType,
      isEnabled: isEnabled,
      targetRatio: targetRatio,
    );
  }

  @override
  Future<void> upsertAllTargets(List<PortfolioTargetData> targets) {
    return _localDataSource.upsertAllTargets(targets);
  }
}