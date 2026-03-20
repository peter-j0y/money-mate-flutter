import 'package:flutter/foundation.dart';
import 'package:money_mate/data/repositories/ledger_record_repository_impl.dart';
import 'package:money_mate/data/repositories/ledger_record_repository.dart';

import '../../../data/model/entities/ledger_record.dart';

class AddLedgerRecordViewModel extends ChangeNotifier {
  AddLedgerRecordViewModel({LedgerRecordRepository? repository})
    : _repository = repository ?? LedgerRecordRepositoryImpl();

  final LedgerRecordRepository _repository;

  bool _isSaving = false;
  String? _errorMessage;

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<bool> saveRecord({
    required LedgerRecordType type,
    required String category,
    required int amount,
    required DateTime date,
    String? memo,
  }) async {
    if (amount <= 0) {
      _errorMessage = '금액은 0원보다 커야 합니다.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.addRecord(
        LedgerEntryDraft(
          type: type,
          category: category,
          amount: amount,
          date: date,
          memo: memo,
        ),
      );
      return true;
    } catch (_) {
      _errorMessage = '저장 중 오류가 발생했습니다. 다시 시도해 주세요.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
