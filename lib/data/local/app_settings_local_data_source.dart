import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsLocalDataSource {
  AppSettingsLocalDataSource();

  static const String _notificationPermissionRequestedKey =
      'notification_permission_requested';
  static const String _reminderEnabledKey = 'reminder_enabled';

  Future<bool> hasRequestedNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationPermissionRequestedKey) ?? false;
  }

  Future<void> setNotificationPermissionRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationPermissionRequestedKey, true);
  }

  Future<bool> isReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_reminderEnabledKey) ?? false;
  }

  Future<void> setReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, enabled);
  }
}
