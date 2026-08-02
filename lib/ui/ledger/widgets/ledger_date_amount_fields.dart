import 'package:flutter/material.dart';
import 'package:money_mate/data/model/entities/currency.dart';
import 'package:money_mate/l10n/app_localizations.dart';
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
    required this.currency,
    this.inputFormatters = const [],
    this.onTap,
  }) : readOnlyText = null;

  const LedgerAmountField.readOnly({
    super.key,
    required this.readOnlyText,
    required this.currency,
  }) : controller = null,
       focusNode = null,
       inputFormatters = const [],
       onTap = null;

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final List<TextInputFormatter> inputFormatters;
  final String? readOnlyText;
  final VoidCallback? onTap;
  final CurrencyCode currency;

  @override
  Widget build(BuildContext context) {
    final amountWidget =
        controller != null
            ? TextField(
              controller: controller,
              focusNode: focusNode,
              onTap: onTap,
              keyboardType: TextInputType.numberWithOptions(
                decimal: currency.supportsDecimalInput,
              ),
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
            currencyInputSuffixLabel(currency, AppLocalizations.of(context)!),
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

/// 통화별 소수점 자릿수를 반영해 금액 입력을 처리하는 포맷터.
/// 소수점을 지원하지 않는 통화(KRW/JPY 등)는 숫자만 허용하고,
/// 지원하는 통화는 소수점 하나와 통화별 자릿수만큼의 소수 입력을 허용한다.
class CurrencyAmountInputFormatter extends TextInputFormatter {
  const CurrencyAmountInputFormatter({required this.currency});

  final CurrencyCode currency;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final decimalDigits = currency.decimalDigits;
    final allowedChars =
        decimalDigits > 0 ? RegExp(r'[^0-9.]') : RegExp(r'[^0-9]');
    var cleaned = newValue.text.replaceAll(allowedChars, '');

    if (decimalDigits > 0) {
      final firstDot = cleaned.indexOf('.');
      if (firstDot != -1) {
        final before = cleaned.substring(0, firstDot + 1);
        final after = cleaned.substring(firstDot + 1).replaceAll('.', '');
        cleaned = before + after;
      }
    }

    if (cleaned.isEmpty || cleaned == '.') {
      return const TextEditingValue(
        text: '0',
        selection: TextSelection.collapsed(offset: 1),
      );
    }

    final formatted = _format(cleaned, decimalDigits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }

  static String _format(String cleaned, int decimalDigits) {
    final dotIndex = cleaned.indexOf('.');
    if (dotIndex == -1) {
      return _formatIntegerPart(cleaned);
    }

    final integerPart = cleaned.substring(0, dotIndex);
    var fractionPart = cleaned.substring(dotIndex + 1);
    if (fractionPart.length > decimalDigits) {
      fractionPart = fractionPart.substring(0, decimalDigits);
    }

    final formattedInteger = _formatIntegerPart(
      integerPart.isEmpty ? '0' : integerPart,
    );
    return '$formattedInteger.$fractionPart';
  }

  static String _formatIntegerPart(String digits) {
    final trimmed = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final normalized = trimmed.isEmpty ? '0' : trimmed;
    final buffer = StringBuffer();
    for (var i = 0; i < normalized.length; i++) {
      final reverseIndex = normalized.length - i;
      buffer.write(normalized[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }

  /// 화면에 표시된 텍스트(콤마·소수점 포함)를 저장용 최소단위 정수로 변환한다.
  static int parseToMinorUnits(String text, CurrencyCode currency) {
    final decimalDigits = currency.decimalDigits;
    final normalized = text.replaceAll(',', '');
    final parts = normalized.split('.');
    final majorDigits = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
    final major = int.tryParse(majorDigits) ?? 0;

    var minor = 0;
    if (decimalDigits > 0 && parts.length > 1) {
      final minorDigitsRaw = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
      final minorDigits = minorDigitsRaw
          .padRight(decimalDigits, '0')
          .substring(0, decimalDigits);
      minor = int.tryParse(minorDigits) ?? 0;
    }

    return major * currency.minorUnitScale + minor;
  }

  /// 저장된 최소단위 정수를 편집 가능한 표시 텍스트(콤마·소수점 포함)로 변환한다.
  static String formatMinorUnits(int minorUnits, CurrencyCode currency) {
    final scale = currency.minorUnitScale;
    final majorText = _formatIntegerPart((minorUnits ~/ scale).toString());
    if (currency.decimalDigits == 0) {
      return majorText;
    }
    final minorText = (minorUnits % scale).toString().padLeft(
      currency.decimalDigits,
      '0',
    );
    return '$majorText.$minorText';
  }
}
