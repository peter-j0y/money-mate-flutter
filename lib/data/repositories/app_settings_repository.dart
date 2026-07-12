import 'package:money_mate/data/model/entities/app_theme_mode.dart';

abstract class AppSettingsRepository {
  Future<AppThemeMode> getThemeMode();
  Stream<AppThemeMode> watchThemeMode();
  Future<void> setThemeMode(AppThemeMode themeMode);
}
