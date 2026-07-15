import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/ui/ledger/view_models/ledger_tab_view_model.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_calendar.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_view_toggle.dart';

import 'ledger_income_summary_card.dart';
import 'add_ledger_record_screen.dart';
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
  final PageStorageKey<String> _calendarScrollKey = const PageStorageKey(
    'ledger-calendar-scroll',
  );
  final PageStorageKey<String> _listScrollKey = const PageStorageKey(
    'ledger-list-scroll',
  );

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

  String get _monthLabel => '${_currentMonth.year}년 ${_currentMonth.month}월';

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
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${date.month}월 ${date.day}일 (${weekdays[date.weekday - 1]})';
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
      locale: const Locale('ko', 'KR'),
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
    return isLandscape ? _buildCalendarTabLandscape() : _buildCalendarTabPortrait();
  }

  Widget _buildCalendarTabPortrait() {
    return Column(
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
        Expanded(
          child: SelectedDateLedgerSection(
            key: _calendarScrollKey,
            selectedDate: _selectedDate,
            items: _selectedDateItems,
            isLoading: _viewModel.isLoading,
            errorMessage: _viewModel.errorMessage,
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
            errorMessage: _viewModel.errorMessage,
            selectedDateLabelBuilder: _selectedDateLabel,
            onItemTap: _handleLedgerItemTap,
          ),
        ),
      ],
    );
  }

  Widget _buildListTab() {
    return ListView(
      key: _listScrollKey,
      padding: EdgeInsets.zero,
      children: [
        ..._buildCommonSection(),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LedgerMonthlyRecordSection(
            title: '수입',
            emptyMessage: '이번 달 수입 내역이 없어요',
            totalLabel: '총 수입 합계',
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
            title: '지출',
            emptyMessage: '이번 달 지출 내역이 없어요',
            totalLabel: '총 지출 합계',
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
              child: LedgerTopNavigationBar(
                selectedView: _selectedView,
                onChanged: (view) => setState(() => _selectedView = view),
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
