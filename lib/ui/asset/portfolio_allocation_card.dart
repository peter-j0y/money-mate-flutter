import 'package:flutter/material.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/asset/portfolio_allocation_chart.dart';
import 'package:money_mate/ui/asset/portfolio_allocation_row.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class PortfolioAllocationCard extends StatelessWidget {
  const PortfolioAllocationCard({
    super.key,
    required this.rows,
    this.onSetTargetTap,
  });

  final List<PortfolioRowData> rows;
  final VoidCallback? onSetTargetTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonBg = context.appColors.surfaceMuted;
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: context.appColors.border) : null,
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.portfolioCompositionLabel,
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 28,
                child: TextButton.icon(
                  onPressed: onSetTargetTap,
                  style: TextButton.styleFrom(
                    backgroundColor: buttonBg,
                    foregroundColor: context.appColors.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: Icon(
                    Icons.tune_rounded,
                    size: 13,
                    color: context.appColors.textPrimary,
                  ),
                  label: Text(
                    l10n.setTargetRatioButton,
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w500,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.actualRatioLabel,
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w400,
              color: context.appColors.textTertiary,
            ),
          ),
          const SizedBox(height: 6),
          PortfolioAllocationChart(
            items: rows
                .map(
                  (e) => PortfolioAllocationChartItem(
                    ratio: e.actual,
                    color: e.color,
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 16),
          ...List.generate(rows.length, (index) {
            final row = rows[index];
            return PortfolioAllocationRow(
              label: row.label,
              actualRatio: row.actual,
              targetRatio: row.target,
              color: row.color,
              showDivider: index != rows.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class PortfolioRowData {
  const PortfolioRowData({
    required this.label,
    required this.actual,
    required this.target,
    required this.color,
  });

  final String label;
  final double actual;
  final double target;
  final Color color;
}
