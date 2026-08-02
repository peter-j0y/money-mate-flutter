import 'package:flutter/material.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/asset/asset_category_card.dart';
import 'package:money_mate/ui/asset/asset_total_header.dart';
import 'package:money_mate/ui/asset/portfolio_allocation_card.dart';
import 'package:money_mate/ui/asset/screen/add_asset_screen.dart';
import 'package:money_mate/ui/asset/screen/asset_detail_screen.dart';
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
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
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
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryCards = <Widget>[];

    for (final category in viewModel.categoryDataList) {
      final meta = assetTypeMeta[category.type]!;
      final items =
          category.items.map((item) {
            return AssetCategoryItemData(
              asset: item.asset,
              name: item.asset.assetName,
              amountText: item.asset.amount.toKoreanWon(),
              innerRatio: item.innerRatio,
              innerRatioText: l10n.innerRatioWithValue(
                meta.label(l10n),
                item.innerRatio.toStringAsFixed(1),
              ),
              isExcludedFromPortfolio: !item.asset.includeInPortfolio,
              ticker:
                  item.asset.includeInPortfolio
                      ? null
                      : l10n.excludedFromPortfolio,
            );
          }).toList();

      categoryCards.add(const SizedBox(height: 12));
      categoryCards.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AssetCategoryCard(
            categoryName: meta.label(l10n),
            totalAmountText: category.totalAmount.toKoreanWon(),
            actualRatio: category.actualRatio,
            targetRatio: category.targetRatio,
            accentColor: meta.accentColor,
            leadingIcon: meta.icon,
            leadingBackgroundColor: meta.backgroundColor(isDark),
            isCategoryEnabled: category.isCategoryEnabled,
            items: items,
            onItemTap: (item) {
              final overallRatio =
                  viewModel.totalAmount > 0
                      ? (item.asset.amount / viewModel.totalAmount) * 100
                      : 0.0;
              Navigator.of(context).push(
                MaterialPageRoute<bool>(
                  builder:
                      (_) => AssetDetailScreen(
                        asset: item.asset,
                        categoryMeta: meta,
                        innerRatio: item.innerRatio,
                        overallRatio: overallRatio,
                      ),
                ),
              );
            },
          ),
        ),
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 48),
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
              l10n.assetListLabel,
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
    final l10n = AppLocalizations.of(context)!;
    final hasEnabledCategory = viewModel.categoryDataList.any(
      (c) => c.isCategoryEnabled,
    );

    if (!hasEnabledCategory) {
      return _PortfolioSetupGuideCard(onSetupTap: onSetTargetTap);
    }

    return PortfolioAllocationCard(
      rows:
          viewModel.categoryDataList.where((c) => c.actualRatio > 0).map((c) {
            final meta = assetTypeMeta[c.type]!;
            return PortfolioRowData(
              label: meta.label(l10n),
              actual: c.actualRatio,
              target: c.targetRatio,
              color: meta.accentColor,
            );
          }).toList(),
      onSetTargetTap: onSetTargetTap,
    );
  }
}

class _PortfolioSetupGuideCard extends StatelessWidget {
  const _PortfolioSetupGuideCard({required this.onSetupTap});

  final VoidCallback onSetupTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            l10n.setupPortfolioTitle,
            style: TextStyle(
              fontSize: 16,
              height: 22 / 16,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.setupPortfolioBody,
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
              child: Text(
                l10n.setupPortfolioButton,
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
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
        children: [
          Text(
            l10n.totalAssetsLabel,
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
            0.toKoreanWon(),
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
    final l10n = AppLocalizations.of(context)!;
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
          l10n.noAssetsYet,
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
          l10n.addFirstAssetBody,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, size: 20),
                const SizedBox(width: 6),
                Text(
                  l10n.addAssetButton,
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
