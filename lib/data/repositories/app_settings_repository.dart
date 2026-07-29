abstract class AppSettingsRepository {
  Future<bool> hasRequestedNotificationPermission();
  Future<void> setNotificationPermissionRequested();
}