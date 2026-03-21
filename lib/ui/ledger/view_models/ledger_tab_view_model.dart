import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:money_mate/data/repositories/ledger_record_repository.dart';
import 'package:money_mate/data/repositories/ledger_record_repository_impl.dart';

import '../../../data/model/entities/ledger_record.dart';

class LedgerTabViewModel extends ChangeNotifier {
  LedgerTabViewModel({LedgerRecordRepository? repository})
    : _repository = repository ?? LedgerRecordRepositoryImpl();

  final LedgerRecordRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  DateTime _currentMonth = DateTime.now();
  StreamSubscription<List<LedgerEntry>>? _monthlyRecordsSubscription;
  List<LedgerEntry> _monthlyRecords = const [];
  Map<DateTime, List<LedgerEntry>> _recordsByDate = const {};
  Map<DateTime, int> _dailyIncomeTotalsByDate = const {};
  Map<DateTime, int> _dailyExpenseTotalsByDate = const {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get currentMonth => _currentMonth;
  List<LedgerEntry> get monthlyRecords => _monthlyRecords;

  int get monthlyIncomeTotal => _monthlyRecords
      .where((record) => record.type == LedgerRecordType.income)
      .fold(0, (sum, record) => sum + record.amount);
  int get monthlyExpenseTotal => _monthlyRecords
      .where((record) => record.type == LedgerRecordType.expense)
      .fold(0, (sum, record) => sum + record.amount);
  int get monthlySavableTotal => monthlyIncomeTotal - monthlyExpenseTotal;

  Map<DateTime, int> get dailyIncomeTotalsByDate => _dailyIncomeTotalsByDate;
  Map<DateTime, int> get dailyExpenseTotalsByDate => _dailyExpenseTotalsByDate;

  Future<void> loadMonth(DateTime month) async {
    final normalizedMonth = DateTime(month.year, month.month);
    _currentMonth = normalizedMonth;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await _monthlyRecordsSubscription?.cancel();
    _monthlyRecordsSubscription = _repository
        .watchMonthlyRecords(normalizedMonth)
        .listen(
          (records) {
            _monthlyRecords = records;
            _rebuildDailyCaches();
            _errorMessage = null;
            _isLoading = false;
            notifyListeners();
          },
          onError: (_) {
            _monthlyRecords = const [];
            _clearDailyCaches();
            _errorMessage = '가계부 내역을 불러오는 중 오류가 발생했습니다.';
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _monthlyRecordsSubscription?.cancel();
    _monthlyRecordsSubscription = null;
    super.dispose();
  }

  List<LedgerEntry> recordsForDate(DateTime date) {
    return _recordsByDate[_normalizeDate(date)] ?? const [];
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _rebuildDailyCaches() {
    final recordsByDate = <DateTime, List<LedgerEntry>>{};
    final incomeTotals = <DateTime, int>{};
    final expenseTotals = <DateTime, int>{};

    for (final record in _monthlyRecords) {
      final key = _normalizeDate(record.date);
      recordsByDate.putIfAbsent(key, () => <LedgerEntry>[]).add(record);

      if (record.type == LedgerRecordType.income) {
        incomeTotals[key] = (incomeTotals[key] ?? 0) + record.amount;
      } else if (record.type == LedgerRecordType.expense) {
        expenseTotals[key] = (expenseTotals[key] ?? 0) + record.amount;
      }
    }

    _recordsByDate = recordsByDate.map(
      (key, value) => MapEntry(key, List<LedgerEntry>.unmodifiable(value)),
    );
    _dailyIncomeTotalsByDate = Map.unmodifiable(incomeTotals);
    _dailyExpenseTotalsByDate = Map.unmodifiable(expenseTotals);
  }

  void _clearDailyCaches() {
    _recordsByDate = const {};
    _dailyIncomeTotalsByDate = const {};
    _dailyExpenseTotalsByDate = const {};
  }
}
