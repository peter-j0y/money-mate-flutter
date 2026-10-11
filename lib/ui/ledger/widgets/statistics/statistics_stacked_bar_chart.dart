import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:money_mate/data/model/entities/currency.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

import 'statistics_month_chart.dart';

/// 막대 하나를 이루는 조각(카테고리 하나).
class StatisticsStackSegment {
  const StatisticsStackSegment({required this.amount, required this.color});

  final int amount;
  final Color color;
}

/// 월별 세로 누적 막대. 막대 높이는 조각 금액의 합이고,
/// [stacks]의 각 목록은 아래에서 위로 쌓는 순서다.
class StatisticsStackedBarChart extends StatelessWidget {
  const StatisticsStackedBarChart({
    super.key,
    required this.months,
    required this.stacks,
    required this.currency,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<DateTime> months;
  final List<List<StatisticsStackSegment>> stacks;
  final CurrencyCode currency;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final maxTotal = stacks.fold<int>(
      0,
      (max, stack) => math.max(
        max,
        stack.fold<int>(0, (sum, segment) => sum + segment.amount),
      ),
    );
    final separatorColor = context.appColors.surface;

    return StatisticsMonthChart(
      months: months,
      maxValue: maxTotal,
      currency: currency,
      selectedIndex: selectedIndex,
      onSelect: onSelect,
      painterBuilder:
          (frame) => _StackedBarPainter(
            frame: frame,
            stacks: stacks,
            separatorColor: separatorColor,
          ),
    );
  }
}

class _StackedBarPainter extends CustomPainter {
  _StackedBarPainter({
    required this.frame,
    required this.stacks,
    required this.separatorColor,
  });

  final StatisticsMonthChartFrame frame;
  final List<List<StatisticsStackSegment>> stacks;
  final Color separatorColor;

  @override
  void paint(Canvas canvas, Size size) {
    frame.paintBackground(canvas);
    final barWidth = math.min(frame.slotWidth * 0.55, 22.0);
    for (var i = 0; i < stacks.length; i++) {
      _paintStack(canvas, stacks[i], frame.centerX(i), barWidth);
    }
    frame.paintMonthLabels(canvas);
  }

  void _paintStack(
    Canvas canvas,
    List<StatisticsStackSegment> stack,
    double centerX,
    double barWidth,
  ) {
    final segments = stack.where((segment) => segment.amount > 0).toList();
    if (segments.isEmpty) return;

    final left = centerX - barWidth / 2;
    final right = centerX + barWidth / 2;
    final total = segments.fold<int>(0, (sum, segment) => sum + segment.amount);

    // 막대 전체의 위쪽 모서리만 둥글게 보이도록 막대 모양으로 잘라낸 뒤 조각을 채운다.
    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(left, frame.y(total), right, frame.plotRect.bottom),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      ),
    );
    var cumulative = 0;
    final separator =
        Paint()
          ..color = separatorColor
          ..strokeWidth = 1;
    for (var i = 0; i < segments.length; i++) {
      final bottom = frame.y(cumulative);
      cumulative += segments[i].amount;
      final top = frame.y(cumulative);
      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        Paint()..color = segments[i].color,
      );
      if (i > 0) {
        canvas.drawLine(Offset(left, bottom), Offset(right, bottom), separator);
      }
    }
    canvas.restore();
  }

  // 데이터·선택·테마가 바뀔 때마다 새 painter가 만들어지고 그리기 비용이 작아 항상 다시 그린다.
  @override
  bool shouldRepaint(covariant _StackedBarPainter oldDelegate) => true;
}
