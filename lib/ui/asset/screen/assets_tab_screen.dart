import 'package:flutter/material.dart';
import 'package:money_mate/ui/asset/asset_category_card.dart';
import 'package:money_mate/ui/asset/asset_total_header.dart';
import 'package:money_mate/ui/asset/portfolio_allocation_card.dart';
import 'package:money_mate/ui/asset/screen/add_asset_screen.dart';
import 'package:money_mate/ui/asset/screen/portfolio_target_setting_screen.dart';
import 'package:money_mate/ui/asset/view_models/assets_tab_view_model.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class AssetsTabScreen extends StatefulWidget {
  const AssetsTabScreen({super.key});

  @override
  State<AssetsTabScreen> createState() => _AssetsTabScreenState();
}

class _AssetsTabScreenState extends State<AssetsTabScreen> {
  final AssetsTabViewModel _viewModel = AssetsTabViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  void _openAddAsset() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const AddAssetScreen()),
    );
  }

  void _openPortfolioTargetSetting() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const PortfolioTargetSettingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.isLoading) {
      return const SafeArea(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_viewModel.isEmpty) {
      return _EmptyAssetsView(onAddAssetTap: _openAddAsset);
    }

    return _AssetContentView(
      viewModel: _viewModel,
      onAddAssetTap: _openAddAsset,
      onSetTargetTap: _openPortfolioTargetSetting,
    );
  }
}

class _AssetContentView extends StatelessWidget {
  const _AssetContentView({
    required this.viewModel,
    required this.onAddAssetTap,
    required this.onSetTargetTap,
  });

  final AssetsTabViewModel viewModel;
  final VoidCallback onAddAssetTap;
  final VoidCallback onSetTargetTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryCards = <Widget>[];

    for (final category in viewModel.categoryDataList) {
      final meta = assetTypeMeta[category.type]!;
      final items = category.items.map((item) {
        return AssetCategoryItemData(
          name: item.asset.assetName,
          amountText: item.asset.amount.toKoreanWon(),
          innerRatioText:
              '${meta.label} 내 비중 ${item.innerRatio.toStringAsFixed(1)}%',
          isExcludedFromPortfolio: !item.asset.includeInPortfolio,
          ticker: item.asset.includeInPortfolio ? null : '포트폴리오 제외',
        );
      }).toList();

      categoryCards.add(const SizedBox(height: 12));
      categoryCards.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AssetCategoryCard(
            categoryName: meta.label,
            totalAmountText: category.totalAmount.toKoreanWon(),
            actualRatio: category.actualRatio,
            targetRatio: category.targetRatio,
            accentColor: meta.accentColor,
            leadingIcon: meta.icon,
            leadingBackgroundColor: meta.backgroundColor(isDark),
            items: items,
          ),
        ),
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 140),
        children: [
          AssetTotalHeader(
            totalAssetText: viewModel.totalAmount.toKoreanWon(),
            onAddAssetTap: onAddAssetTap,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildPortfolioSection(context),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '자산 목록',
              style: TextStyle(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w600,
                color: context.appColors.textSecondary,
              ),
            ),
          ),
          ...categoryCards,
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPortfolioSection(BuildContext context) {
    final hasEnabledCategory =
        viewModel.categoryDataList.any((c) => c.isCategoryEnabled);

    if (!hasEnabledCategory) {
      return _PortfolioSetupGuideCard(onSetupTap: onSetTargetTap);
    }

    return PortfolioAllocationCard(
      rows: viewModel.categoryDataList
          .where((c) => c.actualRatio > 0)
          .map((c) {
            final meta = assetTypeMeta[c.type]!;
            return PortfolioRowData(
              label: meta.label,
              actual: c.actualRatio,
              target: c.targetRatio,
              color: meta.accentColor,
            );
          })
          .toList(),
      onSetTargetTap: onSetTargetTap,
    );
  }
}

class _PortfolioSetupGuideCard extends StatelessWidget {
  const _PortfolioSetupGuideCard({required this.onSetupTap});

  final VoidCallback onSetupTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.appColors.primary.withValues(
                alpha: isDark ? 0.18 : 0.1,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pie_chart_outline_rounded,
              size: 28,
              color: context.appColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '포트폴리오를 설정해보세요',
            style: TextStyle(
              fontSize: 16,
              height: 22 / 16,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '목표 비율을 설정하면 자산 배분 현황을\n한눈에 확인할 수 있어요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 18 / 13,
              fontWeight: FontWeight.w400,
              color: context.appColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              onPressed: onSetupTap,
              style: FilledButton.styleFrom(
                elevation: 0,
                backgroundColor: context.appColors.primary,
                foregroundColor: context.appColors.inverseText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '포트폴리오 설정하기',
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAssetsView extends StatelessWidget {
  const _EmptyAssetsView({required this.onAddAssetTap});

  final VoidCallback onAddAssetTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
        children: [
          Text(
            '총 자산',
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.15,
              color: context.appColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '0원',
            style: TextStyle(
              fontSize: 30,
              height: 36 / 30,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 96),
          _EmptyAssetCard(onAddAssetTap: onAddAssetTap),
        ],
      ),
    );
  }
}

class _EmptyAssetCard extends StatelessWidget {
  const _EmptyAssetCard({required this.onAddAssetTap});

  final VoidCallback onAddAssetTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: context.appColors.primary.withValues(
              alpha: isDark ? 0.18 : 0.1,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.account_balance_wallet_outlined,
            size: 44,
            color: context.appColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '아직 등록된 자산이 없어요',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            height: 28 / 20,
            fontWeight: FontWeight.w700,
            color: context.appColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '첫 자산을 추가하고\n포트폴리오를 한눈에 확인해 보세요',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w400,
            color: context.appColors.textTertiary,
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: onAddAssetTap,
            style: FilledButton.styleFrom(
              elevation: 0,
              backgroundColor: context.appColors.primary,
              foregroundColor: context.appColors.inverseText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 20),
                SizedBox(width: 6),
                Text(
                  '자산 추가하기',
                  style: TextStyle(
                    fontSize: 16,
                    height: 24 / 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}