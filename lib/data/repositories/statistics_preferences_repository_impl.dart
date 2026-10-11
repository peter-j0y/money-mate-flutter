import 'package:money_mate/data/local/statistics_preferences_local_data_source.dart';
import 'package:money_mate/data/repositories/statistics_preferences_repository.dart';

import '../model/entities/statistics_preferences.dart';

class StatisticsPreferencesRepositoryImpl
    implements StatisticsPreferencesRepository {
  StatisticsPreferencesRepositoryImpl({
    StatisticsPreferencesLocalDataSource? localDataSource,
  }) : _localDataSource =
           localDataSource ?? StatisticsPreferencesLocalDataSource();

  final StatisticsPreferencesLocalDataSource _localDataSource;

  @override
  Future<StatisticsPreferences> load() {
    return _localDataSource.load();
  }

  @override
  Future<void> save(StatisticsPreferences preferences) {
    return _localDataSource.save(preferences);
  }
}
