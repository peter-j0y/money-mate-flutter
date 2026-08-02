import 'package:money_mate/data/model/entities/currency.dart';

/// 앱의 현재 주 통화. main()에서 저장된 설정으로 초기화되고,
/// 통화 설정 화면에서 값을 바꾸면 즉시 갱신된다.
class CurrentCurrency {
  CurrentCurrency._();

  static CurrencyCode code = CurrencyCode.krw;
}