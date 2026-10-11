import 'package:flutter/material.dart';
import 'package:money_mate/data/model/entities/currency.dart';
import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/ledger/view_models/ledger_statistics_view_model.dart';

import 'statistics_chart_utils.dart';
import 'statistics_section_card.dart';
import 'statistics_stacked_bar_chart.dart';

/// 최근 최대 12개월의 카테고리별 지출(또는 수입)을 세로 누적 막대로 보여준다.
/// 그래프 위에는 선택한 달의 카테고리별 금액·비율을, 아래에는 색 범례를 둔다.
/// 카테고리 필터는 원형 섹션에만 있고, 이 카드는 항상 모든 카테고리를 보여준다.
class StatisticsCategoryTrendCard extends StatelessWidget {
  const StatisticsCategoryTrendCard({
    super.key,
    required this.type,
    required this.trend,
    required this.categories,
    required this.currency,
    required this.selectedIndex,
    required this.isLoading,
    required this.onSelect,
  });

  final LedgerRecordType type;
  final List<MonthlyCategoryAmounts> trend;

  /// 기간 안에 기록이 있는 카테고리(카테고리 정의 순서, 막대에 쌓는 순서).
  final List<String> categories;
  final CurrencyCode currency;
  final int? selectedIndex;
  final bool isLoading;
  final ValueChanged<int> onSelect;

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
      return const StatisticsLoadingPlaceholder(height: 200);
    }
    if (categories.isEmpty) {
      return StatisticsMessagePlaceholder(
        message:
            _isExpense
                ? l10n.statisticsNoTrendExpense
                : l10n.statisticsNoTrendIncome,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSelectedMonthDetail(context, l10n),
        const SizedBox(height: 12),
        StatisticsStackedBarChart(
          months: [for (final item in trend) item.month],
          stacks: [
            for (final item in trend)
              [
                for (final category in categories)
                  StatisticsStackSegment(
                    amount: item.amounts[category] ?? 0,
                    color: statisticsCategoryColor(context, type, category),
                  ),
              ],
          ],
          currency: currency,
          selectedIndex: selectedIndex,
          onSelect: onSelect,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            for (final category in categories)
              _CategoryLegendItem(
                label: statisticsCategoryLabel(l10n, type, category),
                color: statisticsCategoryColor(context, type, category),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedMonthDetail(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final colors = context.appColors;
    final index = selectedIndex ?? trend.length - 1;
    final selected = trend[index];
    final entries = [
      for (final category in categories)
        if ((selected.amounts[category] ?? 0) > 0)
          MapEntry(category, selected.amounts[category]!),
    ]..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);
    final monthLabel = l10n.yearMonth(
      selected.month.year,
      selected.month.month,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.statisticsSelectedMonthTotal(
            monthLabel,
            total.toFormattedCurrency(currency),
          ),
          style: TextStyle(
            fontSize: 13,
            height: 18 / 13,
            fontWeight: FontWeight.w500,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        if (entries.isEmpty)
          Text(
            _isExpense
                ? l10n.statisticsNoMonthlyExpense
                : l10n.statisticsNoMonthlyIncome,
            style: TextStyle(
              fontSize: 13,
              height: 18 / 13,
              color: colors.textTertiary,
            ),
          )
        else
          for (final entry in entries)
            _CategoryAmountRow(
              label: statisticsCategoryLabel(l10n, type, entry.key),
              color: statisticsCategoryColor(context, type, entry.key),
              amountText: entry.value.toFormattedCurrency(currency),
              percent: LedgerStatisticsViewModel.percentOf(entry.value, total),
            ),
      ],
    );
  }
}

class _CategoryAmountRow extends StatelessWidget {
  const _CategoryAmountRow({
    required this.label,
    required this.color,
    required this.amountText,
    required this.percent,
  });

  final String label;
  final Color color;
  final String amountText;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final style = TextStyle(
      fontSize: 13,
      height: 18 / 13,
      color: colors.textPrimary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
          const SizedBox(width: 8),
          Text(amountText, style: style.copyWith(fontWeight: FontWeight.w500)),
          SizedBox(
            width: 44,
            child: Text(
              '$percent%',
              textAlign: TextAlign.right,
              style: style.copyWith(color: colors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

/// 누적 막대의 색이 어느 카테고리인지 알려주는 범례 항목(● 이름).
class _CategoryLegendItem extends StatelessWidget {
  const _CategoryLegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            height: 18 / 13,
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
