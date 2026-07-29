abstract class AppSettingsRepository {
  Future<bool> hasRequestedNotificationPermission();
  Future<void> setNotificationPermissionRequested();
  Future<bool> isReminderEnabled();
  Future<void> setReminderEnabled(bool enabled);
}
