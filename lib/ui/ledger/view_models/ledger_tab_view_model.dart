import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:money_mate/data/repositories/ledger_record_repository.dart';
import 'package:money_mate/data/repositories/ledger_record_repository_impl.dart';
import 'package:money_mate/l10n/app_localizations.dart';

import '../../../data/model/entities/currency.dart';
import '../../../data/model/entities/ledger_record.dart';

class LedgerTabViewModel extends ChangeNotifier {
  LedgerTabViewModel({LedgerRecordRepository? repository})
    : _repository = repository ?? LedgerRecordRepositoryImpl();

  final LedgerRecordRepository _repository;
  static const int _watchWindowRadius = 1;
  static const int _cacheWindowRadius = 2;

  bool _isLoading = false;
  bool _hasLoadError = false;
  DateTime _currentMonth = DateTime.now();
  final Map<DateTime, StreamSubscription<List<LedgerEntry>>>
  _monthlySubscriptions = {};
  final Map<DateTime, List<LedgerEntry>> _monthlyRecordsByMonth = {};
  final Map<DateTime, Map<DateTime, List<LedgerEntry>>> _recordsByDateByMonth =
      {};
  final Map<DateTime, Map<DateTime, Map<CurrencyCode, int>>>
  _dailyIncomeTotalsByMonth = {};
  final Map<DateTime, Map<DateTime, Map<CurrencyCode, int>>>
  _dailyExpenseTotalsByMonth = {};

  bool get isLoading => _isLoading;
  String? errorMessage(AppLocalizations l10n) =>
      _hasLoadError ? l10n.errorLedgerLoadFailed : null;
  DateTime get currentMonth => _currentMonth;
  List<LedgerEntry> get monthlyRecords =>
      _monthlyRecordsByMonth[_currentMonth] ?? const [];

  /// 통화별 이번 달 수입/지출/저축가능액. 여러 통화가 섞여도
  /// "₩1,000,000 · $200"처럼 통화별로 정확히 표시하기 위한 값이다.
  Map<CurrencyCode, int> get monthlyIncomeTotalsByCurrency => _groupByCurrency(
    _monthlyRecords.where((r) => r.type == LedgerRecordType.income),
  );

  Map<CurrencyCode, int> get monthlyExpenseTotalsByCurrency => _groupByCurrency(
    _monthlyRecords.where((r) => r.type == LedgerRecordType.expense),
  );

  Map<CurrencyCode, int> get monthlySavableTotalsByCurrency {
    final result = <CurrencyCode, int>{...monthlyIncomeTotalsByCurrency};
    monthlyExpenseTotalsByCurrency.forEach((currency, expense) {
      result[currency] = (result[currency] ?? 0) - expense;
    });
    return result;
  }

  Map<CurrencyCode, int> _groupByCurrency(Iterable<LedgerEntry> records) {
    final result = <CurrencyCode, int>{};
    for (final record in records) {
      final currency = CurrencyCode.fromCode(record.currencyCode);
      result[currency] = (result[currency] ?? 0) + record.amount;
    }
    return result;
  }

  Map<DateTime, Map<CurrencyCode, int>> get dailyIncomeTotalsByDate =>
      _dailyIncomeTotalsByMonth[_currentMonth] ?? const {};
  Map<DateTime, Map<CurrencyCode, int>> get dailyExpenseTotalsByDate =>
      _dailyExpenseTotalsByMonth[_currentMonth] ?? const {};

  List<LedgerEntry> get _monthlyRecords =>
      _monthlyRecordsByMonth[_currentMonth] ?? const [];

  Future<void> loadMonth(DateTime month) async {
    final normalizedMonth = DateTime(month.year, month.month);
    _currentMonth = normalizedMonth;
    _hasLoadError = false;
    _isLoading = !_monthlyRecordsByMonth.containsKey(normalizedMonth);
    notifyListeners();

    _ensureWindowSubscriptions(centerMonth: normalizedMonth);
  }

  @override
  void dispose() {
    for (final subscription in _monthlySubscriptions.values) {
      subscription.cancel();
    }
    _monthlySubscriptions.clear();
    super.dispose();
  }

  List<LedgerEntry> recordsForDate(DateTime date) {
    final month = _normalizeMonth(date);
    return _recordsByDateByMonth[month]?[_normalizeDate(date)] ?? const [];
  }

  Map<CurrencyCode, int> incomeTotalsByCurrencyForDate(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    final month = _normalizeMonth(date);
    return _dailyIncomeTotalsByMonth[month]?[normalizedDate] ?? const {};
  }

  Map<CurrencyCode, int> expenseTotalsByCurrencyForDate(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    final month = _normalizeMonth(date);
    return _dailyExpenseTotalsByMonth[month]?[normalizedDate] ?? const {};
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _normalizeMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }

  Set<DateTime> _buildMonthWindow({
    required DateTime centerMonth,
    required int radius,
  }) {
    final months = <DateTime>{};
    for (var delta = -radius; delta <= radius; delta++) {
      months.add(DateTime(centerMonth.year, centerMonth.month + delta));
    }
    return months;
  }

  void _ensureWindowSubscriptions({required DateTime centerMonth}) {
    final watchMonths = _buildMonthWindow(
      centerMonth: centerMonth,
      radius: _watchWindowRadius,
    );

    for (final month in watchMonths) {
      if (_monthlySubscriptions.containsKey(month)) {
        continue;
      }
      _monthlySubscriptions[month] = _repository
          .watchMonthlyRecords(month)
          .listen(
            (records) {
              _updateMonthCaches(month: month, records: records);
              if (_isSameMonth(month, _currentMonth)) {
                _isLoading = false;
                _hasLoadError = false;
              }
              notifyListeners();
            },
            onError: (_) {
              _updateMonthCaches(month: month, records: const []);
              if (_isSameMonth(month, _currentMonth)) {
                _isLoading = false;
                _hasLoadError = true;
              }
              notifyListeners();
            },
          );
    }

    final monthsToUnsubscribe =
        _monthlySubscriptions.keys
            .where((month) => !watchMonths.contains(month))
            .toList();
    for (final month in monthsToUnsubscribe) {
      _monthlySubscriptions.remove(month)?.cancel();
    }

    final cacheMonths = _buildMonthWindow(
      centerMonth: centerMonth,
      radius: _cacheWindowRadius,
    );
    final monthsToRemove =
        _monthlyRecordsByMonth.keys
            .where((month) => !cacheMonths.contains(month))
            .toList();
    for (final month in monthsToRemove) {
      _monthlyRecordsByMonth.remove(month);
      _recordsByDateByMonth.remove(month);
      _dailyIncomeTotalsByMonth.remove(month);
      _dailyExpenseTotalsByMonth.remove(month);
    }
  }

  void _updateMonthCaches({
    required DateTime month,
    required List<LedgerEntry> records,
  }) {
    _monthlyRecordsByMonth[month] = List<LedgerEntry>.unmodifiable(records);

    final recordsByDate = <DateTime, List<LedgerEntry>>{};
    final incomeTotals = <DateTime, Map<CurrencyCode, int>>{};
    final expenseTotals = <DateTime, Map<CurrencyCode, int>>{};

    for (final record in records) {
      final key = _normalizeDate(record.date);
      recordsByDate.putIfAbsent(key, () => <LedgerEntry>[]).add(record);
      final currency = CurrencyCode.fromCode(record.currencyCode);

      if (record.type == LedgerRecordType.income) {
        final byCurrency = incomeTotals.putIfAbsent(key, () => {});
        byCurrency[currency] = (byCurrency[currency] ?? 0) + record.amount;
      } else if (record.type == LedgerRecordType.expense) {
        final byCurrency = expenseTotals.putIfAbsent(key, () => {});
        byCurrency[currency] = (byCurrency[currency] ?? 0) + record.amount;
      }
    }

    _recordsByDateByMonth[month] = recordsByDate.map(
      (key, value) => MapEntry(key, List<LedgerEntry>.unmodifiable(value)),
    );
    _dailyIncomeTotalsByMonth[month] = Map.unmodifiable(incomeTotals);
    _dailyExpenseTotalsByMonth[month] = Map.unmodifiable(expenseTotals);
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}
