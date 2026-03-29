import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class LedgerTrailingChevron extends StatelessWidget {
  const LedgerTrailingChevron({super.key, this.size = 14});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      size: size,
      color: AppColors.textTertiary,
    );
  }
}
