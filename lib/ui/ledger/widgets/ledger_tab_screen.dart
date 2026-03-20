import 'package:flutter/material.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_calendar.dart';
import 'package:money_mate/ui/core/ledger_view_toggle.dart';
import 'package:money_mate/ui/core/tab_header_section.dart';

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
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;
  LedgerViewType _selectedView = LedgerViewType.calendar;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _currentMonth = DateTime(_selectedDate!.year, _selectedDate!.month);
  }

  @override
  void didUpdateWidget(covariant LedgerTabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != null && widget.selectedDate != oldWidget.selectedDate) {
      _selectedDate = widget.selectedDate;
      _currentMonth = DateTime(widget.selectedDate!.year, widget.selectedDate!.month);
    }
  }

  String get _monthLabel => '${_currentMonth.year}년 ${_currentMonth.month}월';

  void _changeMonth(int monthDelta) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + monthDelta,
      );
    });
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: LedgerIncomeSummaryCard(),
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
                    _currentMonth = DateTime(date.year, date.month);
                  });
                  widget.onSelectedDateChanged?.call(date);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
