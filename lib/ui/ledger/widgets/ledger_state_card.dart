import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class LedgerStateCard extends StatelessWidget {
  const LedgerStateCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
    this.borderRadius = 16,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.appColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: child,
    );
  }
}
