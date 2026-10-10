import '../model/entities/statistics_preferences.dart';

abstract class StatisticsPreferencesRepository {
  /// 저장된 값이 없으면 기본값(꺾은선/원형, 숨긴 카테고리 없음)을 반환한다.
  Future<StatisticsPreferences> load();
  Future<void> save(StatisticsPreferences preferences);
}
