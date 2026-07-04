import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:money_mate/data/local/app_database.dart';
import 'package:money_mate/data/local/asset_local_data_source.dart';
import 'package:money_mate/data/model/entities/asset_entry.dart';

class AssetsTabViewModel extends ChangeNotifier {
  AssetsTabViewModel({AssetLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? AssetLocalDataSource() {
    _subscription = _localDataSource.watchAssets().listen(_onAssetsChanged);
  }

  final AssetLocalDataSource _localDataSource;
  StreamSubscription<List<Asset>>? _subscription;

  List<Asset> _assets = const [];
  bool _isLoading = true;

  List<Asset> get assets => _assets;
  bool get isLoading => _isLoading;
  bool get isEmpty => _assets.isEmpty;

  int get totalAmount => _assets.fold<int>(0, (sum, a) => sum + a.amount);

  int get portfolioTotal => _assets
      .where((a) => a.includeInPortfolio)
      .fold<int>(0, (sum, a) => sum + a.amount);

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

      final categoryTotal =
          assetsInCategory.fold<int>(0, (sum, a) => sum + a.amount);
      final portfolioCategoryTotal = assetsInCategory
          .where((a) => a.includeInPortfolio)
          .fold<int>(0, (sum, a) => sum + a.amount);

      final actualRatio = portfolioTotal > 0
          ? (portfolioCategoryTotal / portfolioTotal) * 100
          : 0.0;

      final items = assetsInCategory.map((asset) {
        final innerRatio =
            categoryTotal > 0 ? (asset.amount / categoryTotal) * 100 : 0.0;
        return AssetItemData(
          asset: asset,
          innerRatio: innerRatio,
        );
      }).toList();

      result.add(AssetCategoryData(
        type: type,
        totalAmount: categoryTotal,
        actualRatio: actualRatio,
        targetRatio: 0,
        items: items,
      ));
    }

    return result;
  }

  void _onAssetsChanged(List<Asset> assets) {
    _assets = assets;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class AssetCategoryData {
  const AssetCategoryData({
    required this.type,
    required this.totalAmount,
    required this.actualRatio,
    required this.targetRatio,
    required this.items,
  });

  final AssetType type;
  final int totalAmount;
  final double actualRatio;
  final double targetRatio;
  final List<AssetItemData> items;
}

class AssetItemData {
  const AssetItemData({
    required this.asset,
    required this.innerRatio,
  });

  final Asset asset;
  final double innerRatio;
}

class AssetTypeMeta {
  const AssetTypeMeta({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
  });

  final String label;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
}

const assetTypeMeta = <AssetType, AssetTypeMeta>{
  AssetType.stock: AssetTypeMeta(
    label: '주식',
    icon: Icons.trending_up_rounded,
    accentColor: Color(0xFF3B82F6),
    backgroundColor: Color(0xFFEFF6FF),
  ),
  AssetType.cash: AssetTypeMeta(
    label: '현금',
    icon: Icons.account_balance_wallet_rounded,
    accentColor: Color(0xFF10B981),
    backgroundColor: Color(0xFFECFDF5),
  ),
  AssetType.realEstate: AssetTypeMeta(
    label: '부동산',
    icon: Icons.home_work_outlined,
    accentColor: Color(0xFFF59E0B),
    backgroundColor: Color(0xFFFFFBEB),
  ),
  AssetType.crypto: AssetTypeMeta(
    label: '가상화폐',
    icon: Icons.currency_bitcoin_rounded,
    accentColor: Color(0xFF8B5CF6),
    backgroundColor: Color(0xFFF5F3FF),
  ),
  AssetType.savings: AssetTypeMeta(
    label: '예적금',
    icon: Icons.savings_outlined,
    accentColor: Color(0xFF0EA5E9),
    backgroundColor: Color(0xFFF0F9FF),
  ),
  AssetType.commodity: AssetTypeMeta(
    label: '원자재',
    icon: Icons.all_inclusive_rounded,
    accentColor: Color(0xFFEF4444),
    backgroundColor: Color(0xFFFEF2F2),
  ),
  AssetType.other: AssetTypeMeta(
    label: '기타',
    icon: Icons.category_outlined,
    accentColor: Color(0xFF6B7280),
    backgroundColor: Color(0xFFF9FAFB),
  ),
};
