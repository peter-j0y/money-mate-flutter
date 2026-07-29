import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsLocalDataSource {
  AppSettingsLocalDataSource();

  static const String _notificationPermissionRequestedKey =
      'notification_permission_requested';

  Future<bool> hasRequestedNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationPermissionRequestedKey) ?? false;
  }

  Future<void> setNotificationPermissionRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationPermissionRequestedKey, true);
  }
}