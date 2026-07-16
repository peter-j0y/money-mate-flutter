import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_record_item_content.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_state_card.dart';

class SelectedDateLedgerSection extends StatelessWidget {
  const SelectedDateLedgerSection({
    super.key,
    required this.selectedDate,
    required this.items,
    required this.isLoading,
    required this.errorMessage,
    required this.selectedDateLabelBuilder,
    required this.onItemTap,
    this.controller,
  });

  final DateTime? selectedDate;
  final List<LedgerEntry> items;
  final bool isLoading;
  final String? errorMessage;
  final String Function(DateTime) selectedDateLabelBuilder;
  final ValueChanged<LedgerEntry> onItemTap;
  final ScrollController? controller;
  static const double _emptyStateHeight = 80;

  @override
  Widget build(BuildContext context) {
    if (selectedDate == null) {
      return const SizedBox.shrink();
    }

    final totalAmount = items.fold<int>(
      0,
      (sum, item) =>
          sum +
          (item.type == LedgerRecordType.income ? item.amount : -item.amount),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedDateLabelBuilder(selectedDate!),
                style: TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w500,
                  color: context.appColors.textPrimary,
                ),
              ),
              Text(
                '합계 ${_wonText(totalAmount)}',
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w400,
                  color: context.appColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty && !isLoading && errorMessage == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                height: _emptyStateHeight,
                child: LedgerStateCard(
                  child: Center(
                    child: Text(
                      '해당 날짜에 등록된 내역이 없어요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w500,
                        color: context.appColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),
            )
          else if (isLoading)
            SizedBox(
              height: _emptyStateHeight,
              child: const LedgerStateCard(
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (errorMessage != null)
            SizedBox(
              height: _emptyStateHeight,
              child: LedgerStateCard(
                child: Center(
                  child: Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w500,
                      color: context.appColors.danger,
                    ),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              controller: controller,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 48),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                return _DailyLedgerListTile(item: item, onTap: onItemTap);
              },
            ),
        ],
      ),
    );
  }

  String _wonText(int amount) {
    final sign = amount < 0 ? '-' : '';
    final reversed = amount.abs().toString().split('').reversed.toList();
    final buffer = StringBuffer();

    for (var i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(reversed[i]);
    }

    return '$sign${buffer.toString().split('').reversed.join()}원';
  }
}

class _DailyLedgerListTile extends StatelessWidget {
  const _DailyLedgerListTile({required this.item, required this.onTap});

  final LedgerEntry item;
  final ValueChanged<LedgerEntry> onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onTap(item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LedgerRecordItemContent(
            item: item,
            amountStyle: LedgerAmountStyle.signed,
            showExpensePaymentMethod: true,
          ),
        ),
      ),
    );
  }
}
