import 'package:money_mate/data/model/entities/currency.dart';

abstract class AppSettingsRepository {
  Future<bool> hasRequestedNotificationPermission();
  Future<void> setNotificationPermissionRequested();

  /// 저장된 주 통화. 아직 한 번도 설정된 적이 없으면 null을 반환한다.
  Future<CurrencyCode?> getMainCurrency();
  Future<void> setMainCurrency(CurrencyCode currency);
}