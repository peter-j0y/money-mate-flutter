import 'package:flutter/material.dart';
import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/ledger/extensions/expense_payment_method_localization.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_category_options.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_trailing_chevron.dart';

enum LedgerAmountStyle { signed, unsigned }

class LedgerRecordItemContent extends StatelessWidget {
  const LedgerRecordItemContent({
    super.key,
    required this.item,
    this.amountStyle = LedgerAmountStyle.signed,
    this.showExpensePaymentMethod = true,
  });

  final LedgerEntry item;
  final LedgerAmountStyle amountStyle;
  final bool showExpensePaymentMethod;

  @override
  Widget build(BuildContext context) {
    final categoryOption = _categoryOptionOf(item);
    final isIncome = item.type == LedgerRecordType.income;
    final amountColor = isIncome ? AppColors.primary : AppColors.danger;
    final amountPrefix =
        amountStyle == LedgerAmountStyle.signed ? (isIncome ? '+' : '-') : '';
    final memo = _truncateMemo(item.memo?.trim());
    final hasMemo = memo != null && memo.isNotEmpty;
    final rightBottomText =
        showExpensePaymentMethod && !isIncome
            ? item.paymentMethod?.koreanLabel
            : null;
    final hasRightBottomText =
        rightBottomText != null && rightBottomText.isNotEmpty;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: categoryOption.backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            categoryOption.icon,
            color: categoryOption.iconColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (hasMemo) ...[
                const SizedBox(height: 2),
                Text(
                  memo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$amountPrefix${_wonText(item.amount)}',
                  style: TextStyle(
                    fontSize: 16,
                    height: 24 / 16,
                    fontWeight: FontWeight.w500,
                    color: amountColor,
                  ),
                ),
                if (hasRightBottomText) ...[
                  const SizedBox(height: 1),
                  Text(
                    rightBottomText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 15 / 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 8),
            const LedgerTrailingChevron(),
          ],
        ),
      ],
    );
  }

  static String _wonText(int amount) {
    final reversed = amount.toString().split('').reversed.toList();
    final buffer = StringBuffer();
    for (var i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(reversed[i]);
    }
    return '${buffer.toString().split('').reversed.join()}원';
  }

  LedgerCategoryOption _categoryOptionOf(LedgerEntry entry) {
    final options =
        entry.type == LedgerRecordType.income
            ? ledgerIncomeCategoryOptions
            : ledgerExpenseCategoryOptions;
    return options.firstWhere(
      (option) => option.label == entry.category,
      orElse: () => options.last,
    );
  }

  String? _truncateMemo(String? memo) {
    if (memo == null || memo.isEmpty) {
      return null;
    }
    if (memo.length <= 10) {
      return memo;
    }
    return '${memo.substring(0, 10)}...';
  }
}
