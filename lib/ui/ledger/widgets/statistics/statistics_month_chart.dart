import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat, Intl;
import 'package:money_mate/data/model/entities/currency.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

import 'statistics_chart_utils.dart';

/// X축이 월, Y축이 금액인 통계 그래프의 공통 틀.
/// 축·격자·선택 강조·월 라벨과 탭 선택을 처리하고, 데이터 계열은 [painterBuilder]가 그린다.
class StatisticsMonthChart extends StatelessWidget {
  const StatisticsMonthChart({
    super.key,
    required this.months,
    required this.maxValue,
    required this.currency,
    required this.selectedIndex,
    required this.onSelect,
    required this.painterBuilder,
    this.height = 200,
  });

  final List<DateTime> months;
  final int maxValue;
  final CurrencyCode currency;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;
  final CustomPainter Function(StatisticsMonthChartFrame frame) painterBuilder;
  final double height;

  static const int _gridDivisions = 4;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final axisMax = statisticsNiceAxisMax(maxValue, divisions: _gridDivisions);
    final monthFormat = DateFormat.MMM(Intl.getCurrentLocale());
    final labelStyle = TextStyle(
      fontSize: 10,
      height: 1.2,
      color: colors.textTertiary,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final frame = StatisticsMonthChartFrame(
          size: Size(constraints.maxWidth, height),
          axisMax: axisMax,
          yLabels: [
            for (var i = 0; i <= _gridDivisions; i++)
              statisticsCompactAmount(
                (axisMax * i / _gridDivisions).round(),
                currency,
              ),
          ],
          monthLabels: [for (final month in months) monthFormat.format(month)],
          selectedIndex: selectedIndex,
          gridColor: colors.border,
          highlightColor: colors.textTertiary.withValues(alpha: 0.1),
          labelStyle: labelStyle,
          selectedLabelStyle: labelStyle.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        );

        void select(Offset position) {
          final index = frame.indexAt(position.dx);
          if (index != null && index != selectedIndex) onSelect(index);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) => select(details.localPosition),
          onHorizontalDragUpdate: (details) => select(details.localPosition),
          child: CustomPaint(size: frame.size, painter: painterBuilder(frame)),
        );
      },
    );
  }
}

/// 그래프 영역의 좌표 계산과 공통 요소(격자, 선택 강조, 월 라벨) 그리기.
class StatisticsMonthChartFrame {
  StatisticsMonthChartFrame({
    required this.size,
    required this.axisMax,
    required this.yLabels,
    required this.monthLabels,
    required this.selectedIndex,
    required this.gridColor,
    required this.highlightColor,
    required this.labelStyle,
    required this.selectedLabelStyle,
  }) {
    var maxLabelWidth = 0.0;
    for (final label in yLabels) {
      maxLabelWidth = math.max(maxLabelWidth, _textPainter(label).width);
    }
    plotRect = Rect.fromLTRB(
      maxLabelWidth + 8,
      8,
      size.width,
      size.height - _bottomLabelHeight,
    );
  }

  static const double _bottomLabelHeight = 22;

  final Size size;
  final double axisMax;
  final List<String> yLabels;
  final List<String> monthLabels;
  final int? selectedIndex;
  final Color gridColor;
  final Color highlightColor;
  final TextStyle labelStyle;
  final TextStyle selectedLabelStyle;
  late final Rect plotRect;

  int get slotCount => monthLabels.length;

  double get slotWidth => slotCount == 0 ? 0 : plotRect.width / slotCount;

  double centerX(int index) => plotRect.left + slotWidth * (index + 0.5);

  double y(num value) => plotRect.bottom - (value / axisMax) * plotRect.height;

  int? indexAt(double dx) {
    if (slotCount == 0) return null;
    final index = ((dx - plotRect.left) / slotWidth).floor();
    return index.clamp(0, slotCount - 1);
  }

  /// 데이터 계열보다 먼저 그리는 격자·Y축 라벨·선택 강조.
  void paintBackground(Canvas canvas) {
    final gridPaint =
        Paint()
          ..color = gridColor
          ..strokeWidth = 1;
    final divisions = yLabels.length - 1;
    for (var i = 0; i <= divisions; i++) {
      final lineY = plotRect.bottom - plotRect.height * i / divisions;
      canvas.drawLine(
        Offset(plotRect.left, lineY),
        Offset(plotRect.right, lineY),
        gridPaint,
      );
      final painter = _textPainter(yLabels[i]);
      painter.paint(
        canvas,
        Offset(plotRect.left - 8 - painter.width, lineY - painter.height / 2),
      );
    }

    final index = selectedIndex;
    if (index == null) return;
    final rect = Rect.fromCenter(
      center: Offset(centerX(index), plotRect.center.dy),
      width: math.min(slotWidth, 40),
      height: plotRect.height,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = highlightColor,
    );
  }

  /// 슬롯이 좁으면 라벨이 겹치므로 격월로 표시하되, 마지막 달과 선택한 달은 항상 표시한다.
  /// 선택한 달이 격월 칸에서 벗어나면 겹치지 않도록 바로 옆 달 라벨을 숨긴다.
  void paintMonthLabels(Canvas canvas) {
    final step = slotWidth < 30 ? 2 : 1;
    final last = monthLabels.length - 1;
    final selected = selectedIndex;
    for (var i = 0; i < monthLabels.length; i++) {
      final isSelected = i == selected;
      final isNextToSelected =
          step > 1 && selected != null && (i - selected).abs() == 1;
      final isVisible =
          isSelected || ((last - i) % step == 0 && !isNextToSelected);
      if (!isVisible) continue;
      final painter = _textPainter(
        monthLabels[i],
        style: isSelected ? selectedLabelStyle : labelStyle,
      );
      painter.paint(
        canvas,
        Offset(centerX(i) - painter.width / 2, plotRect.bottom + 6),
      );
    }
  }

  TextPainter _textPainter(String text, {TextStyle? style}) {
    return TextPainter(
      text: TextSpan(text: text, style: style ?? labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
  }
}
