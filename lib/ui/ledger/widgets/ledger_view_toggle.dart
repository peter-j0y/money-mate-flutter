import 'package:flutter/material.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

enum LedgerViewType { calendar, monthly }

class LedgerViewToggle extends StatelessWidget {
  const LedgerViewToggle({
    super.key,
    required this.selectedView,
    this.onChanged,
  });

  final LedgerViewType selectedView;
  final ValueChanged<LedgerViewType>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SegmentedToggle(
      options: [l10n.viewCalendar, l10n.viewList],
      selectedIndex: selectedView == LedgerViewType.calendar ? 0 : 1,
      onChanged: (index) {
        onChanged?.call(
          index == 0 ? LedgerViewType.calendar : LedgerViewType.monthly,
        );
      },
    );
  }
}

class SegmentedToggle extends StatelessWidget {
  const SegmentedToggle({
    super.key,
    required this.options,
    required this.selectedIndex,
    this.onChanged,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: context.appColors.surfaceMuted,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: List.generate(options.length, (index) {
            return Expanded(
              child: _ToggleButton(
                label: options[index],
                isSelected: selectedIndex == index,
                onTap: () => onChanged?.call(index),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
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
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? context.appColors.surface
                    : context.appColors.overlay,
            borderRadius: BorderRadius.circular(16),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ]
                    : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color:
                  isSelected
                      ? context.appColors.primary
                      : context.appColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
