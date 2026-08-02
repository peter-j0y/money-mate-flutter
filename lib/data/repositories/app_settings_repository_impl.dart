import 'package:money_mate/data/local/app_settings_local_data_source.dart';
import 'package:money_mate/data/model/entities/currency.dart';
import 'package:money_mate/data/repositories/app_settings_repository.dart';

class AppSettingsRepositoryImpl implements AppSettingsRepository {
  AppSettingsRepositoryImpl({AppSettingsLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? AppSettingsLocalDataSource();

  final AppSettingsLocalDataSource _localDataSource;

  @override
  Future<bool> hasRequestedNotificationPermission() {
    return _localDataSource.hasRequestedNotificationPermission();
  }

  @override
  Future<void> setNotificationPermissionRequested() {
    return _localDataSource.setNotificationPermissionRequested();
  }

  @override
  Future<CurrencyCode?> getMainCurrency() async {
    final code = await _localDataSource.getMainCurrencyCode();
    if (code == null) return null;
    return CurrencyCode.fromCode(code);
  }

  @override
  Future<void> setMainCurrency(CurrencyCode currency) {
    return _localDataSource.setMainCurrencyCode(currency.isoCode);
  }
}