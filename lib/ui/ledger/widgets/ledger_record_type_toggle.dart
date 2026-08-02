import 'package:flutter/material.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class LedgerRecordTypeToggle extends StatelessWidget {
  const LedgerRecordTypeToggle({
    super.key,
    required this.selectedIndex,
    this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: _RecordTypeButton(
              label: l10n.typeIncome,
              isSelected: selectedIndex == 0,
              onTap: () => onChanged?.call(0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _RecordTypeButton(
              label: l10n.typeExpense,
              isSelected: selectedIndex == 1,
              onTap: () => onChanged?.call(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordTypeButton extends StatelessWidget {
  const _RecordTypeButton({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.overlay,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:
                isSelected
                    ? context.appColors.primary
                    : context.appColors.surfaceMuted,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.appColors.overlay, width: 2),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color:
                  isSelected
                      ? AppColors.white
                      : context.appColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
