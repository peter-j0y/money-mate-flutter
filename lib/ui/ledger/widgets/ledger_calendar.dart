import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class LedgerCalendar extends StatefulWidget {
  const LedgerCalendar({
    super.key,
    required this.displayedMonth,
    this.selectedDate,
    this.incomeTotalForDate,
    this.expenseTotalForDate,
    this.collapseProgress = 0,
    this.onMonthChanged,
    this.onDateTap,
  });

  static const int weekCount = 6;
  static const double containerVerticalPadding = 12;
  static const double weekdayLabelHeight = 16;
  static const double weekdayToGridSpacing = 8;
  static const double expandedRowHeight = 60;
  static const double collapsedRowHeight = 38;

  static double get expandedHeight =>
      (containerVerticalPadding * 2) +
      weekdayLabelHeight +
      weekdayToGridSpacing +
      (expandedRowHeight * weekCount);

  static double get collapsedHeight =>
      (containerVerticalPadding * 2) +
      weekdayLabelHeight +
      weekdayToGridSpacing +
      (collapsedRowHeight * weekCount);

  final DateTime displayedMonth;
  final DateTime? selectedDate;
  final int Function(DateTime date)? incomeTotalForDate;
  final int Function(DateTime date)? expenseTotalForDate;
  final double collapseProgress;
  final ValueChanged<DateTime>? onMonthChanged;
  final ValueChanged<DateTime>? onDateTap;

  @override
  State<LedgerCalendar> createState() => _LedgerCalendarState();
}

class _LedgerCalendarState extends State<LedgerCalendar> {
  static const int _centerPage = 10000;
  late final PageController _pageController;
  int _pendingMonthOffset = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _centerPage);
  }

  @override
  void didUpdateWidget(covariant LedgerCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSameMonth(oldWidget.displayedMonth, widget.displayedMonth) &&
        _pageController.hasClients) {
      _pageController.jumpToPage(_centerPage);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collapsedProgress = widget.collapseProgress.clamp(0.0, 1.0);
    final rowHeight =
        lerpDouble(
          LedgerCalendar.expandedRowHeight,
          LedgerCalendar.collapsedRowHeight,
          collapsedProgress,
        )!;
    final amountOpacity = (1 - collapsedProgress * 1.4).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        0,
        LedgerCalendar.containerVerticalPadding,
        0,
        LedgerCalendar.containerVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              _WeekdayLabel(text: '일', color: AppColors.hexFFEF4444),
              _WeekdayLabel(text: '월'),
              _WeekdayLabel(text: '화'),
              _WeekdayLabel(text: '수'),
              _WeekdayLabel(text: '목'),
              _WeekdayLabel(text: '금'),
              _WeekdayLabel(text: '토', color: AppColors.hexFF3B82F6),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: rowHeight * LedgerCalendar.weekCount,
            child: NotificationListener<ScrollEndNotification>(
              onNotification: (_) {
                if (_pendingMonthOffset == 0) {
                  return false;
                }
                final nextMonth = DateTime(
                  widget.displayedMonth.year,
                  widget.displayedMonth.month + _pendingMonthOffset,
                );
                _pendingMonthOffset = 0;
                widget.onMonthChanged?.call(
                  DateTime(nextMonth.year, nextMonth.month),
                );
                return false;
              },
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  _pendingMonthOffset = index - _centerPage;
                },
                itemBuilder: (context, index) {
                  final monthOffset = index - _centerPage;
                  final month = DateTime(
                    widget.displayedMonth.year,
                    widget.displayedMonth.month + monthOffset,
                    1,
                  );
                  return _CalendarMonthGrid(
                    displayedMonth: month,
                    selectedDate: widget.selectedDate,
                    incomeTotalForDate: widget.incomeTotalForDate,
                    expenseTotalForDate: widget.expenseTotalForDate,
                    rowHeight: rowHeight,
                    amountOpacity: amountOpacity,
                    onDateTap: widget.onDateTap,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}

class _CalendarMonthGrid extends StatelessWidget {
  const _CalendarMonthGrid({
    required this.displayedMonth,
    required this.selectedDate,
    required this.incomeTotalForDate,
    required this.expenseTotalForDate,
    required this.rowHeight,
    required this.amountOpacity,
    required this.onDateTap,
  });

  final DateTime displayedMonth;
  final DateTime? selectedDate;
  final int Function(DateTime date)? incomeTotalForDate;
  final int Function(DateTime date)? expenseTotalForDate;
  final double rowHeight;
  final double amountOpacity;
  final ValueChanged<DateTime>? onDateTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isTodaySelected = _isSameDate(today, selectedDate);

    final firstDayOfMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month,
      1,
    );
    final firstVisibleDay = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday % 7),
    );
    final days = List.generate(
      42,
      (index) => DateTime(
        firstVisibleDay.year,
        firstVisibleDay.month,
        firstVisibleDay.day + index,
      ),
    );

    return Column(
      children: List.generate(6, (weekIndex) {
        final start = weekIndex * 7;
        final weekDays = days.sublist(start, start + 7);

        return SizedBox(
          height: rowHeight,
          child: Row(
            children: weekDays
                .map((day) {
                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  final isCurrentMonth = day.month == displayedMonth.month;
                  final isSelected = _isSameDate(day, selectedDate);
                  final isToday = _isSameDate(day, today);
                  final shouldShowTodayMarker =
                      isToday && !isSelected && !isTodaySelected;
                  final incomeTotal =
                      incomeTotalForDate?.call(normalizedDay) ?? 0;
                  final expenseTotal =
                      expenseTotalForDate?.call(normalizedDay) ?? 0;
                  final amountLineCount =
                      (isCurrentMonth && incomeTotal > 0 ? 1 : 0) +
                      (isCurrentMonth && expenseTotal > 0 ? 1 : 0);
                  const double dayNumberBlockHeight = 24;
                  const double amountTopSpacing = 2;
                  const double amountLineHeight = 14;
                  final requiredHeightForAmounts =
                      dayNumberBlockHeight +
                      (amountLineCount > 0
                          ? amountTopSpacing +
                              (amountLineHeight * amountLineCount)
                          : 0);
                  final canShowAmounts =
                      amountOpacity > 0 &&
                      rowHeight >= requiredHeightForAmounts;

                  return Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onDateTap?.call(day),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.rgba_19_127_236_005
                                  : AppColors.overlay,
                          border: Border(
                            top: BorderSide(
                              color:
                                  isSelected
                                      ? AppColors.primary
                                      : AppColors.white,
                              width: 1,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 20 / 14,
                                    fontWeight:
                                        isSelected || shouldShowTodayMarker
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                    color:
                                        isSelected
                                            ? AppColors.primary
                                            : _dayTextColor(
                                              day: day,
                                              isCurrentMonth: isCurrentMonth,
                                            ),
                                  ),
                                ),
                                if (shouldShowTodayMarker)
                                  const Positioned(
                                    top: -5,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: AppColors.hexFFFACC15,
                                        shape: BoxShape.circle,
                                      ),
                                      child: SizedBox(width: 5, height: 5),
                                    ),
                                  ),
                              ],
                            ),
                            if (canShowAmounts) ...[
                              const SizedBox(height: 2),
                              if (isCurrentMonth && incomeTotal > 0)
                                Opacity(
                                  opacity: amountOpacity,
                                  child: _AdaptiveCalendarAmountText(
                                    text: '+${_wonText(incomeTotal)}',
                                    color: AppColors.primary,
                                  ),
                                ),
                              if (isCurrentMonth && expenseTotal > 0)
                                Opacity(
                                  opacity: amountOpacity,
                                  child: _AdaptiveCalendarAmountText(
                                    text: '-${_wonText(expenseTotal)}',
                                    color: AppColors.danger,
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                })
                .toList(growable: false),
          ),
        );
      }),
    );
  }

  bool _isSameDate(DateTime a, DateTime? b) {
    if (b == null) {
      return false;
    }
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Color _dayTextColor({required DateTime day, required bool isCurrentMonth}) {
    if (isCurrentMonth && day.weekday == DateTime.sunday) {
      return AppColors.hexFFEF4444;
    }
    if (isCurrentMonth && day.weekday == DateTime.saturday) {
      return AppColors.hexFF3B82F6;
    }
    return isCurrentMonth ? AppColors.textPrimary : AppColors.textTertiary;
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
    return buffer.toString().split('').reversed.join();
  }
}

class _AdaptiveCalendarAmountText extends StatelessWidget {
  const _AdaptiveCalendarAmountText({required this.text, required this.color});

  final String text;
  final Color color;

  static const double _fontSize = 10;
  static const double _lineHeightRatio = 14 / 10;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _fontSize * _lineHeightRatio,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            fontSize: _fontSize,
            height: _lineHeightRatio,
            fontWeight: FontWeight.w400,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel({
    required this.text,
    this.color = AppColors.textSecondary,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            height: 16 / 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ),
    );
  }
}
