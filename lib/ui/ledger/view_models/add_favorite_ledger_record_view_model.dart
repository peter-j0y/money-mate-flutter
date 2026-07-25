import 'package:flutter/foundation.dart';
import 'package:money_mate/data/repositories/favorite_ledger_record_repository.dart';
import 'package:money_mate/data/repositories/favorite_ledger_record_repository_impl.dart';
import 'package:money_mate/data/repositories/ledger_record_repository.dart';
import 'package:money_mate/data/repositories/ledger_record_repository_impl.dart';

import '../../../data/model/entities/favorite_ledger_record.dart';
import '../../../data/model/entities/ledger_record.dart';

class AddFavoriteLedgerRecordViewModel extends ChangeNotifier {
  AddFavoriteLedgerRecordViewModel({
    LedgerRecordRepository? ledgerRecordRepository,
    FavoriteLedgerRecordRepository? favoriteRecordRepository,
  }) : _ledgerRecordRepository =
           ledgerRecordRepository ?? LedgerRecordRepositoryImpl(),
       _favoriteRecordRepository =
           favoriteRecordRepository ?? FavoriteLedgerRecordRepositoryImpl();

  static const int _pageSize = 20;

  final LedgerRecordRepository _ledgerRecordRepository;
  final FavoriteLedgerRecordRepository _favoriteRecordRepository;

  final List<LedgerEntry> _records = [];

  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isAdding = false;
  String? _errorMessage;

  List<LedgerEntry> get records => List.unmodifiable(_records);
  bool get isLoadingInitial => _isLoadingInitial;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  bool get isAdding => _isAdding;
  String? get errorMessage => _errorMessage;

  Future<void> loadInitial() async {
    _isLoadingInitial = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final page = await _ledgerRecordRepository.fetchRecordsPage(
        limit: _pageSize,
        offset: 0,
      );
      _records
        ..clear()
        ..addAll(page);
      _hasMore = page.length == _pageSize;
    } catch (_) {
      _errorMessage = '가계부 기록을 불러오지 못했습니다. 다시 시도해 주세요.';
    } finally {
      _isLoadingInitial = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingInitial || _isLoadingMore || !_hasMore) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final page = await _ledgerRecordRepository.fetchRecordsPage(
        limit: _pageSize,
        offset: _records.length,
      );
      _records.addAll(page);
      _hasMore = page.length == _pageSize;
    } catch (_) {
      _errorMessage = '가계부 기록을 불러오지 못했습니다. 다시 시도해 주세요.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<bool> addToFavorite(LedgerEntry entry) async {
    _isAdding = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _favoriteRecordRepository.addFavorite(
        FavoriteLedgerEntryDraft(
          type: entry.type,
          category: entry.category,
          amount: entry.amount,
          paymentMethod: entry.paymentMethod,
          memo: entry.memo,
        ),
      );
      return true;
    } catch (_) {
      _errorMessage = '즐겨찾기 추가 중 오류가 발생했습니다. 다시 시도해 주세요.';
      return false;
    } finally {
      _isAdding = false;
      notifyListeners();
    }
  }
}
