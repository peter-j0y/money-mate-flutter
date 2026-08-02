import 'package:flutter/material.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/ui/ledger/extensions/expense_payment_method_localization.dart';

class ExpensePaymentMethodSelector extends StatelessWidget {
  const ExpensePaymentMethodSelector({
    super.key,
    required this.options,
    required this.selectedMethod,
    required this.onChanged,
  });

  final List<ExpensePaymentMethod> options;
  final ExpensePaymentMethod? selectedMethod;
  final ValueChanged<ExpensePaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.expensePaymentMethodLabel,
          style: TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w500,
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < options.length; i++)
              _PaymentMethodChip(
                label: options[i].label(l10n),
                selected: selectedMethod == options[i],
                onTap: () => onChanged(options[i]),
              ),
          ],
        ),
      ],
    );
  }
}

class _PaymentMethodChip extends StatelessWidget {
  const _PaymentMethodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(9999),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
        decoration: BoxDecoration(
          color:
              selected ? context.appColors.primary : context.appColors.surface,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color:
                selected ? context.appColors.primary : context.appColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.white : context.appColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
