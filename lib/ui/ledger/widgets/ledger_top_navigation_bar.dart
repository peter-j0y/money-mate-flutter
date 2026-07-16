import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_view_toggle.dart';

class LedgerTopNavigationBar extends StatelessWidget {
  const LedgerTopNavigationBar({
    super.key,
    required this.selectedView,
    required this.onChanged,
  });

  final LedgerViewType selectedView;
  final ValueChanged<LedgerViewType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      decoration: BoxDecoration(color: context.appColors.background),
      child: Row(
        children: [
          _TopNavItem(
            label: '달력',
            isSelected: selectedView == LedgerViewType.calendar,
            onTap: () => onChanged(LedgerViewType.calendar),
          ),
          const SizedBox(width: 8),
          _TopNavItem(
            label: '목록',
            isSelected: selectedView == LedgerViewType.monthly,
            onTap: () => onChanged(LedgerViewType.monthly),
          ),
        ],
      ),
    );
  }
}

class _TopNavItem extends StatelessWidget {
  const _TopNavItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.overlay,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 20,
                height: 28 / 18,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color:
                    isSelected ? context.appColors.textPrimary : context.appColors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
