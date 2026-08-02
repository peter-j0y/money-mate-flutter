import 'package:flutter/foundation.dart';
import 'package:money_mate/data/repositories/ledger_record_repository_impl.dart';
import 'package:money_mate/data/repositories/ledger_record_repository.dart';
import 'package:money_mate/l10n/app_localizations.dart';

import '../../../data/model/entities/ledger_record.dart';

enum _AddLedgerRecordError { invalidAmount, saveFailed }

class AddLedgerRecordViewModel extends ChangeNotifier {
  AddLedgerRecordViewModel({LedgerRecordRepository? repository})
    : _repository = repository ?? LedgerRecordRepositoryImpl();

  final LedgerRecordRepository _repository;

  bool _isSaving = false;
  _AddLedgerRecordError? _errorKind;

  bool get isSaving => _isSaving;

  String? errorMessage(AppLocalizations l10n) {
    switch (_errorKind) {
      case _AddLedgerRecordError.invalidAmount:
        return l10n.errorAmountMustBePositive;
      case _AddLedgerRecordError.saveFailed:
        return l10n.errorSaveFailedRetry;
      case null:
        return null;
    }
  }

  Future<bool> saveRecord({
    required LedgerRecordType type,
    required String category,
    required int amount,
    required String currencyCode,
    required DateTime date,
    ExpensePaymentMethod? paymentMethod,
    String? memo,
  }) async {
    if (amount <= 0) {
      _errorKind = _AddLedgerRecordError.invalidAmount;
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorKind = null;
    notifyListeners();

    try {
      await _repository.addRecord(
        LedgerEntryDraft(
          type: type,
          category: category,
          amount: amount,
          currencyCode: currencyCode,
          date: date,
          paymentMethod: paymentMethod,
          memo: memo,
        ),
      );
      return true;
    } catch (_) {
      _errorKind = _AddLedgerRecordError.saveFailed;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
