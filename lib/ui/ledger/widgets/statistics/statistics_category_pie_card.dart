import 'package:flutter/material.dart';
import 'package:money_mate/data/model/entities/currency.dart';
import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/ledger/view_models/ledger_statistics_view_model.dart';

import 'statistics_category_check.dart';
import 'statistics_chart_utils.dart';
import 'statistics_donut_chart.dart';
import 'statistics_section_card.dart';

/// 한 달의 카테고리별 지출(또는 수입)을 도넛으로 보여주고,
/// 아래 목록에서 카테고리별 금액·비율을 보여주며 그래프에 포함할 카테고리를 고르게 한다.
class StatisticsCategoryPieCard extends StatelessWidget {
  const StatisticsCategoryPieCard({
    super.key,
    required this.type,
    required this.amounts,
    required this.hiddenCategories,
    required this.currency,
    required this.isLoading,
    required this.onCategoryVisibilityChanged,
  });

  final LedgerRecordType type;

  /// 고른 달의 카테고리별 합계(금액 큰 순서).
  final List<MapEntry<String, int>> amounts;
  final Set<String> hiddenCategories;
  final CurrencyCode currency;
  final bool isLoading;
  final void Function(String category, bool visible)
  onCategoryVisibilityChanged;

  bool get _isExpense => type == LedgerRecordType.expense;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StatisticsSectionCard(
      title:
          _isExpense
              ? l10n.statisticsCategoryExpenseTitle
              : l10n.statisticsCategoryIncomeTitle,
      child: _buildBody(context, l10n),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    if (isLoading) {
      return const StatisticsLoadingPlaceholder();
    }
    if (amounts.isEmpty) {
      return StatisticsMessagePlaceholder(
        message:
            _isExpense
                ? l10n.statisticsNoMonthlyExpense
                : l10n.statisticsNoMonthlyIncome,
      );
    }

    final visible =
        amounts
            .where((entry) => !hiddenCategories.contains(entry.key))
            .toList();
    final visibleTotal = visible.fold<int>(
      0,
      (sum, entry) => sum + entry.value,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (visible.isEmpty)
          StatisticsMessagePlaceholder(
            message: l10n.statisticsNoCategorySelected,
          )
        else
          StatisticsDonutChart(
            slices: [
              for (final entry in visible)
                StatisticsDonutSlice(
                  amount: entry.value,
                  color: statisticsCategoryColor(context, type, entry.key),
                ),
            ],
            centerTitle: l10n.statisticsTotal,
            centerValue: visibleTotal.toFormattedCurrency(currency),
          ),
        const SizedBox(height: 12),
        Divider(height: 1, color: context.appColors.border),
        const SizedBox(height: 4),
        for (final entry in amounts)
          _CategoryLegendRow(
            label: statisticsCategoryLabel(l10n, type, entry.key),
            color: statisticsCategoryColor(context, type, entry.key),
            amountText: entry.value.toFormattedCurrency(currency),
            percent:
                hiddenCategories.contains(entry.key)
                    ? null
                    : LedgerStatisticsViewModel.percentOf(
                      entry.value,
                      visibleTotal,
                    ),
            onChanged:
                (checked) => onCategoryVisibilityChanged(entry.key, checked),
          ),
      ],
    );
  }
}

class _CategoryLegendRow extends StatelessWidget {
  const _CategoryLegendRow({
    required this.label,
    required this.color,
    required this.amountText,
    required this.percent,
    required this.onChanged,
  });

  final String label;
  final Color color;
  final String amountText;

  /// null이면 체크 해제된 카테고리다.
  final int? percent;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isChecked = percent != null;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onChanged(!isChecked),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: StatisticsCategoryCheck(
                label: label,
                color: color,
                isChecked: isChecked,
                onChanged: onChanged,
                expandLabel: true,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              amountText,
              style: TextStyle(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w500,
                color: isChecked ? colors.textPrimary : colors.textTertiary,
              ),
            ),
            SizedBox(
              width: 44,
              child: Text(
                isChecked ? '$percent%' : '-',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  color: colors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
