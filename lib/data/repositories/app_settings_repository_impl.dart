import 'package:money_mate/data/local/app_settings_local_data_source.dart';
import 'package:money_mate/data/model/entities/app_theme_mode.dart';
import 'package:money_mate/data/repositories/app_settings_repository.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  AppSettingsRepositoryImpl({AppSettingsLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? AppSettingsLocalDataSource();

  final AppSettingsLocalDataSource _localDataSource;

  @override
  Future<AppThemeMode> getThemeMode() async {
    final code = await _localDataSource.getThemeMode();
    return AppThemeModeFromCode.fromCode(code);
  }

  @override
  Stream<AppThemeMode> watchThemeMode() {
    return _localDataSource.watchThemeMode().map(
      AppThemeModeFromCode.fromCode,
    );
  }

  @override
  Future<void> setThemeMode(AppThemeMode themeMode) {
    return _localDataSource.setThemeMode(themeMode.code);
  }
}
