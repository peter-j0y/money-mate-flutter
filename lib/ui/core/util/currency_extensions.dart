extension CurrencyFormatExtension on int {
  /// 콤마 포맷으로 변환 (예: 1234567 → "1,234,567원")
  String toCommaWon() {
    final sign = this < 0 ? '-' : '';
    final formatted = _formatWithComma(abs());
    return '$sign$formatted원';
  }

  /// 한국어 단위 포맷으로 변환 (예: 123456789 → "1억 2,345만원")
  String toKoreanWon() {
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