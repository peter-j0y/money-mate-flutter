import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

/// 도넛 차트의 한 조각.
class StatisticsDonutSlice {
  const StatisticsDonutSlice({required this.amount, required this.color});

  final int amount;
  final Color color;
}

/// 조각 금액의 합을 100%로 그리는 도넛 차트. 가운데에 [centerValue]를 표시한다.
class StatisticsDonutChart extends StatelessWidget {
  const StatisticsDonutChart({
    super.key,
    required this.slices,
    required this.centerTitle,
    required this.centerValue,
    this.size = 176,
  });

  final List<StatisticsDonutSlice> slices;
  final String centerTitle;
  final String centerValue;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _DonutPainter(
            slices: slices,
            separatorColor: colors.surface,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centerTitle,
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      color: colors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      centerValue,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 15,
                        height: 20 / 15,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.slices, required this.separatorColor});

  final List<StatisticsDonutSlice> slices;
  final Color separatorColor;

  static const double _strokeWidth = 26;

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<int>(0, (sum, slice) => sum + slice.amount);
    if (total <= 0) return;

    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2 - _strokeWidth / 2,
    );
    var startAngle = -math.pi / 2;
    for (final slice in slices) {
      final sweep = 2 * math.pi * slice.amount / total;
      canvas.drawArc(
        rect,
        startAngle,
        sweep,
        false,
        Paint()
          ..color = slice.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = _strokeWidth,
      );
      startAngle += sweep;
    }

    // 조각이 여러 개일 때만 경계선을 그어 구분한다.
    if (slices.length < 2) return;
    final separator =
        Paint()
          ..color = separatorColor
          ..strokeWidth = 2;
    final center = rect.center;
    final inner = rect.width / 2 - _strokeWidth / 2;
    final outer = rect.width / 2 + _strokeWidth / 2;
    var angle = -math.pi / 2;
    for (final slice in slices) {
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * inner,
        center + direction * outer,
        separator,
      );
      angle += 2 * math.pi * slice.amount / total;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => true;
}
