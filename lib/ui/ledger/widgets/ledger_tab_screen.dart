import 'package:flutter/material.dart';
import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_view_toggle.dart';
import 'package:money_mate/ui/core/tab_header_section.dart';
import 'package:money_mate/ui/ledger/view_models/ledger_tab_view_model.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_calendar.dart';

import 'ledger_income_summary_card.dart';
import 'ledger_month_selector.dart';

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
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + monthDelta,
      );
    });
    _viewModel.loadMonth(_currentMonth);
  }

  List<LedgerEntry> get _selectedDateItems {
    final selectedDate = _selectedDate;
    if (selectedDate == null) {
      return const [];
    }
    return _viewModel.recordsForDate(selectedDate);
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  String _selectedDateLabel(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${date.month}월 ${date.day}일 (${weekdays[date.weekday - 1]})';
  }

  String _currencyText(int amount) {
    final reversed = amount.toString().split('').reversed.toList();
    final buffer = StringBuffer();
    for (var i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(reversed[i]);
    }
    return '${buffer.toString().split('').reversed.join()}원';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 140),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: TabHeaderSection(title: '가계부'),
          ),
          LedgerMonthSelector(
            monthLabel: _monthLabel,
            onPreviousTap: () => _changeMonth(-1),
            onNextTap: () => _changeMonth(1),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LedgerViewToggle(
              selectedView: _selectedView,
              onChanged: (view) => setState(() => _selectedView = view),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: LedgerIncomeSummaryCard(
              incomeText: _currencyText(_viewModel.monthlyIncomeTotal),
              expenseText: _currencyText(_viewModel.monthlyExpenseTotal),
              savableText: _currencyText(_viewModel.monthlySavableTotal),
            ),
          ),
          if (_selectedView == LedgerViewType.calendar) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LedgerCalendar(
                displayedMonth: _currentMonth,
                selectedDate: _selectedDate,
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SelectedDateLedgerSection(
                selectedDate: _selectedDate,
                items: _selectedDateItems,
                isLoading: _viewModel.isLoading,
                errorMessage: _viewModel.errorMessage,
                selectedDateLabelBuilder: _selectedDateLabel,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SelectedDateLedgerSection extends StatelessWidget {
  const _SelectedDateLedgerSection({
    required this.selectedDate,
    required this.items,
    required this.isLoading,
    required this.errorMessage,
    required this.selectedDateLabelBuilder,
  });

  final DateTime? selectedDate;
  final List<LedgerEntry> items;
  final bool isLoading;
  final String? errorMessage;
  final String Function(DateTime) selectedDateLabelBuilder;

  @override
  Widget build(BuildContext context) {
    if (selectedDate == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                selectedDateLabelBuilder(selectedDate!),
                style: const TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${items.length}건',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFEF4444),
                ),
              ),
            )
          else if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '해당 날짜에 등록된 내역이 없어요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DailyLedgerListTile(item: item),
              ),
            ),
        ],
      ),
    );
  }
}

class _DailyLedgerListTile extends StatelessWidget {
  const _DailyLedgerListTile({required this.item});

  final LedgerEntry item;

  @override
  Widget build(BuildContext context) {
    final isIncome = item.type == LedgerRecordType.income;
    final amountColor =
        isIncome ? const Color(0xFF137FEC) : const Color(0xFFF43F5E);
    final amountPrefix = isIncome ? '+' : '-';
    final style = _LedgerCategoryStyle.from(item);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: style.iconBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(style.icon, color: style.iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.memo?.trim().isNotEmpty == true
                      ? item.memo!.trim()
                      : item.category,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 22 / 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.category} · ${isIncome ? '수입' : '지출'}',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 18 / 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$amountPrefix${_wonText(item.amount)}',
            style: TextStyle(
              fontSize: 15,
              height: 22 / 15,
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  String _wonText(int amount) {
    final reversed = amount.toString().split('').reversed.toList();
    final buffer = StringBuffer();
    for (var i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(reversed[i]);
    }
    return '${buffer.toString().split('').reversed.join()}원';
  }
}

class _LedgerCategoryStyle {
  const _LedgerCategoryStyle({
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;

  static _LedgerCategoryStyle from(LedgerEntry entry) {
    switch (entry.category) {
      case '월급':
        return const _LedgerCategoryStyle(
          icon: Icons.payments_outlined,
          iconBackgroundColor: Color(0xFFDCFCE7),
          iconColor: Color(0xFF22C55E),
        );
      case '부업':
        return const _LedgerCategoryStyle(
          icon: Icons.work_outline_rounded,
          iconBackgroundColor: Color(0xFFDBEAFE),
          iconColor: Color(0xFF137FEC),
        );
      case '보너스':
        return const _LedgerCategoryStyle(
          icon: Icons.card_giftcard_rounded,
          iconBackgroundColor: Color(0xFFFFEDD5),
          iconColor: Color(0xFFF97316),
        );
      case '용돈':
        return const _LedgerCategoryStyle(
          icon: Icons.savings_outlined,
          iconBackgroundColor: Color(0xFFFCE7F3),
          iconColor: Color(0xFFEC4899),
        );
      case '이자/배당':
        return const _LedgerCategoryStyle(
          icon: Icons.trending_up_rounded,
          iconBackgroundColor: Color(0xFFF3E8FF),
          iconColor: Color(0xFFA855F7),
        );
      case '식비':
        return const _LedgerCategoryStyle(
          icon: Icons.restaurant_rounded,
          iconBackgroundColor: Color(0xFFFFEDD5),
          iconColor: Color(0xFFF97316),
        );
      case '교통':
        return const _LedgerCategoryStyle(
          icon: Icons.directions_bus_filled_rounded,
          iconBackgroundColor: Color(0xFFDBEAFE),
          iconColor: Color(0xFF137FEC),
        );
      case '쇼핑':
        return const _LedgerCategoryStyle(
          icon: Icons.shopping_bag_outlined,
          iconBackgroundColor: Color(0xFFFCE7F3),
          iconColor: Color(0xFFEC4899),
        );
      case '문화/취미':
        return const _LedgerCategoryStyle(
          icon: Icons.theaters_outlined,
          iconBackgroundColor: Color(0xFFF3E8FF),
          iconColor: Color(0xFFA855F7),
        );
      case '주거/통신':
        return const _LedgerCategoryStyle(
          icon: Icons.home_outlined,
          iconBackgroundColor: Color(0xFFDCFCE7),
          iconColor: Color(0xFF22C55E),
        );
      case '의료/건강':
        return const _LedgerCategoryStyle(
          icon: Icons.medical_services_outlined,
          iconBackgroundColor: Color(0xFFCCFBF1),
          iconColor: Color(0xFF14B8A6),
        );
      case '교육':
        return const _LedgerCategoryStyle(
          icon: Icons.school_outlined,
          iconBackgroundColor: Color(0xFFFEF9C3),
          iconColor: Color(0xFFD97706),
        );
      default:
        final isIncome = entry.type == LedgerRecordType.income;
        return _LedgerCategoryStyle(
          icon:
              isIncome ? Icons.payments_outlined : Icons.receipt_long_outlined,
          iconBackgroundColor: const Color(0xFFF1F5F9),
          iconColor: const Color(0xFF94A3B8),
        );
    }
  }
}
