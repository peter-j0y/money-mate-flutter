import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:flutter/services.dart';

class LedgerDateCard extends StatelessWidget {
  const LedgerDateCard({
    super.key,
    required this.date,
    required this.dateTextBuilder,
    this.onTap,
  });

  final DateTime date;
  final String Function(DateTime) dateTextBuilder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dateTextBuilder(date),
              style: TextStyle(
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w500,
                color: context.appColors.textPrimary,
              ),
            ),
          ),
          Icon(
            Icons.calendar_today_outlined,
            size: 20,
            color: context.appColors.textTertiary,
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(child: content),
    );
  }
}

class LedgerAmountField extends StatelessWidget {
  const LedgerAmountField.editable({
    super.key,
    required this.controller,
    required this.focusNode,
    this.inputFormatters = const [],
    this.onTap,
  }) : readOnlyText = null;

  const LedgerAmountField.readOnly({super.key, required this.readOnlyText})
    : controller = null,
      focusNode = null,
      inputFormatters = const [],
      onTap = null;

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final List<TextInputFormatter> inputFormatters;
  final String? readOnlyText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final amountWidget =
        controller != null
            ? TextField(
              controller: controller,
              focusNode: focusNode,
              onTap: onTap,
              keyboardType: TextInputType.number,
              inputFormatters: inputFormatters,
              style: TextStyle(
                fontSize: 36,
                height: 36 / 30,
                fontWeight: FontWeight.w700,
                color: context.appColors.textPrimary,
              ),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 6),
              ),
            )
            : Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                readOnlyText ?? '0',
                style: TextStyle(
                  fontSize: 36,
                  height: 36 / 30,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
            );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: amountWidget),
        Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            '원',
            style: TextStyle(
              fontSize: 20,
              height: 28 / 20,
              fontWeight: FontWeight.w500,
              color: context.appColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
