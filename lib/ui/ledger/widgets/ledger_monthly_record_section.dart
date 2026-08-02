import 'package:flutter/material.dart';
import 'package:money_mate/data/model/entities/currency.dart';
import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_record_item_content.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_state_card.dart';

class LedgerMonthlyRecordSection extends StatelessWidget {
  const LedgerMonthlyRecordSection({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.totalLabel,
    required this.items,
    required this.onItemTap,
    this.onAddTap,
  });

  final String title;
  final String emptyMessage;
  final String totalLabel;
  final List<LedgerEntry> items;
  final ValueChanged<LedgerEntry> onItemTap;
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    final totalsByCurrency = <CurrencyCode, int>{};
    for (final item in items) {
      final currency = CurrencyCode.fromCode(item.currencyCode);
      totalsByCurrency[currency] = (totalsByCurrency[currency] ?? 0) + item.amount;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  height: 28 / 18,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
              Material(
                color: context.appColors.surfaceMuted,
                borderRadius: BorderRadius.circular(9999),
                child: InkWell(
                  borderRadius: BorderRadius.circular(9999),
                  onTap: onAddTap,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      AppLocalizations.of(context)!.addShort,
                      style: TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w700,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LedgerStateCard(
          padding: EdgeInsets.zero,
          borderRadius: 24,
          backgroundColor: context.appColors.surface,
          borderColor: context.appColors.surfaceMuted,
          child: Column(
            children: [
              if (items.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Text(
                    emptyMessage,
                    style: TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w500,
                      color: context.appColors.textTertiary,
                    ),
                  ),
                )
              else
                ...items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _RecordItemTile(
                    item: item,
                    onTap: () => onItemTap(item),
                    isFirst: index == 0,
                    hasTopBorder: index > 0,
                  );
                }),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.appColors.surfaceMuted,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  border: Border(
                    top: BorderSide(color: context.appColors.border, width: 1),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 13, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      totalLabel,
                      style: TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w500,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                    Text(
                      formatGroupedCurrencyAmounts(totalsByCurrency),
                      style: TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w500,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecordItemTile extends StatelessWidget {
  const _RecordItemTile({
    required this.item,
    required this.onTap,
    required this.isFirst,
    required this.hasTopBorder,
  });

  final LedgerEntry item;
  final VoidCallback onTap;
  final bool isFirst;
  final bool hasTopBorder;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.surface,
      borderRadius:
          isFirst
              ? const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              )
              : null,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            isFirst
                ? const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                )
                : null,
        child: Container(
          decoration: BoxDecoration(
            border:
                hasTopBorder
                    ? Border(
                      top: BorderSide(
                        color: context.appColors.background,
                        width: 1,
                      ),
                    )
                    : null,
          ),
          padding: const EdgeInsets.all(16),
          child: LedgerRecordItemContent(
            item: item,
            amountStyle: LedgerAmountStyle.unsigned,
            showExpensePaymentMethod: false,
          ),
        ),
      ),
    );
  }
}
