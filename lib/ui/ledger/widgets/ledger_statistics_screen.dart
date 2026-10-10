import 'package:flutter/material.dart';
import 'package:money_mate/data/model/entities/currency.dart';
import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/data/model/entities/statistics_preferences.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/currency/current_currency.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/ledger/view_models/ledger_statistics_view_model.dart';

import 'ledger_month_selector.dart';
import 'ledger_screen_header.dart';
import 'statistics/statistics_category_pie_card.dart';
import 'statistics/statistics_category_trend_card.dart';
import 'statistics/statistics_chart_type_toggle.dart';
import 'statistics/statistics_section_card.dart';
import 'statistics/statistics_trend_chart.dart';

class LedgerStatisticsScreen extends StatefulWidget {
  const LedgerStatisticsScreen({
    super.key,
    required this.initialMonth,
    this.viewModel,
  });

  /// 원형 섹션이 처음 보여줄 달(가계부 탭에서 보던 달).
  final DateTime initialMonth;

  /// 테스트에서 주입할 때만 사용한다.
  final LedgerStatisticsViewModel? viewModel;

  @override
  State<LedgerStatisticsScreen> createState() => _LedgerStatisticsScreenState();
}

class _LedgerStatisticsScreenState extends State<LedgerStatisticsScreen> {
  late final LedgerStatisticsViewModel _viewModel =
      widget.viewModel ?? LedgerStatisticsViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.start(
      initialMonth: widget.initialMonth,
      primary: CurrentCurrency.code,
    );
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openMonthPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _viewModel.selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: Localizations.localeOf(context),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked == null) return;
    _viewModel.selectMonth(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final errorMessage = _viewModel.errorMessage(l10n);
    final currencies = _viewModel.availableCurrencies;
    final selectedMonth = _viewModel.selectedMonth;

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: Column(
          children: [
            LedgerScreenHeader(
              title: l10n.statisticsTitle,
              closeIcon: Icons.arrow_back_ios_new_rounded,
              closeTooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onCloseTap: () => Navigator.of(context).maybePop(),
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                children: [
                  if (errorMessage != null) ...[
                    Text(
                      errorMessage,
                      style: TextStyle(
                        fontSize: 13,
                        height: 18 / 13,
                        color: context.appColors.danger,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (!_viewModel.isLoading && currencies.length > 1) ...[
                    _CurrencyChips(
                      currencies: currencies,
                      selected: _viewModel.currency,
                      onSelected: _viewModel.selectCurrency,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _SectionTitle(title: l10n.statisticsMonthlySectionTitle),
                  const SizedBox(height: 8),
                  LedgerMonthSelector(
                    monthLabel: l10n.yearMonth(
                      selectedMonth.year,
                      selectedMonth.month,
                    ),
                    onPreviousTap: () => _viewModel.changeMonth(-1),
                    onNextTap: () => _viewModel.changeMonth(1),
                    onLabelTap: _openMonthPicker,
                  ),
                  const SizedBox(height: 8),
                  _buildPieCard(LedgerRecordType.expense),
                  const SizedBox(height: 12),
                  _buildPieCard(LedgerRecordType.income),
                  const SizedBox(height: 32),
                  _SectionTitle(title: l10n.statisticsTrendSectionTitle),
                  const SizedBox(height: 12),
                  _buildTrendSection(l10n),
                  const SizedBox(height: 12),
                  _buildCategoryTrendCard(LedgerRecordType.expense),
                  const SizedBox(height: 12),
                  _buildCategoryTrendCard(LedgerRecordType.income),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendSection(AppLocalizations l10n) {
    final trend = _viewModel.monthlyTrend;
    final selectedIndex = _viewModel.selectedTrendIndex;
    final currency = _viewModel.currency;

    Widget body;
    if (_viewModel.isLoading) {
      body = const StatisticsLoadingPlaceholder(height: 200);
    } else if (trend.isEmpty) {
      body = StatisticsMessagePlaceholder(message: l10n.statisticsNoTrendData);
    } else {
      final selected = trend[selectedIndex ?? trend.length - 1];
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.statisticsSelectedMonthSummary(
              l10n.yearMonth(selected.month.year, selected.month.month),
              selected.income.toFormattedCurrency(currency),
              selected.expense.toFormattedCurrency(currency),
            ),
            style: TextStyle(
              fontSize: 13,
              height: 18 / 13,
              fontWeight: FontWeight.w500,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _SeriesLegend(
                label: l10n.typeIncome,
                color: context.appColors.primary,
              ),
              const SizedBox(width: 12),
              _SeriesLegend(
                label: l10n.typeExpense,
                color: context.appColors.danger,
              ),
            ],
          ),
          const SizedBox(height: 12),
          StatisticsTrendChart(
            data: trend,
            chartType: _viewModel.trendChartType,
            currency: currency,
            selectedIndex: selectedIndex,
            onSelect: _viewModel.selectTrendIndex,
          ),
        ],
      );
    }

    return StatisticsSectionCard(
      key: const ValueKey('statistics-income-expense'),
      title: l10n.statisticsIncomeExpenseTitle,
      trailing: StatisticsChartTypeToggle<StatisticsTrendChartType>(
        selected: _viewModel.trendChartType,
        onChanged: _viewModel.setTrendChartType,
        options: [
          StatisticsChartTypeOption(
            value: StatisticsTrendChartType.line,
            icon: Icons.show_chart_rounded,
            label: l10n.statisticsChartLine,
          ),
          StatisticsChartTypeOption(
            value: StatisticsTrendChartType.bar,
            icon: Icons.bar_chart_rounded,
            label: l10n.statisticsChartBar,
          ),
        ],
      ),
      child: body,
    );
  }

  Widget _buildPieCard(LedgerRecordType type) {
    return StatisticsCategoryPieCard(
      key: ValueKey('statistics-pie-${type.name}'),
      type: type,
      amounts: _viewModel.monthCategoryAmounts(type),
      hiddenCategories: _viewModel.hiddenCategories(type),
      currency: _viewModel.currency,
      // 기본 통화는 12개월 기록까지 봐야 정해지므로, 둘 다 불러온 뒤에 그린다.
      isLoading: _viewModel.isMonthLoading || _viewModel.isLoading,
      onCategoryVisibilityChanged:
          (category, visible) =>
              _viewModel.setCategoryVisible(type, category, visible: visible),
    );
  }

  Widget _buildCategoryTrendCard(LedgerRecordType type) {
    return StatisticsCategoryTrendCard(
      key: ValueKey('statistics-trend-${type.name}'),
      type: type,
      trend: _viewModel.categoryTrend(type),
      categories: _viewModel.categoriesInRange(type),
      currency: _viewModel.currency,
      selectedIndex: _viewModel.selectedCategoryIndex(type),
      isLoading: _viewModel.isLoading,
      onSelect: (index) => _viewModel.selectCategoryIndex(type, index),
    );
  }
}

/// 한 달 단위(월간 통계)와 12개월 단위(최근 12개월 추이) 영역을 나누는 섹션 제목.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            height: 28 / 20,
            fontWeight: FontWeight.w700,
            color: context.appColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SeriesLegend extends StatelessWidget {
  const _SeriesLegend({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            height: 16 / 12,
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// 기록에 통화가 2개 이상 섞여 있을 때만 노출되는 통화 선택 칩.
class _CurrencyChips extends StatelessWidget {
  const _CurrencyChips({
    required this.currencies,
    required this.selected,
    required this.onSelected,
  });

  final List<CurrencyCode> currencies;
  final CurrencyCode selected;
  final ValueChanged<CurrencyCode> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final currency in currencies)
          Semantics(
            button: true,
            selected: currency == selected,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onSelected(currency),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      currency == selected
                          ? colors.primary.withValues(alpha: isDark ? 0.2 : 0.1)
                          : colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        currency == selected ? colors.primary : colors.border,
                  ),
                ),
                child: Text(
                  currency.isoCode,
                  style: TextStyle(
                    fontSize: 13,
                    height: 18 / 13,
                    fontWeight: FontWeight.w600,
                    color:
                        currency == selected
                            ? colors.primary
                            : colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
