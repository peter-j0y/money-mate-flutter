import 'package:shared_preferences/shared_preferences.dart';

import '../model/entities/statistics_preferences.dart';

class StatisticsPreferencesLocalDataSource {
  StatisticsPreferencesLocalDataSource();

  static const String _trendChartTypeKey = 'statistics_trend_chart_type';
  static const String _hiddenExpenseCategoriesKey =
      'statistics_hidden_expense_categories';
  static const String _hiddenIncomeCategoriesKey =
      'statistics_hidden_income_categories';

  Future<StatisticsPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    const defaults = StatisticsPreferences();
    return StatisticsPreferences(
      trendChartType: _enumByName(
        StatisticsTrendChartType.values,
        prefs.getString(_trendChartTypeKey),
        defaults.trendChartType,
      ),
      hiddenExpenseCategories:
          (prefs.getStringList(_hiddenExpenseCategoriesKey) ?? const [])
              .toSet(),
      hiddenIncomeCategories:
          (prefs.getStringList(_hiddenIncomeCategoriesKey) ?? const []).toSet(),
    );
  }

  Future<void> save(StatisticsPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_trendChartTypeKey, preferences.trendChartType.name);
    await prefs.setStringList(
      _hiddenExpenseCategoriesKey,
      preferences.hiddenExpenseCategories.toList(),
    );
    await prefs.setStringList(
      _hiddenIncomeCategoriesKey,
      preferences.hiddenIncomeCategories.toList(),
    );
  }

  T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}
