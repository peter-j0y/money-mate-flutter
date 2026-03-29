import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class LedgerCalendar extends StatelessWidget {
  const LedgerCalendar({
    super.key,
    required this.displayedMonth,
    this.selectedDate,
    this.dailyIncomeTotalsByDate = const {},
    this.dailyExpenseTotalsByDate = const {},
    this.onDateTap,
  });

  final DateTime displayedMonth;
  final DateTime? selectedDate;
  final Map<DateTime, int> dailyIncomeTotalsByDate;
  final Map<DateTime, int> dailyExpenseTotalsByDate;
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
    final lastDayOfMonth = DateTime(
      displayedMonth.year,
      displayedMonth.month + 1,
      0,
    );
    final firstVisibleDay = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday % 7),
    );
    final lastVisibleDay = lastDayOfMonth.add(
      Duration(days: 6 - (lastDayOfMonth.weekday % 7)),
    );
    final totalDays = lastVisibleDay.difference(firstVisibleDay).inDays + 1;
    final days = List.generate(
      totalDays,
      (index) => DateTime(
        firstVisibleDay.year,
        firstVisibleDay.month,
        firstVisibleDay.day + index,
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 74,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              final normalizedDay = DateTime(day.year, day.month, day.day);
              final isCurrentMonth = day.month == displayedMonth.month;
              final isSelected = _isSameDate(day, selectedDate);
              final isToday = _isSameDate(day, today);
              final shouldShowTodayMarker =
                  isToday && !isSelected && !isTodaySelected;
              final incomeTotal = dailyIncomeTotalsByDate[normalizedDay] ?? 0;
              final expenseTotal = dailyExpenseTotalsByDate[normalizedDay] ?? 0;

              return InkWell(
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
                  padding: EdgeInsets.only(top: 4),
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
                      const SizedBox(height: 2),
                      if (isCurrentMonth && incomeTotal > 0)
                        _AdaptiveCalendarAmountText(
                          text: '+${_wonText(incomeTotal)}',
                          color: AppColors.primary,
                        ),
                      if (isCurrentMonth && expenseTotal > 0)
                        _AdaptiveCalendarAmountText(
                          text: '-${_wonText(expenseTotal)}',
                          color: AppColors.danger,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
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
  const _WeekdayLabel({required this.text, this.color = AppColors.textSecondary});

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
