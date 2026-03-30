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

  String _currencyText(int amount) {
    final sign = amount < 0 ? '-' : '';
    final reversed = amount.abs().toString().split('').reversed.toList();
    final buffer = StringBuffer();
    for (var i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(reversed[i]);
    }
    return '$sign${buffer.toString().split('').reversed.join()}원';
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

  List<Widget> _buildCommonSection() {
    return [
      LedgerMonthSelector(
        monthLabel: _monthLabel,
        onPreviousTap: () => _changeMonth(-1),
        onNextTap: () => _changeMonth(1),
      ),
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: LedgerIncomeSummaryCard(
          incomeText: _currencyText(_viewModel.monthlyIncomeTotal),
          expenseText: _currencyText(_viewModel.monthlyExpenseTotal),
          savableText: _currencyText(_viewModel.monthlySavableTotal),
        ),
      ),
    ];
  }

  Widget _buildCalendarTab() {
    return ListView(
      key: _calendarScrollKey,
      padding: EdgeInsets.zero,
      children: [
        ..._buildCommonSection(),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LedgerCalendar(
            displayedMonth: _currentMonth,
            selectedDate: _selectedDate,
            dailyIncomeTotalsByDate: _viewModel.dailyIncomeTotalsByDate,
            dailyExpenseTotalsByDate: _viewModel.dailyExpenseTotalsByDate,
            onDateTap: (date) {
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
            },
          ),
        ),
        SelectedDateLedgerSection(
          selectedDate: _selectedDate,
          items: _selectedDateItems,
          isLoading: _viewModel.isLoading,
          errorMessage: _viewModel.errorMessage,
          selectedDateLabelBuilder: _selectedDateLabel,
          onItemTap: (item) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => LedgerRecordDetailScreen(entry: item),
              ),
            );
          },
        ),
        const SizedBox(height: 80),
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
        color: AppColors.background,
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
