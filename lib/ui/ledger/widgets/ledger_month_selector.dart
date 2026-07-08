import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class LedgerMonthSelector extends StatelessWidget {
  const LedgerMonthSelector({
    super.key,
    required this.monthLabel,
    this.onPreviousTap,
    this.onNextTap,
    this.onLabelTap,
  });

  final String monthLabel;
  final VoidCallback? onPreviousTap;
  final VoidCallback? onNextTap;
  final VoidCallback? onLabelTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ArrowButton(icon: Icons.chevron_left_rounded, onTap: onPreviousTap),
          const SizedBox(width: 24),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onLabelTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
              ),
              child: Text(
                monthLabel,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: context.appColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          _ArrowButton(icon: Icons.chevron_right_rounded, onTap: onNextTap),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Material(
        color: context.appColors.overlay,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Icon(icon, size: 18, color: context.appColors.textTertiary),
        ),
      ),
    );
  }
}
