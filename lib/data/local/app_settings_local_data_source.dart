import 'package:money_mate/data/local/app_database.dart';

class AppSettingsLocalDataSource {
  AppSettingsLocalDataSource({AppDatabase? database})
    : _database = database ?? AppDatabase();

  final AppDatabase _database;

  Future<String?> getThemeMode() {
    return _database.getThemeMode();
  }

  Stream<String?> watchThemeMode() {
    return _database.watchThemeMode();
  }

  Future<void> setThemeMode(String themeMode) {
    return _database.setThemeMode(themeMode);
  }
}
