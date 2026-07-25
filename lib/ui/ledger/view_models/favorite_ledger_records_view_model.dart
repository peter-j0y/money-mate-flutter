import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:money_mate/data/repositories/favorite_ledger_record_repository.dart';
import 'package:money_mate/data/repositories/favorite_ledger_record_repository_impl.dart';

import '../../../data/model/entities/favorite_ledger_record.dart';

class FavoriteLedgerRecordsViewModel extends ChangeNotifier {
  FavoriteLedgerRecordsViewModel({FavoriteLedgerRecordRepository? repository})
    : _repository = repository ?? FavoriteLedgerRecordRepositoryImpl() {
    _subscribe();
  }

  final FavoriteLedgerRecordRepository _repository;
  StreamSubscription<List<FavoriteLedgerEntry>>? _subscription;

  bool _isLoading = true;
  String? _errorMessage;
  List<FavoriteLedgerEntry> _records = const [];
  bool _isDeleting = false;
  String? _actionErrorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<FavoriteLedgerEntry> get records => _records;
  bool get isAtLimit => _records.length >= maxFavoriteLedgerRecordCount;
  bool get isDeleting => _isDeleting;
  String? get actionErrorMessage => _actionErrorMessage;

  Future<bool> deleteFavorites(Set<int> ids) async {
    _isDeleting = true;
    _actionErrorMessage = null;
    notifyListeners();

    try {
      for (final id in ids) {
        await _repository.deleteFavorite(id);
      }
      return true;
    } catch (_) {
      _actionErrorMessage = '삭제 중 오류가 발생했습니다. 다시 시도해 주세요.';
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  void _subscribe() {
    _subscription = _repository.watchFavoriteRecords().listen(
      (records) {
        _records = records;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        _errorMessage = '즐겨찾기 목록을 불러오는 중 오류가 발생했습니다.';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
