import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:money_mate/data/model/entities/currency.dart';
import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/data/model/entities/statistics_preferences.dart';
import 'package:money_mate/data/repositories/ledger_record_repository.dart';
import 'package:money_mate/data/repositories/ledger_record_repository_impl.dart';
import 'package:money_mate/data/repositories/statistics_preferences_repository.dart';
import 'package:money_mate/data/repositories/statistics_preferences_repository_impl.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_category_options.dart';

/// 한 달의 수입/지출 합계.
class MonthlyIncomeExpense {
  const MonthlyIncomeExpense({
    required this.month,
    required this.income,
    required this.expense,
  });

  final DateTime month;
  final int income;
  final int expense;
}

/// 한 달의 카테고리별 합계. 기록이 없는 카테고리는 [amounts]에 들어 있지 않다.
class MonthlyCategoryAmounts {
  const MonthlyCategoryAmounts({required this.month, required this.amounts});

  final DateTime month;
  final Map<String, int> amounts;
}

class LedgerStatisticsViewModel extends ChangeNotifier {
  LedgerStatisticsViewModel({
    LedgerRecordRepository? repository,
    StatisticsPreferencesRepository? preferencesRepository,
    DateTime Function()? now,
  }) : _repository = repository ?? LedgerRecordRepositoryImpl(),
       _preferencesRepository =
           preferencesRepository ?? StatisticsPreferencesRepositoryImpl(),
       _now = now ?? DateTime.now;

  /// 그래프에 보여주는 최대 개월 수(이번 달 포함).
  static const int trendMonthCount = 12;
  static const String otherCategoryCode = '기타';

  final LedgerRecordRepository _repository;
  final StatisticsPreferencesRepository _preferencesRepository;
  final DateTime Function() _now;

  StreamSubscription<List<LedgerEntry>>? _subscription;
  StreamSubscription<List<LedgerEntry>>? _monthSubscription;

  List<LedgerEntry> _records = const [];
  bool _isLoading = true;
  bool _hasLoadError = false;

  /// 원형 섹션에서 고른 달. 12개월 밖일 수도 있어 별도로 조회한다.
  DateTime _selectedMonth = _normalizeMonth(DateTime.now());
  List<LedgerEntry> _monthRecords = const [];
  bool _isMonthLoading = true;

  CurrencyCode? _selectedCurrency;
  CurrencyCode _primaryCurrency = CurrencyCode.krw;
  StatisticsPreferences _preferences = const StatisticsPreferences();
  bool _hasChangedPreferences = false;

  /// 그래프별로 사용자가 고른 달. 그래프끼리 연동되지 않는다.
  DateTime? _selectedTrendMonth;
  final Map<LedgerRecordType, DateTime> _selectedCategoryMonths = {};

  bool get isLoading => _isLoading;
  bool get isMonthLoading => _isMonthLoading;
  DateTime get selectedMonth => _selectedMonth;
  String? errorMessage(AppLocalizations l10n) =>
      _hasLoadError ? l10n.errorLedgerLoadFailed : null;
  StatisticsTrendChartType get trendChartType => _preferences.trendChartType;

  Set<String> hiddenCategories(LedgerRecordType type) =>
      type == LedgerRecordType.expense
          ? _preferences.hiddenExpenseCategories
          : _preferences.hiddenIncomeCategories;

  /// 통화가 다른 금액은 합산할 수 없어서 통계는 한 통화 기준으로 보여준다.
  /// 사용자가 고르지 않았다면 주 통화를, 주 통화 기록이 없으면 기록이 있는 첫 통화를 쓴다.
  CurrencyCode get currency {
    final available = availableCurrencies;
    final selected = _selectedCurrency;
    if (selected != null && available.contains(selected)) return selected;
    if (available.isEmpty || available.contains(_primaryCurrency)) {
      return _primaryCurrency;
    }
    return available.first;
  }

  /// 통계 기간과 원형 섹션에서 고른 달에 기록이 있는 통화 목록(주 통화 우선, 나머지는 선언 순서).
  List<CurrencyCode> get availableCurrencies {
    final codes = <CurrencyCode>{
      for (final record in _records) CurrencyCode.fromCode(record.currencyCode),
      for (final record in _monthRecords)
        CurrencyCode.fromCode(record.currencyCode),
    };
    return codes.toList()..sort((a, b) {
      if (a == _primaryCurrency) return -1;
      if (b == _primaryCurrency) return 1;
      return a.index.compareTo(b.index);
    });
  }

  /// 세 그래프가 공유하는 기간(첫 기록 달 ~ 이번 달).
  List<MonthlyIncomeExpense> get monthlyTrend => buildMonthlyTrend(
    records: _records,
    currency: currency,
    currentMonth: _normalizeMonth(_now()),
  );

  int? get selectedTrendIndex =>
      _indexOrLast(monthlyTrend.length, _selectedTrendMonth);

  List<MonthlyCategoryAmounts> categoryTrend(LedgerRecordType type) {
    return buildCategoryTrend(
      records: _records,
      type: type,
      currency: currency,
      months: [for (final item in monthlyTrend) item.month],
      knownCategories: _categoryCodes(type),
    );
  }

  /// 기간 안에 기록이 있는 카테고리. 카테고리 정의 순서(기타는 마지막)를 따른다.
  List<String> categoriesInRange(LedgerRecordType type) {
    final present = {
      for (final month in categoryTrend(type)) ...month.amounts.keys,
    };
    return [
      for (final code in _categoryOrder(type))
        if (present.contains(code)) code,
    ];
  }

  int? selectedCategoryIndex(LedgerRecordType type) =>
      _indexOrLast(monthlyTrend.length, _selectedCategoryMonths[type]);

  /// 원형 섹션에서 고른 달의 카테고리별 합계(금액 큰 순서).
  List<MapEntry<String, int>> monthCategoryAmounts(LedgerRecordType type) {
    final month = _normalizeMonth(_selectedMonth);
    final amounts =
        buildCategoryTrend(
          records: _monthRecords,
          type: type,
          currency: currency,
          months: [month],
          knownCategories: _categoryCodes(type),
        ).single.amounts;
    return amounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  void start({required DateTime initialMonth, required CurrencyCode primary}) {
    _primaryCurrency = primary;
    _selectedMonth = _normalizeMonth(initialMonth);
    _loadPreferences();
    _watchSelectedMonth();

    final currentMonth = _normalizeMonth(_now());
    final start = DateTime(
      currentMonth.year,
      currentMonth.month - (trendMonthCount - 1),
    );
    final end = DateTime(currentMonth.year, currentMonth.month + 1);
    _subscription?.cancel();
    _subscription = _repository
        .watchRecordsBetween(start, end)
        .listen(
          (records) {
            _records = List.unmodifiable(records);
            _isLoading = false;
            _hasLoadError = false;
            notifyListeners();
          },
          onError: (_) {
            _records = const [];
            _isLoading = false;
            _hasLoadError = true;
            notifyListeners();
          },
        );
  }

  void changeMonth(int delta) {
    selectMonth(DateTime(_selectedMonth.year, _selectedMonth.month + delta));
  }

  void selectMonth(DateTime month) {
    final normalized = _normalizeMonth(month);
    if (normalized == _selectedMonth) return;
    _selectedMonth = normalized;
    _watchSelectedMonth();
  }

  void selectCurrency(CurrencyCode currency) {
    if (_selectedCurrency == currency) return;
    _selectedCurrency = currency;
    notifyListeners();
  }

  void selectTrendIndex(int index) {
    final month = _monthAt(index);
    if (month == null) return;
    _selectedTrendMonth = month;
    notifyListeners();
  }

  void selectCategoryIndex(LedgerRecordType type, int index) {
    final month = _monthAt(index);
    if (month == null) return;
    _selectedCategoryMonths[type] = month;
    notifyListeners();
  }

  void setTrendChartType(StatisticsTrendChartType type) {
    _updatePreferences(_preferences.copyWith(trendChartType: type));
  }

  void setCategoryVisible(
    LedgerRecordType type,
    String category, {
    required bool visible,
  }) {
    final hidden = {...hiddenCategories(type)};
    if (visible) {
      hidden.remove(category);
    } else {
      hidden.add(category);
    }
    _updatePreferences(
      type == LedgerRecordType.expense
          ? _preferences.copyWith(hiddenExpenseCategories: hidden)
          : _preferences.copyWith(hiddenIncomeCategories: hidden),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _monthSubscription?.cancel();
    super.dispose();
  }

  void _watchSelectedMonth() {
    _isMonthLoading = true;
    _monthRecords = const [];
    notifyListeners();

    _monthSubscription?.cancel();
    _monthSubscription = _repository
        .watchMonthlyRecords(_selectedMonth)
        .listen(
          (records) {
            _monthRecords = List.unmodifiable(records);
            _isMonthLoading = false;
            notifyListeners();
          },
          onError: (_) {
            _monthRecords = const [];
            _isMonthLoading = false;
            _hasLoadError = true;
            notifyListeners();
          },
        );
  }

  DateTime? _monthAt(int index) {
    final trend = monthlyTrend;
    if (index < 0 || index >= trend.length) return null;
    return trend[index].month;
  }

  /// 고른 달이 기간 안에 있으면 그 인덱스, 아니면 마지막 달.
  int? _indexOrLast(int length, DateTime? selected) {
    if (length == 0) return null;
    final months = [for (final item in monthlyTrend) item.month];
    final index = months.indexOf(selected ?? months.last);
    return index >= 0 ? index : length - 1;
  }

  Future<void> _loadPreferences() async {
    try {
      final loaded = await _preferencesRepository.load();
      // 불러오는 사이에 사용자가 이미 바꾼 값이 있으면 그 선택을 우선한다.
      if (_hasChangedPreferences) return;
      _preferences = loaded;
      notifyListeners();
    } catch (_) {
      // 저장된 설정을 읽지 못해도 기본값으로 통계는 볼 수 있어야 한다.
    }
  }

  void _updatePreferences(StatisticsPreferences preferences) {
    _hasChangedPreferences = true;
    _preferences = preferences;
    notifyListeners();
    _preferencesRepository.save(preferences).catchError((_) {});
  }

  static List<String> _categoryOrder(LedgerRecordType type) => [
    for (final option
        in type == LedgerRecordType.expense
            ? ledgerExpenseCategoryOptions
            : ledgerIncomeCategoryOptions)
      if (option.code != otherCategoryCode) option.code,
    otherCategoryCode,
  ];

  static Set<String> _categoryCodes(LedgerRecordType type) =>
      _categoryOrder(type).toSet();

  static DateTime _normalizeMonth(DateTime date) =>
      DateTime(date.year, date.month);

  /// 체크된 카테고리 합계 대비 비율(정수 반올림). 합계가 0이면 0.
  static int percentOf(int amount, int total) {
    if (total <= 0) return 0;
    return (amount * 100 / total).round();
  }

  /// [currentMonth]를 끝으로 최대 [trendMonthCount]개월의 월별 합계를 만든다.
  /// 기록이 처음 등장한 달 이전의 빈 달은 잘라내고, 기록이 없으면 빈 목록을 반환한다.
  @visibleForTesting
  static List<MonthlyIncomeExpense> buildMonthlyTrend({
    required List<LedgerEntry> records,
    required CurrencyCode currency,
    required DateTime currentMonth,
  }) {
    final months = [
      for (var offset = trendMonthCount - 1; offset >= 0; offset--)
        DateTime(currentMonth.year, currentMonth.month - offset),
    ];
    final income = <DateTime, int>{};
    final expense = <DateTime, int>{};

    for (final record in records) {
      if (CurrencyCode.fromCode(record.currencyCode) != currency) continue;
      final month = _normalizeMonth(record.date);
      final target = record.type == LedgerRecordType.income ? income : expense;
      target[month] = (target[month] ?? 0) + record.amount;
    }

    final firstIndex = months.indexWhere(
      (month) => income.containsKey(month) || expense.containsKey(month),
    );
    if (firstIndex < 0) return const [];

    return [
      for (final month in months.skip(firstIndex))
        MonthlyIncomeExpense(
          month: month,
          income: income[month] ?? 0,
          expense: expense[month] ?? 0,
        ),
    ];
  }

  /// [months] 각각에 대해 카테고리별 합계를 만든다.
  /// [knownCategories]에 없는 카테고리 코드는 '기타'로 합친다.
  @visibleForTesting
  static List<MonthlyCategoryAmounts> buildCategoryTrend({
    required List<LedgerEntry> records,
    required LedgerRecordType type,
    required CurrencyCode currency,
    required List<DateTime> months,
    required Set<String> knownCategories,
  }) {
    final totals = {for (final month in months) month: <String, int>{}};
    for (final record in records) {
      if (record.type != type) continue;
      if (CurrencyCode.fromCode(record.currencyCode) != currency) continue;
      final byCategory = totals[_normalizeMonth(record.date)];
      if (byCategory == null) continue;
      final category =
          knownCategories.contains(record.category)
              ? record.category
              : otherCategoryCode;
      byCategory[category] = (byCategory[category] ?? 0) + record.amount;
    }
    return [
      for (final month in months)
        MonthlyCategoryAmounts(
          month: month,
          amounts: Map.unmodifiable(totals[month]!),
        ),
    ];
  }
}
