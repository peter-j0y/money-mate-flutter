import 'package:flutter/material.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class PortfolioAllocationRow extends StatelessWidget {
  const PortfolioAllocationRow({
    super.key,
    required this.label,
    required this.actualRatio,
    required this.targetRatio,
    required this.color,
    this.showDivider = true,
  });

  final String label;
  final double actualRatio;
  final double targetRatio;
  final Color color;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final diff = actualRatio - targetRatio;
    final isUp = diff >= 0;
    final badgeColor =
        isUp ? context.appColors.danger : context.appColors.success;
    final badgeBg = badgeColor.withValues(alpha: isDark ? 0.2 : 0.1);

    return Container(
      height: 53,
      decoration: BoxDecoration(
        border:
            showDivider
                ? Border(
                  bottom: BorderSide(color: context.appColors.border, width: 1),
                )
                : null,
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w500,
                color: context.appColors.textSecondary,
              ),
            ),
          ),
          Text(
            '${actualRatio.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(
              context,
            )!.targetRatioWithValue(targetRatio.toStringAsFixed(0)),
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w400,
              color: context.appColors.textTertiary,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            height: 19,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text(
              '${isUp ? '▲' : '▼'}${diff.abs().toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 10,
                height: 15 / 10,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
