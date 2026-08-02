enum CurrencyCode {
  krw,
  usd,
  jpy,
  eur,
  cny,
  gbp,
  hkd;

  static CurrencyCode fromCode(String? code) {
    return CurrencyCode.values.firstWhere(
      (c) => c.isoCode == code,
      orElse: () => CurrencyCode.krw,
    );
  }
}

extension CurrencyCodeX on CurrencyCode {
  String get isoCode => switch (this) {
    CurrencyCode.krw => 'KRW',
    CurrencyCode.usd => 'USD',
    CurrencyCode.jpy => 'JPY',
    CurrencyCode.eur => 'EUR',
    CurrencyCode.cny => 'CNY',
    CurrencyCode.gbp => 'GBP',
    CurrencyCode.hkd => 'HKD',
  };

  /// ISO 4217 기준 소수점 자릿수. KRW/JPY는 0(보조단위 없음), 그 외는 2(센트 단위).
  int get decimalDigits => switch (this) {
    CurrencyCode.krw => 0,
    CurrencyCode.jpy => 0,
    CurrencyCode.usd => 2,
    CurrencyCode.eur => 2,
    CurrencyCode.cny => 2,
    CurrencyCode.gbp => 2,
    CurrencyCode.hkd => 2,
  };

  bool get supportsDecimalInput => decimalDigits > 0;

  /// 저장값(minor unit)과 사용자가 보는 금액(major unit) 사이의 배율.
  /// 예: USD는 100 (센트 단위), KRW는 1 (보조단위 없음).
  int get minorUnitScale {
    var scale = 1;
    for (var i = 0; i < decimalDigits; i++) {
      scale *= 10;
    }
    return scale;
  }
}

const Set<String> _eurozoneCountryCodes = {
  'DE',
  'FR',
  'IT',
  'ES',
  'NL',
  'BE',
  'AT',
  'IE',
  'PT',
  'FI',
  'GR',
  'LU',
  'SK',
  'SI',
  'EE',
  'LV',
  'LT',
  'CY',
  'MT',
};

/// 기기의 국가 코드를 바탕으로 신규 설치 사용자의 초기 주 통화를 추론한다.
/// 지원하지 않는 국가는 국제적으로 통용되는 USD를 기본값으로 한다.
CurrencyCode defaultCurrencyForCountryCode(String? countryCode) {
  switch (countryCode) {
    case 'KR':
      return CurrencyCode.krw;
    case 'US':
      return CurrencyCode.usd;
    case 'JP':
      return CurrencyCode.jpy;
    case 'CN':
      return CurrencyCode.cny;
    case 'GB':
      return CurrencyCode.gbp;
    case 'HK':
      return CurrencyCode.hkd;
    default:
      if (countryCode != null && _eurozoneCountryCodes.contains(countryCode)) {
        return CurrencyCode.eur;
      }
      return CurrencyCode.krw;
  }
}
