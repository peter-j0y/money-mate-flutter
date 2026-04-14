import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class LedgerIncomeSummaryCard extends StatelessWidget {
  const LedgerIncomeSummaryCard({
    super.key,
    this.incomeText = '0원',
    this.expenseText = '0원',
    this.savableText = '0원',
  });

  final String incomeText;
  final String expenseText;
  final String savableText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryValueColumn(
              title: '수입',
              value: incomeText,
              valueColor: AppColors.primary,
              showRightBorder: true,
            ),
          ),
          Expanded(
            child: _SummaryValueColumn(
              title: '지출',
              value: expenseText,
              valueColor: AppColors.danger,
              showRightBorder: true,
            ),
          ),
          Expanded(
            child: _SummaryValueColumn(
              title: '저축 가능',
              value: savableText,
              valueColor: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryValueColumn extends StatelessWidget {
  const _SummaryValueColumn({
    required this.title,
    required this.value,
    required this.valueColor,
    this.showRightBorder = false,
  });

  final String title;
  final String value;
  final Color valueColor;
  final bool showRightBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 1),
      decoration: BoxDecoration(
        border:
            showRightBorder
                ? const Border(
                  right: BorderSide(color: AppColors.border, width: 1),
                )
                : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: AppColors.hexFF4D545E,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
