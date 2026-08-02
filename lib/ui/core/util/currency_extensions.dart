import 'package:intl/intl.dart';

extension CurrencyFormatExtension on int {
  /// 콤마 포맷으로 변환 (예: 1234567 → "1,234,567원" / "₩1,234,567")
  String toCommaWon() {
    final sign = this < 0 ? '-' : '';
    final formatted = _formatWithComma(abs());
    return _isKorean ? '$sign$formatted원' : '$sign₩$formatted';
  }

  /// 한국어 로케일에서는 단위 포맷(예: 123456789 → "1억 2,345만원"),
  /// 그 외 로케일에서는 콤마 포맷으로 변환한다.
  String toKoreanWon() {
    if (!_isKorean) {
      return toCommaWon();
    }
    if (this <= 0) return '0원';

    final eok = this ~/ 100000000;
    final man = (this % 100000000) ~/ 10000;
    final won = this % 10000;

    final parts = <String>[];
    if (eok > 0) parts.add('$eok억');
    if (man > 0) parts.add('${_formatWithComma(man)}만');
    if (won > 0) parts.add(_formatWithComma(won));

    if (parts.isEmpty) return '0원';
    return '${parts.join(' ')}원';
  }
}

bool get _isKorean => Intl.getCurrentLocale().startsWith('ko');

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
