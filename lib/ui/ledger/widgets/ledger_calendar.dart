import 'package:flutter/material.dart';

class LedgerCalendar extends StatelessWidget {
  const LedgerCalendar({
    super.key,
    required this.displayedMonth,
    this.selectedDate,
    this.onDateTap,
  });

  final DateTime displayedMonth;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateTap;

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(displayedMonth.year, displayedMonth.month, 1);
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
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              _WeekdayLabel(text: '일', color: Color(0xFFEF4444)),
              _WeekdayLabel(text: '월'),
              _WeekdayLabel(text: '화'),
              _WeekdayLabel(text: '수'),
              _WeekdayLabel(text: '목'),
              _WeekdayLabel(text: '금'),
              _WeekdayLabel(text: '토', color: Color(0xFF3B82F6)),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 56,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              final isCurrentMonth = day.month == displayedMonth.month;
              final isSelected = _isSameDate(day, selectedDate);

              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onDateTap?.call(day),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color.fromRGBO(19, 127, 236, 0.05)
                        : Colors.transparent,
                    border: Border(
                      top: BorderSide(
                        color: isSelected ? const Color(0xFF137FEC) : const Color(0xFFF8FAFC),
                        width: 1,
                      ),
                    ),
                  ),
                  padding: EdgeInsets.only(top: 4),
                  child: isSelected
                      ? Column(
                          children: [
                            Text(
                              '${day.day}',
                              style: const TextStyle(
                                fontSize: 14,
                                height: 20 / 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF137FEC),
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        )
                      : Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 14,
                              height: 20 / 14,
                              fontWeight: FontWeight.w500,
                              color: _dayTextColor(
                                day: day,
                                isCurrentMonth: isCurrentMonth,
                              ),
                            ),
                          ),
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

  Color _dayTextColor({
    required DateTime day,
    required bool isCurrentMonth,
  }) {
    if (isCurrentMonth && day.weekday == DateTime.sunday) {
      return const Color(0xFFEF4444);
    }
    if (isCurrentMonth && day.weekday == DateTime.saturday) {
      return const Color(0xFF3B82F6);
    }
    return isCurrentMonth ? const Color(0xFF0F172A) : const Color(0xFF94A3B8);
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel({
    required this.text,
    this.color = const Color(0xFF64748B),
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
