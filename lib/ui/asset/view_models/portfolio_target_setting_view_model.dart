import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:money_mate/data/local/app_database.dart';
import 'package:money_mate/data/local/asset_local_data_source.dart';
import 'package:money_mate/data/local/portfolio_target_local_data_source.dart';
import 'package:money_mate/data/model/entities/asset_entry.dart';

class PortfolioTargetSettingViewModel extends ChangeNotifier {
  PortfolioTargetSettingViewModel({
    AssetLocalDataSource? assetDataSource,
    PortfolioTargetLocalDataSource? targetDataSource,
  }) : _assetDataSource = assetDataSource ?? AssetLocalDataSource(),
       _targetDataSource = targetDataSource ?? PortfolioTargetLocalDataSource() {
    _init();
  }

  final AssetLocalDataSource _assetDataSource;
  final PortfolioTargetLocalDataSource _targetDataSource;

  StreamSubscription<List<Asset>>? _assetSubscription;

  List<Asset> _assets = const [];
  final Map<AssetType, TargetItemState> _itemStates = {};
  bool _isLoading = true;
  bool _isSaving = false;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  List<TargetItemState> get items =>
      AssetType.values.map((type) => _itemStates[type]!).toList();

  int get includedTotal => _itemStates.values
      .where((item) => item.isEnabled)
      .fold(0, (sum, item) => sum + item.targetRatio);

  bool get isBalanced => includedTotal == 100;

  int get _portfolioTotal {
    var total = 0;
    for (final asset in _assets) {
      if (!asset.includeInPortfolio) continue;
      final type = AssetTypeFromCode.fromCode(asset.assetType);
      if (type == null) continue;
      final state = _itemStates[type];
      if (state != null && !state.isEnabled) continue;
      total += asset.amount;
    }
    return total;
  }

  Future<void> _init() async {
    for (final type in AssetType.values) {
      _itemStates[type] = TargetItemState(
        type: type,
        actualRatio: 0,
        targetRatio: 0,
        isEnabled: false,
      );
    }

    final targets = await _targetDataSource.getTargets();
    for (final target in targets) {
      final type = AssetTypeFromCode.fromCode(target.assetType);
      if (type != null) {
        _itemStates[type] = TargetItemState(
          type: type,
          actualRatio: 0,
          targetRatio: target.targetRatio,
          isEnabled: target.isEnabled,
        );
      }
    }

    _assetSubscription = _assetDataSource.watchAssets().listen(_onAssetsChanged);
  }

  void _onAssetsChanged(List<Asset> assets) {
    _assets = assets;
    _recalculateActualRatios();
    _isLoading = false;
    notifyListeners();
  }

  void _recalculateActualRatios() {
    final portfolioTotal = _portfolioTotal;
    final categoryTotals = <AssetType, int>{};

    for (final asset in _assets) {
      if (!asset.includeInPortfolio) continue;
      final type = AssetTypeFromCode.fromCode(asset.assetType);
      if (type == null) continue;
      final state = _itemStates[type];
      if (state != null && !state.isEnabled) continue;
      categoryTotals[type] = (categoryTotals[type] ?? 0) + asset.amount;
    }

    for (final type in AssetType.values) {
      final oldState = _itemStates[type]!;
      final categoryTotal = categoryTotals[type] ?? 0;
      final actualRatio = portfolioTotal > 0
          ? (categoryTotal / portfolioTotal) * 100
          : 0.0;
      _itemStates[type] = TargetItemState(
        type: type,
        actualRatio: actualRatio,
        targetRatio: oldState.targetRatio,
        isEnabled: oldState.isEnabled,
      );
    }
  }

  void toggleEnabled(AssetType type, bool value) {
    final oldState = _itemStates[type]!;
    _itemStates[type] = TargetItemState(
      type: type,
      actualRatio: oldState.actualRatio,
      targetRatio: value ? (oldState.targetRatio == 0 ? 10 : oldState.targetRatio) : 0,
      isEnabled: value,
    );
    _recalculateActualRatios();
    notifyListeners();
  }

  void updateTargetRatio(AssetType type, int ratio) {
    final oldState = _itemStates[type]!;
    _itemStates[type] = TargetItemState(
      type: type,
      actualRatio: oldState.actualRatio,
      targetRatio: ratio.clamp(0, 100),
      isEnabled: oldState.isEnabled,
    );
    notifyListeners();
  }

  void applyEqualDistribution() {
    final enabledTypes = _itemStates.entries
        .where((e) => e.value.isEnabled)
        .map((e) => e.key)
        .toList();

    if (enabledTypes.isEmpty) return;

    final base = 100 ~/ enabledTypes.length;
    var remainder = 100 % enabledTypes.length;

    for (final type in enabledTypes) {
      final oldState = _itemStates[type]!;
      _itemStates[type] = TargetItemState(
        type: type,
        actualRatio: oldState.actualRatio,
        targetRatio: base + (remainder > 0 ? 1 : 0),
        isEnabled: true,
      );
      if (remainder > 0) remainder--;
    }
    notifyListeners();
  }

  Future<bool> save() async {
    if (_isSaving) return false;

    _isSaving = true;
    notifyListeners();

    try {
      final targets = _itemStates.values
          .map((state) => PortfolioTargetData(
                assetType: state.type,
                isEnabled: state.isEnabled,
                targetRatio: state.targetRatio,
              ))
          .toList();

      await _targetDataSource.upsertAllTargets(targets);
      return true;
    } catch (e) {
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _assetSubscription?.cancel();
    super.dispose();
  }
}

class TargetItemState {
  const TargetItemState({
    required this.type,
    required this.actualRatio,
    required this.targetRatio,
    required this.isEnabled,
  });

  final AssetType type;
  final double actualRatio;
  final int targetRatio;
  final bool isEnabled;
}