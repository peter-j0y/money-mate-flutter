import 'dart:async';

import 'package:flutter/material.dart';
import 'package:money_mate/data/local/app_database.dart';
import 'package:money_mate/data/local/asset_local_data_source.dart';
import 'package:money_mate/data/local/portfolio_target_local_data_source.dart';
import 'package:money_mate/data/model/entities/asset_entry.dart';
import 'package:money_mate/data/model/entities/currency.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/design_system/app_colors.dart';

class AssetsTabViewModel extends ChangeNotifier {
  AssetsTabViewModel({
    AssetLocalDataSource? assetDataSource,
    PortfolioTargetLocalDataSource? targetDataSource,
  }) : _assetDataSource = assetDataSource ?? AssetLocalDataSource(),
       _targetDataSource =
           targetDataSource ?? PortfolioTargetLocalDataSource() {
    _assetSubscription = _assetDataSource.watchAssets().listen(
      _onAssetsChanged,
    );
    _targetSubscription = _targetDataSource.watchTargets().listen(
      _onTargetsChanged,
    );
  }

  final AssetLocalDataSource _assetDataSource;
  final PortfolioTargetLocalDataSource _targetDataSource;
  StreamSubscription<List<Asset>>? _assetSubscription;
  StreamSubscription<List<PortfolioTarget>>? _targetSubscription;

  List<Asset> _assets = const [];
  Map<String, PortfolioTarget> _targetMap = const {};
  bool _isLoading = true;

  List<Asset> get assets => _assets;
  bool get isLoading => _isLoading;
  bool get isEmpty => _assets.isEmpty;

  int get totalAmount => _assets.fold<int>(0, (sum, a) => sum + a.amount);

  /// 통화별 자산 합계. 표시용으로는 이 값을 사용해 통화가 섞여도
  /// "₩1,000,000 · $200"처럼 정확하게 보여준다.
  /// (참고: [totalAmount]와 아래 비율 계산은 환율 연동 전이라 통화가 섞이면
  /// 부정확할 수 있다 — Phase 2에서 환율 적용 후 개선 예정)
  Map<CurrencyCode, int> get totalAmountsByCurrency {
    final result = <CurrencyCode, int>{};
    for (final asset in _assets) {
      final currency = CurrencyCode.fromCode(asset.currencyCode);
      result[currency] = (result[currency] ?? 0) + asset.amount;
    }
    return result;
  }

  int get portfolioTotal {
    var total = 0;
    for (final asset in _assets) {
      if (!asset.includeInPortfolio) continue;
      final target = _targetMap[asset.assetType];
      if (target != null && !target.isEnabled) continue;
      total += asset.amount;
    }
    return total;
  }

  List<AssetCategoryData> get categoryDataList {
    final grouped = <AssetType, List<Asset>>{};
    for (final asset in _assets) {
      final type = AssetTypeFromCode.fromCode(asset.assetType);
      if (type != null) {
        grouped.putIfAbsent(type, () => []).add(asset);
      }
    }

    final result = <AssetCategoryData>[];
    for (final type in AssetType.values) {
      final assetsInCategory = grouped[type];
      if (assetsInCategory == null || assetsInCategory.isEmpty) continue;

      final target = _targetMap[type.code];
      final isCategoryEnabled = target?.isEnabled ?? true;
      final targetRatio = target?.targetRatio ?? 0;

      final categoryTotal = assetsInCategory.fold<int>(
        0,
        (sum, a) => sum + a.amount,
      );
      final categorySubtotalsByCurrency = <CurrencyCode, int>{};
      for (final a in assetsInCategory) {
        final currency = CurrencyCode.fromCode(a.currencyCode);
        categorySubtotalsByCurrency[currency] =
            (categorySubtotalsByCurrency[currency] ?? 0) + a.amount;
      }

      final portfolioCategoryTotal =
          isCategoryEnabled
              ? assetsInCategory
                  .where((a) => a.includeInPortfolio)
                  .fold<int>(0, (sum, a) => sum + a.amount)
              : 0;

      final actualRatio =
          portfolioTotal > 0
              ? (portfolioCategoryTotal / portfolioTotal) * 100
              : 0.0;

      final items =
          assetsInCategory.map((asset) {
            final innerRatio =
                categoryTotal > 0 ? (asset.amount / categoryTotal) * 100 : 0.0;
            return AssetItemData(asset: asset, innerRatio: innerRatio);
          }).toList();

      result.add(
        AssetCategoryData(
          type: type,
          totalAmount: categoryTotal,
          subtotalsByCurrency: categorySubtotalsByCurrency,
          actualRatio: actualRatio,
          targetRatio: targetRatio.toDouble(),
          isCategoryEnabled: isCategoryEnabled,
          items: items,
        ),
      );
    }

    return result;
  }

  void _onAssetsChanged(List<Asset> assets) {
    _assets = assets;
    _isLoading = false;
    notifyListeners();
  }

  void _onTargetsChanged(List<PortfolioTarget> targets) {
    _targetMap = {for (final t in targets) t.assetType: t};
    notifyListeners();
  }

  @override
  void dispose() {
    _assetSubscription?.cancel();
    _targetSubscription?.cancel();
    super.dispose();
  }
}

class AssetCategoryData {
  const AssetCategoryData({
    required this.type,
    required this.totalAmount,
    required this.subtotalsByCurrency,
    required this.actualRatio,
    required this.targetRatio,
    required this.isCategoryEnabled,
    required this.items,
  });

  final AssetType type;
  final int totalAmount;
  final Map<CurrencyCode, int> subtotalsByCurrency;
  final double actualRatio;
  final double targetRatio;
  final bool isCategoryEnabled;
  final List<AssetItemData> items;
}

class AssetItemData {
  const AssetItemData({required this.asset, required this.innerRatio});

  final Asset asset;
  final double innerRatio;
}

class AssetTypeMeta {
  const AssetTypeMeta({
    required this.type,
    required this.icon,
    required this.accentColor,
  });

  final AssetType type;
  final IconData icon;
  final Color accentColor;

  Color backgroundColor(bool isDark) =>
      accentColor.withValues(alpha: isDark ? 0.15 : 0.1);

  String label(AppLocalizations l10n) {
    switch (type) {
      case AssetType.stock:
        return l10n.assetTypeStock;
      case AssetType.cash:
        return l10n.assetTypeCash;
      case AssetType.realEstate:
        return l10n.assetTypeRealEstate;
      case AssetType.crypto:
        return l10n.assetTypeCrypto;
      case AssetType.savings:
        return l10n.assetTypeSavings;
      case AssetType.commodity:
        return l10n.assetTypeCommodity;
      case AssetType.other:
        return l10n.assetTypeOther;
    }
  }
}

const assetTypeMeta = <AssetType, AssetTypeMeta>{
  AssetType.stock: AssetTypeMeta(
    type: AssetType.stock,
    icon: Icons.trending_up_rounded,
    accentColor: AppColors.hexFF3B82F6,
  ),
  AssetType.cash: AssetTypeMeta(
    type: AssetType.cash,
    icon: Icons.account_balance_wallet_rounded,
    accentColor: AppColors.hexFF10B981,
  ),
  AssetType.realEstate: AssetTypeMeta(
    type: AssetType.realEstate,
    icon: Icons.home_work_outlined,
    accentColor: AppColors.hexFFF59E0B,
  ),
  AssetType.crypto: AssetTypeMeta(
    type: AssetType.crypto,
    icon: Icons.currency_bitcoin_rounded,
    accentColor: AppColors.hexFF8B5CF6,
  ),
  AssetType.savings: AssetTypeMeta(
    type: AssetType.savings,
    icon: Icons.savings_outlined,
    accentColor: AppColors.hexFF0EA5E9,
  ),
  AssetType.commodity: AssetTypeMeta(
    type: AssetType.commodity,
    icon: Icons.all_inclusive_rounded,
    accentColor: AppColors.hexFFF43F5E,
  ),
  AssetType.other: AssetTypeMeta(
    type: AssetType.other,
    icon: Icons.category_outlined,
    accentColor: AppColors.hexFF6B7280,
  ),
};
