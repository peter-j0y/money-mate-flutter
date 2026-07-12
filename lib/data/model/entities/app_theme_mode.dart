enum AppThemeMode {
  system,
  light,
  dark;

  String get code {
    switch (this) {
      case AppThemeMode.system:
        return 'system';
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
    }
  }
}

extension AppThemeModeFromCode on AppThemeMode {
  static AppThemeMode fromCode(String? code) {
    switch (code) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }
}
