import 'package:flutter/material.dart';
import 'package:money_mate/data/local/app_database.dart';
import 'package:money_mate/data/model/entities/currency.dart';
import 'package:money_mate/data/repositories/asset_repository.dart';
import 'package:money_mate/data/repositories/asset_repository_impl.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/asset/screen/add_asset_screen.dart';
import 'package:money_mate/ui/asset/view_models/assets_tab_view_model.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class AssetDetailScreen extends StatefulWidget {
  const AssetDetailScreen({
    super.key,
    required this.asset,
    required this.categoryMeta,
    required this.innerRatio,
    required this.overallRatio,
  });

  final Asset asset;
  final AssetTypeMeta categoryMeta;
  final double innerRatio;
  final double overallRatio;

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  final AssetRepository _repository = AssetRepositoryImpl();
  bool _isDeleting = false;

  Future<void> _onEditTap() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddAssetScreen(initialAsset: widget.asset),
      ),
    );
    if (!mounted) {
      return;
    }
    if (result == true) {
      Navigator.of(context).pop(true);
    }
  }

  Future<bool> _showDeleteConfirmDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: context.appColors.surface,
          content: Text(l10n.deleteAssetConfirm),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: context.appColors.primary,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: context.appColors.danger,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _onDeleteTap() async {
    if (_isDeleting) {
      return;
    }

    final confirmed = await _showDeleteConfirmDialog();
    if (!mounted || !confirmed) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    setState(() => _isDeleting = true);

    try {
      final deleted = await _repository.deleteAsset(widget.asset.id);
      if (!mounted) {
        return;
      }

      if (!deleted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorAssetDeleteNotFound)));
        setState(() => _isDeleting = false);
        return;
      }

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorDeleteFailed)));
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meta = widget.categoryMeta;
    final asset = widget.asset;

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _DetailTopBar(
              onBackTap: () => Navigator.of(context).pop(),
              onDeleteTap: _onDeleteTap,
              isDeleting: _isDeleting,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailHero(
                      isDark: isDark,
                      categoryMeta: meta,
                      assetName: asset.assetName,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AmountCard(
                            amount: asset.amount,
                            currency: CurrencyCode.fromCode(
                              asset.currencyCode,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _RatioMiniCard(
                                  label: l10n.innerRatioLabel(meta.label(l10n)),
                                  ratio: widget.innerRatio,
                                  color: meta.accentColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _RatioMiniCard(
                                  label: l10n.overallRatioLabel,
                                  ratio: widget.overallRatio,
                                  color: context.appColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _PortfolioStatusCard(
                            isDark: isDark,
                            accentColor: meta.accentColor,
                            includeInPortfolio: asset.includeInPortfolio,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _DetailBottomActions(onEditTap: _onEditTap),
          ],
        ),
      ),
    );
  }
}

class _DetailTopBar extends StatelessWidget {
  const _DetailTopBar({
    required this.onBackTap,
    required this.onDeleteTap,
    required this.isDeleting,
  });

  final VoidCallback onBackTap;
  final VoidCallback onDeleteTap;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  onPressed: onBackTap,
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    size: 28,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                l10n.assetDetailTitle,
                style: TextStyle(
                  fontSize: 18,
                  height: 24 / 18,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: isDeleting ? null : onDeleteTap,
                style: TextButton.styleFrom(
                  foregroundColor: context.appColors.danger,
                ),
                child:
                    isDeleting
                        ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.appColors.danger,
                          ),
                        )
                        : Text(
                          l10n.commonDelete,
                          style: TextStyle(
                            fontSize: 14,
                            height: 20 / 14,
                            fontWeight: FontWeight.w600,
                            color: context.appColors.danger,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailHero extends StatelessWidget {
  const _DetailHero({
    required this.isDark,
    required this.categoryMeta,
    required this.assetName,
  });

  final bool isDark;
  final AssetTypeMeta categoryMeta;
  final String assetName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  categoryMeta.icon,
                  size: 16,
                  color: categoryMeta.accentColor,
                ),
                const SizedBox(width: 6),
                Text(
                  categoryMeta.label(l10n),
                  style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w600,
                    color: categoryMeta.accentColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            assetName,
            style: TextStyle(
              fontSize: 22,
              height: 33 / 22,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({required this.amount, required this.currency});

  final int amount;
  final CurrencyCode currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.evaluatedAmountLabel,
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w400,
              color: context.appColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount.toFormattedCurrency(currency),
            style: TextStyle(
              fontSize: 24,
              height: 36 / 24,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatioMiniCard extends StatelessWidget {
  const _RatioMiniCard({
    required this.label,
    required this.ratio,
    required this.color,
  });

  final String label;
  final double ratio;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final clamped = ratio.clamp(0, 100).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w400,
              color: context.appColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${ratio.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 20,
              height: 28 / 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(color: context.appColors.surfaceMuted),
                  FractionallySizedBox(
                    widthFactor: clamped / 100,
                    alignment: Alignment.centerLeft,
                    child: Container(color: color),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioStatusCard extends StatelessWidget {
  const _PortfolioStatusCard({
    required this.isDark,
    required this.accentColor,
    required this.includeInPortfolio,
  });

  final bool isDark;
  final Color accentColor;
  final bool includeInPortfolio;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final iconColor =
        includeInPortfolio ? accentColor : context.appColors.textTertiary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(
              includeInPortfolio
                  ? Icons.pie_chart_rounded
                  : Icons.remove_circle_outline_rounded,
              size: 18,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  includeInPortfolio
                      ? l10n.includedInPortfolio
                      : l10n.excludedFromPortfolio,
                  style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  includeInPortfolio
                      ? l10n.includeInPortfolioSubtitle
                      : l10n.excludedFromTargetCalc,
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w400,
                    color: context.appColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailBottomActions extends StatelessWidget {
  const _DetailBottomActions({required this.onEditTap});

  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 13, 20, safeAreaBottom + 20),
      child: _ActionButton(
        label: AppLocalizations.of(context)!.commonUpdate,
        color: context.appColors.inverseText,
        backgroundColor: context.appColors.primary,
        onTap: onEditTap,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
