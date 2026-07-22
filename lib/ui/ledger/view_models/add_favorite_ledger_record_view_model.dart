import 'package:flutter/foundation.dart';
import 'package:money_mate/data/repositories/favorite_ledger_record_repository.dart';
import 'package:money_mate/data/repositories/favorite_ledger_record_repository_impl.dart';

import '../../../data/model/entities/favorite_ledger_record.dart';
import '../../../data/model/entities/ledger_record.dart';

class AddFavoriteLedgerRecordViewModel extends ChangeNotifier {
  AddFavoriteLedgerRecordViewModel({FavoriteLedgerRecordRepository? repository})
    : _repository = repository ?? FavoriteLedgerRecordRepositoryImpl();

  final FavoriteLedgerRecordRepository _repository;

  bool _isSaving = false;
  String? _errorMessage;

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<bool> saveFavorite({
    required LedgerRecordType type,
    required String category,
    required int amount,
    ExpensePaymentMethod? paymentMethod,
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
      await _repository.addFavorite(
        FavoriteLedgerEntryDraft(
          type: type,
          category: category,
          amount: amount,
          paymentMethod: paymentMethod,
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