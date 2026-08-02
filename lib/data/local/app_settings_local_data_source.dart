import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsLocalDataSource {
  AppSettingsLocalDataSource();

  static const String _notificationPermissionRequestedKey =
      'notification_permission_requested';
  static const String _mainCurrencyCodeKey = 'main_currency_code';

  Future<bool> hasRequestedNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationPermissionRequestedKey) ?? false;
  }

  Future<void> setNotificationPermissionRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationPermissionRequestedKey, true);
  }

  Future<String?> getMainCurrencyCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mainCurrencyCodeKey);
  }

  Future<void> setMainCurrencyCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mainCurrencyCodeKey, code);
  }
}
