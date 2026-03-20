import 'package:flutter/material.dart';

class LedgerIncomeSummaryCard extends StatelessWidget {
  const LedgerIncomeSummaryCard({
    super.key,
    this.incomeText = '₩0',
    this.expenseText = '₩0',
    this.savableText = '₩0',
  });

  final String incomeText;
  final String expenseText;
  final String savableText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryValueColumn(
              title: '수입',
              value: incomeText,
              valueColor: const Color(0xFF137FEC),
              showRightBorder: true,
            ),
          ),
          Expanded(
            child: _SummaryValueColumn(
              title: '지출',
              value: expenseText,
              valueColor: const Color(0xFFF43F5E),
              showRightBorder: true,
            ),
          ),
          Expanded(
            child: _SummaryValueColumn(
              title: '저축 가능',
              value: savableText,
              valueColor: const Color(0xFF10B981),
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
        border: showRightBorder
            ? const Border(
                right: BorderSide(
                  color: Color(0xFFE2E8F0),
                  width: 1,
                ),
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
              color: Color(0xFF4D545E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w400,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
