import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class LedgerScreenHeaderAction {
  const LedgerScreenHeaderAction({
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;
}

class LedgerScreenHeader extends StatelessWidget {
  const LedgerScreenHeader({
    super.key,
    required this.title,
    required this.onCloseTap,
    this.actions = const [],
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(0, 16, 0, 8),
    this.closeButtonSize = 48,
  });

  final String title;
  final VoidCallback onCloseTap;
  final List<LedgerScreenHeaderAction> actions;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final double closeButtonSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: closeButtonSize,
                height: closeButtonSize,
                child: IconButton(
                  onPressed: onCloseTap,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 24,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                height: 22.5 / 18,
                fontWeight: FontWeight.w500,
                color: context.appColors.textPrimary,
              ),
            ),
            if (trailing != null)
              Align(alignment: Alignment.centerRight, child: trailing)
            else if (actions.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      _LedgerHeaderActionButton(action: actions[i]),
                    ],
                    const SizedBox(width: 16),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LedgerHeaderActionButton extends StatelessWidget {
  const _LedgerHeaderActionButton({required this.action});

  final LedgerScreenHeaderAction action;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: action.onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Text(
          action.label,
          style: TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w500,
            color: action.color,
          ),
        ),
      ),
    );
  }
}
