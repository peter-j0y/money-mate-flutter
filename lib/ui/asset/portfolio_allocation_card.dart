import 'package:flutter/material.dart';
import 'package:money_mate/ui/asset/portfolio_allocation_chart.dart';
import 'package:money_mate/ui/asset/portfolio_allocation_row.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class PortfolioAllocationCard extends StatelessWidget {
  const PortfolioAllocationCard({
    super.key,
    this.onSetTargetTap,
  });

  final VoidCallback? onSetTargetTap;

  static const _rows = [
    _PortfolioRowData(label: '주식', actual: 40.3, target: 40, color: Color(0xFF3B82F6)),
    _PortfolioRowData(label: '현금', actual: 9.4, target: 15, color: Color(0xFF10B981)),
    _PortfolioRowData(label: '가상화폐', actual: 14.1, target: 10, color: Color(0xFF8B5CF6)),
    _PortfolioRowData(label: '예적금', actual: 29.4, target: 25, color: Color(0xFF0EA5E9)),
    _PortfolioRowData(label: '원자재', actual: 6.8, target: 10, color: Color(0xFFEF4444)),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonBg =
        isDark
            ? context.appColors.surfaceMuted
            : const Color(0xFFF3F4F6);
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border:
            isDark
                ? Border.all(color: context.appColors.border)
                : null,
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '포트폴리오 구성',
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 28,
                child: TextButton.icon(
                  onPressed: onSetTargetTap,
                  style: TextButton.styleFrom(
                    backgroundColor: buttonBg,
                    foregroundColor: context.appColors.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: Icon(
                    Icons.tune_rounded,
                    size: 13,
                    color: context.appColors.textPrimary,
                  ),
                  label: Text(
                    '목표 비율 설정',
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w500,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '실제 비율',
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w400,
              color: context.appColors.textTertiary,
            ),
          ),
          const SizedBox(height: 6),
          PortfolioAllocationChart(
            items: _rows
                .map((e) => PortfolioAllocationChartItem(ratio: e.actual, color: e.color))
                .toList(growable: false),
          ),
          const SizedBox(height: 16),
          ...List.generate(_rows.length, (index) {
            final row = _rows[index];
            return PortfolioAllocationRow(
              label: row.label,
              actualRatio: row.actual,
              targetRatio: row.target,
              color: row.color,
              showDivider: index != _rows.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _PortfolioRowData {
  const _PortfolioRowData({
    required this.label,
    required this.actual,
    required this.target,
    required this.color,
  });

  final String label;
  final double actual;
  final double target;
  final Color color;
}
