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
  List<LedgerEntry> _monthlyRecords = const [];

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

  Future<void> loadMonth(DateTime month) async {
    final normalizedMonth = DateTime(month.year, month.month);
    _currentMonth = normalizedMonth;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _monthlyRecords = await _repository.fetchMonthlyRecords(normalizedMonth);
    } catch (_) {
      _monthlyRecords = const [];
      _errorMessage = '가계부 내역을 불러오는 중 오류가 발생했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<LedgerEntry> recordsForDate(DateTime date) {
    return _monthlyRecords
        .where(
          (record) =>
              record.date.year == date.year &&
              record.date.month == date.month &&
              record.date.day == date.day,
        )
        .toList(growable: false);
  }
}
