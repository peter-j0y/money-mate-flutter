import 'package:flutter/material.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/ui/ledger/view_models/ledger_tab_view_model.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_calendar.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_view_toggle.dart';

import 'ledger_income_summary_card.dart';
import 'add_ledger_record_screen.dart';
import 'favorite_ledger_records_screen.dart';
import 'ledger_month_selector.dart';
import 'ledger_monthly_record_section.dart';
import 'ledger_record_detail_screen.dart';
import 'ledger_top_navigation_bar.dart';
import 'selected_date_ledger_section.dart';

class LedgerTabScreen extends StatefulWidget {
  const LedgerTabScreen({
    super.key,
    this.selectedDate,
    this.onSelectedDateChanged,
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onSelectedDateChanged;

  @override
  State<LedgerTabScreen> createState() => _LedgerTabScreenState();
}

class _LedgerTabScreenState extends State<LedgerTabScreen> {
  static const double _calendarSwipeVelocityThreshold = 200;

  final LedgerTabViewModel _viewModel = LedgerTabViewModel();
  final ValueKey<String> _calendarScrollKey = const ValueKey(
    'ledger-calendar-scroll',
  );
  final ValueKey<String> _listScrollKey = const ValueKey('ledger-list-scroll');

  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;
  LedgerViewType _selectedView = LedgerViewType.calendar;
  bool _isCalendarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _currentMonth = DateTime(_selectedDate!.year, _selectedDate!.month);

    _viewModel.addListener(_onViewModelChanged);
    _viewModel.loadMonth(_currentMonth);
  }

  @override
  void didUpdateWidget(covariant LedgerTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != null &&
        widget.selectedDate != oldWidget.selectedDate) {
      _selectedDate = widget.selectedDate;
      final updatedMonth = DateTime(
        widget.selectedDate!.year,
        widget.selectedDate!.month,
      );
      final isMonthChanged = !_isSameMonth(_currentMonth, updatedMonth);
      _currentMonth = updatedMonth;

      if (isMonthChanged) {
        _viewModel.loadMonth(_currentMonth);
      }
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  String get _monthLabel => AppLocalizations.of(
    context,
  )!.yearMonth(_currentMonth.year, _currentMonth.month);

  void _changeMonth(int monthDelta) {
    late final DateTime nextMonth;
    late final DateTime firstDayOfNextMonth;

    setState(() {
      nextMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + monthDelta,
      );
      _currentMonth = nextMonth;
      firstDayOfNextMonth = DateTime(nextMonth.year, nextMonth.month, 1);
      _selectedDate = firstDayOfNextMonth;
    });

    widget.onSelectedDateChanged?.call(firstDayOfNextMonth);
    _viewModel.loadMonth(_currentMonth);
  }

  List<LedgerEntry> get _selectedDateItems {
    final selectedDate = _selectedDate;
    if (selectedDate == null) {
      return const [];
    }
    return _viewModel.recordsForDate(selectedDate);
  }

  List<LedgerEntry> get _monthlyIncomeItems {
    final items =
        _viewModel.monthlyRecords
            .where((record) => record.type == LedgerRecordType.income)
            .toList();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  List<LedgerEntry> get _monthlyExpenseItems {
    final items =
        _viewModel.monthlyRecords
            .where((record) => record.type == LedgerRecordType.expense)
            .toList();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  String _selectedDateLabel(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final weekdays = weekdayShortLabels(l10n);
    return l10n.monthDayWithWeekday(
      date.month,
      date.day,
      weekdays[date.weekday - 1],
    );
  }

  Future<void> _openAddLedgerRecordScreen(LedgerRecordType type) async {
    final didSave = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder:
            (context) => AddLedgerRecordScreen(
              initialDate: _selectedDate ?? DateTime.now(),
              initialType: type,
            ),
      ),
    );

    if (didSave == true) {
      _viewModel.loadMonth(_currentMonth);
    }
  }

  Future<void> _openMonthPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _currentMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: Localizations.localeOf(context),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked == null) {
      return;
    }

    final pickedMonth = DateTime(picked.year, picked.month);
    final isMonthChanged = !_isSameMonth(_currentMonth, pickedMonth);

    setState(() {
      _currentMonth = pickedMonth;
      _selectedDate = picked;
    });

    widget.onSelectedDateChanged?.call(picked);

    if (isMonthChanged) {
      _viewModel.loadMonth(_currentMonth);
    }
  }

  List<Widget> _buildCommonSection() {
    return [
      LedgerMonthSelector(
        monthLabel: _monthLabel,
        onPreviousTap: () => _changeMonth(-1),
        onNextTap: () => _changeMonth(1),
        onLabelTap: _openMonthPicker,
      ),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: LedgerIncomeSummaryCard(
          incomeText: _viewModel.monthlyIncomeTotal.toCommaWon(),
          expenseText: _viewModel.monthlyExpenseTotal.toCommaWon(),
          savableText: _viewModel.monthlySavableTotal.toCommaWon(),
        ),
      ),
    ];
  }

  void _handleCalendarMonthChanged(DateTime month) {
    if (_isSameMonth(_currentMonth, month)) {
      return;
    }
    setState(() {
      _currentMonth = month;
      _selectedDate = DateTime(month.year, month.month, 1);
    });
    widget.onSelectedDateChanged?.call(_selectedDate!);
    _viewModel.loadMonth(_currentMonth);
  }

  void _handleCalendarDateTap(DateTime date) {
    setState(() {
      _selectedDate = date;
    });

    final selectedMonth = DateTime(date.year, date.month);
    if (!_isSameMonth(_currentMonth, selectedMonth)) {
      setState(() {
        _currentMonth = selectedMonth;
      });
      _viewModel.loadMonth(_currentMonth);
    }

    widget.onSelectedDateChanged?.call(date);
  }

  void _openFavoritesScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const FavoriteLedgerRecordsScreen(),
      ),
    );
  }

  void _handleLedgerItemTap(LedgerEntry item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => LedgerRecordDetailScreen(entry: item),
      ),
    );
  }

  Widget _buildCalendarTab() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return isLandscape
        ? _buildCalendarTabLandscape()
        : _buildCalendarTabPortrait();
  }

  Widget _buildCalendarTabPortrait() {
    // 달력 높이는 고정이라 글씨 크기가 커지거나 화면 세로가 짧은 기기에서는
    // 헤더+달력만으로 화면을 다 채워 하단 리스트가 가려질 수 있다.
    // CustomScrollView로 감싸고 리스트를 내용 높이만큼만 차지하게 해서,
    // 그런 경우에도 전체를 스크롤해 하단 리스트까지 도달할 수 있게 한다.
    return CustomScrollView(
      key: _calendarScrollKey,
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              ..._buildCommonSection(),
              const SizedBox(height: 12),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity.abs() < _calendarSwipeVelocityThreshold) {
                    return;
                  }
                  setState(() {
                    _isCalendarCollapsed = velocity < 0;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(end: _isCalendarCollapsed ? 1 : 0),
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOutCubic,
                    builder: (context, collapseProgress, _) {
                      return LedgerCalendar(
                        displayedMonth: _currentMonth,
                        selectedDate: _selectedDate,
                        collapseProgress: collapseProgress,
                        incomeTotalForDate: _viewModel.incomeTotalForDate,
                        expenseTotalForDate: _viewModel.expenseTotalForDate,
                        onMonthChanged: _handleCalendarMonthChanged,
                        onDateTap: _handleCalendarDateTap,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: SelectedDateLedgerSection(
            selectedDate: _selectedDate,
            items: _selectedDateItems,
            isLoading: _viewModel.isLoading,
            errorMessage: _viewModel.errorMessage(
              AppLocalizations.of(context)!,
            ),
            selectedDateLabelBuilder: _selectedDateLabel,
            onItemTap: _handleLedgerItemTap,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarTabLandscape() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                ..._buildCommonSection(),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LedgerCalendar(
                    displayedMonth: _currentMonth,
                    selectedDate: _selectedDate,
                    incomeTotalForDate: _viewModel.incomeTotalForDate,
                    expenseTotalForDate: _viewModel.expenseTotalForDate,
                    onMonthChanged: _handleCalendarMonthChanged,
                    onDateTap: _handleCalendarDateTap,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: SelectedDateLedgerSection(
            key: _calendarScrollKey,
            selectedDate: _selectedDate,
            items: _selectedDateItems,
            isLoading: _viewModel.isLoading,
            errorMessage: _viewModel.errorMessage(
              AppLocalizations.of(context)!,
            ),
            selectedDateLabelBuilder: _selectedDateLabel,
            onItemTap: _handleLedgerItemTap,
          ),
        ),
      ],
    );
  }

  Widget _buildListTab() {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      key: _listScrollKey,
      padding: EdgeInsets.zero,
      children: [
        ..._buildCommonSection(),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LedgerMonthlyRecordSection(
            title: l10n.typeIncome,
            emptyMessage: l10n.emptyMonthlyIncome,
            totalLabel: l10n.totalIncomeLabel,
            items: _monthlyIncomeItems,
            onItemTap: (item) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => LedgerRecordDetailScreen(entry: item),
                ),
              );
            },
            onAddTap: () => _openAddLedgerRecordScreen(LedgerRecordType.income),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LedgerMonthlyRecordSection(
            title: l10n.typeExpense,
            emptyMessage: l10n.emptyMonthlyExpense,
            totalLabel: l10n.totalExpenseLabel,
            items: _monthlyExpenseItems,
            onItemTap: (item) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => LedgerRecordDetailScreen(entry: item),
                ),
              );
            },
            onAddTap:
                () => _openAddLedgerRecordScreen(LedgerRecordType.expense),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: context.appColors.background,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: LedgerTopNavigationBar(
                      selectedView: _selectedView,
                      onChanged: (view) => setState(() => _selectedView = view),
                    ),
                  ),
                  IconButton(
                    onPressed: _openFavoritesScreen,
                    icon: Icon(
                      Icons.bookmark_border_rounded,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedView == LedgerViewType.calendar ? 0 : 1,
                children: [_buildCalendarTab(), _buildListTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
