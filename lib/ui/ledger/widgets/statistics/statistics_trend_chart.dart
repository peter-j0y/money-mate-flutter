import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:money_mate/data/model/entities/currency.dart';
import 'package:money_mate/data/model/entities/statistics_preferences.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/ledger/view_models/ledger_statistics_view_model.dart';

import 'statistics_month_chart.dart';

/// 월별 수입·지출 추이를 꺾은선 또는 묶음 막대로 그린다.
/// 달을 탭하거나 가로로 훑으면 [onSelect]로 선택한 달의 인덱스를 알린다.
class StatisticsTrendChart extends StatelessWidget {
  const StatisticsTrendChart({
    super.key,
    required this.data,
    required this.chartType,
    required this.currency,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<MonthlyIncomeExpense> data;
  final StatisticsTrendChartType chartType;
  final CurrencyCode currency;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return StatisticsMonthChart(
      months: [for (final item in data) item.month],
      maxValue: data.fold<int>(
        0,
        (max, item) => math.max(max, math.max(item.income, item.expense)),
      ),
      currency: currency,
      selectedIndex: selectedIndex,
      onSelect: onSelect,
      painterBuilder:
          (frame) => _TrendChartPainter(
            frame: frame,
            data: data,
            chartType: chartType,
            incomeColor: colors.primary,
            expenseColor: colors.danger,
            dotFillColor: colors.surface,
          ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  _TrendChartPainter({
    required this.frame,
    required this.data,
    required this.chartType,
    required this.incomeColor,
    required this.expenseColor,
    required this.dotFillColor,
  });

  final StatisticsMonthChartFrame frame;
  final List<MonthlyIncomeExpense> data;
  final StatisticsTrendChartType chartType;
  final Color incomeColor;
  final Color expenseColor;
  final Color dotFillColor;

  @override
  void paint(Canvas canvas, Size size) {
    frame.paintBackground(canvas);
    if (chartType == StatisticsTrendChartType.line) {
      _paintLine(canvas, [for (final item in data) item.income], incomeColor);
      _paintLine(canvas, [for (final item in data) item.expense], expenseColor);
    } else {
      _paintBars(canvas);
    }
    frame.paintMonthLabels(canvas);
  }

  void _paintLine(Canvas canvas, List<int> values, Color color) {
    final points = [
      for (var i = 0; i < values.length; i++)
        Offset(frame.centerX(i), frame.y(values[i])),
    ];
    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
    }

    for (var i = 0; i < points.length; i++) {
      final radius = i == frame.selectedIndex ? 4.5 : 3.0;
      canvas.drawCircle(points[i], radius, Paint()..color = dotFillColor);
      canvas.drawCircle(
        points[i],
        radius,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _paintBars(Canvas canvas) {
    final barWidth = math.min(frame.slotWidth * 0.3, 12.0);
    const gap = 2.0;
    for (var i = 0; i < data.length; i++) {
      final centerX = frame.centerX(i);
      _paintBar(
        canvas,
        left: centerX - gap / 2 - barWidth,
        width: barWidth,
        value: data[i].income,
        color: incomeColor,
      );
      _paintBar(
        canvas,
        left: centerX + gap / 2,
        width: barWidth,
        value: data[i].expense,
        color: expenseColor,
      );
    }
  }

  void _paintBar(
    Canvas canvas, {
    required double left,
    required double width,
    required int value,
    required Color color,
  }) {
    if (value <= 0) return;
    final rect = Rect.fromLTRB(
      left,
      frame.y(value),
      left + width,
      frame.plotRect.bottom,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      ),
      Paint()..color = color,
    );
  }

  // 데이터·선택·테마가 바뀔 때마다 새 painter가 만들어지고 그리기 비용이 작아 항상 다시 그린다.
  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) => true;
}
