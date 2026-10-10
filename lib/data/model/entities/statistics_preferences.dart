enum StatisticsTrendChartType { line, bar }

/// 통계 화면에서 사용자가 고른 그래프 유형과 숨긴 카테고리.
/// 통계 화면을 다시 열거나 앱을 재실행해도 유지되도록 저장한다.
class StatisticsPreferences {
  const StatisticsPreferences({
    this.trendChartType = StatisticsTrendChartType.line,
    this.hiddenExpenseCategories = const {},
    this.hiddenIncomeCategories = const {},
  });

  final StatisticsTrendChartType trendChartType;

  /// 그래프에서 제외한(체크 해제한) 카테고리 코드.
  final Set<String> hiddenExpenseCategories;
  final Set<String> hiddenIncomeCategories;

  StatisticsPreferences copyWith({
    StatisticsTrendChartType? trendChartType,
    Set<String>? hiddenExpenseCategories,
    Set<String>? hiddenIncomeCategories,
  }) {
    return StatisticsPreferences(
      trendChartType: trendChartType ?? this.trendChartType,
      hiddenExpenseCategories:
          hiddenExpenseCategories ?? this.hiddenExpenseCategories,
      hiddenIncomeCategories:
          hiddenIncomeCategories ?? this.hiddenIncomeCategories,
    );
  }
}
