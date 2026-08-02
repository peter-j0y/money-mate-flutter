import 'package:intl/intl.dart';
import 'package:money_mate/data/model/entities/currency.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/currency/current_currency.dart';

enum CurrencySymbolPosition { prefix, suffix }

class _CurrencySymbolRule {
  const _CurrencySymbolRule({required this.symbol, required this.position});

  final String symbol;
  final CurrencySymbolPosition position;
}

/// KRW는 언어에 따라 표기(원/₩)가 달라져 별도 처리하고,
/// 그 외 통화는 언어와 무관하게 국제 관례(기호 접두)를 따른다.
const Map<CurrencyCode, _CurrencySymbolRule> _currencySymbolRules = {
  CurrencyCode.usd: _CurrencySymbolRule(
    symbol: '\$',
    position: CurrencySymbolPosition.prefix,
  ),
  CurrencyCode.jpy: _CurrencySymbolRule(
    symbol: '¥',
    position: CurrencySymbolPosition.prefix,
  ),
  CurrencyCode.eur: _CurrencySymbolRule(
    symbol: '€',
    position: CurrencySymbolPosition.prefix,
  ),
  CurrencyCode.cny: _CurrencySymbolRule(
    symbol: 'CN¥',
    position: CurrencySymbolPosition.prefix,
  ),
  CurrencyCode.gbp: _CurrencySymbolRule(
    symbol: '£',
    position: CurrencySymbolPosition.prefix,
  ),
  CurrencyCode.hkd: _CurrencySymbolRule(
    symbol: 'HK\$',
    position: CurrencySymbolPosition.prefix,
  ),
};

extension CurrencyFormatExtension on int {
  /// 통화별 규칙(기호 위치, 소수점 자리수)에 맞춰 금액을 포맷한다.
  /// 소수점이 있는 통화(USD 등)는 [this]를 최소단위(예: 센트)로 해석한다.
  /// KRW/JPY처럼 소수점이 없는 통화는 그대로 정수 단위로 해석한다.
  /// [useKoreanUnitGrouping]이 true이고 통화가 KRW·한국어 로케일이면
  /// 억/만 단위 표기(예: "1억 2,345만원")를 사용한다.
  String toFormattedCurrency(
    CurrencyCode currency, {
    bool useKoreanUnitGrouping = false,
  }) {
    if (currency == CurrencyCode.krw) {
      if (useKoreanUnitGrouping && _isKorean) {
        return _formatKoreanWonUnits(this);
      }
      final sign = this < 0 ? '-' : '';
      final formatted = _formatWithComma(abs());
      return _isKorean ? '$sign$formatted원' : '$sign₩$formatted';
    }

    final rule = _currencySymbolRules[currency]!;
    final decimalDigits = currency.decimalDigits;
    final sign = this < 0 ? '-' : '';
    final absValue = abs();

    String amountText;
    if (decimalDigits > 0) {
      final scale = currency.minorUnitScale;
      final majorPart = absValue ~/ scale;
      final minorPart = absValue % scale;
      final minorText = minorPart.toString().padLeft(decimalDigits, '0');
      amountText = '${_formatWithComma(majorPart)}.$minorText';
    } else {
      amountText = _formatWithComma(absValue);
    }

    return rule.position == CurrencySymbolPosition.prefix
        ? '$sign${rule.symbol}$amountText'
        : '$sign$amountText${rule.symbol}';
  }
}

/// 금액 입력 필드 옆에 붙는 통화 단위 표기. KRW는 기존 문구(원/KRW)를 유지하고,
/// 그 외 통화는 ISO 코드로 표시한다.
String currencyInputSuffixLabel(CurrencyCode currency, AppLocalizations l10n) {
  if (currency == CurrencyCode.krw) return l10n.currencyUnitSuffix;
  return currency.isoCode;
}

/// 통화별로 묶인 금액 맵을 줄바꿈으로 이어 붙인다("₩1,000,000\n$200" 형태).
/// 한 줄로 이어붙이면 통화가 늘어날수록 폭이 길어져 레이아웃이 깨지기 쉬워
/// 가로가 아닌 세로로 쌓이게 한다.
/// 0원인 통화는 표시하지 않으며, 전부 0이면 현재 주 통화 기준 0을 보여준다.
String formatGroupedCurrencyAmounts(
  Map<CurrencyCode, int> amountsByCurrency, {
  bool useKoreanUnitGrouping = false,
}) {
  final nonZeroEntries =
      amountsByCurrency.entries.where((entry) => entry.value != 0).toList()
        ..sort((a, b) => a.key.index.compareTo(b.key.index));

  if (nonZeroEntries.isEmpty) {
    return 0.toFormattedCurrency(
      CurrentCurrency.code,
      useKoreanUnitGrouping: useKoreanUnitGrouping,
    );
  }

  return nonZeroEntries
      .map(
        (entry) => entry.value.toFormattedCurrency(
          entry.key,
          useKoreanUnitGrouping: useKoreanUnitGrouping,
        ),
      )
      .join('\n');
}

bool get _isKorean => Intl.getCurrentLocale().startsWith('ko');

String _formatKoreanWonUnits(int value) {
  if (value <= 0) return '0원';

  final eok = value ~/ 100000000;
  final man = (value % 100000000) ~/ 10000;
  final won = value % 10000;

  final parts = <String>[];
  if (eok > 0) parts.add('$eok억');
  if (man > 0) parts.add('${_formatWithComma(man)}만');
  if (won > 0) parts.add(_formatWithComma(won));

  if (parts.isEmpty) return '0원';
  return '${parts.join(' ')}원';
}

String _formatWithComma(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final reverseIndex = raw.length - i;
    buffer.write(raw[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write(',');
  }
  return buffer.toString();
}