import 'package:flutter/foundation.dart';
import 'package:money_mate/data/repositories/favorite_ledger_record_repository.dart';
import 'package:money_mate/data/repositories/favorite_ledger_record_repository_impl.dart';
import 'package:money_mate/data/repositories/ledger_record_repository.dart';
import 'package:money_mate/data/repositories/ledger_record_repository_impl.dart';
import 'package:money_mate/l10n/app_localizations.dart';

import '../../../data/model/entities/favorite_ledger_record.dart';
import '../../../data/model/entities/ledger_record.dart';

enum _AddFavoriteError { loadFailed, limitExceeded, addFailed }

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
  _AddFavoriteError? _errorKind;

  List<LedgerEntry> get records => List.unmodifiable(_records);
  bool get isLoadingInitial => _isLoadingInitial;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  bool get isAdding => _isAdding;

  String? errorMessage(AppLocalizations l10n) {
    switch (_errorKind) {
      case _AddFavoriteError.loadFailed:
        return l10n.errorLoadLedgerRecordsFailed;
      case _AddFavoriteError.limitExceeded:
        return l10n.errorFavoriteLimitExceeded(maxFavoriteLedgerRecordCount);
      case _AddFavoriteError.addFailed:
        return l10n.errorAddFavoriteFailed;
      case null:
        return null;
    }
  }

  Future<void> loadInitial() async {
    _isLoadingInitial = true;
    _errorKind = null;
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
      _errorKind = _AddFavoriteError.loadFailed;
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
      _errorKind = _AddFavoriteError.loadFailed;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<bool> addToFavorite(LedgerEntry entry) async {
    _isAdding = true;
    _errorKind = null;
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
    } on FavoriteLedgerRecordLimitExceededException {
      _errorKind = _AddFavoriteError.limitExceeded;
      return false;
    } catch (_) {
      _errorKind = _AddFavoriteError.addFailed;
      return false;
    } finally {
      _isAdding = false;
      notifyListeners();
    }
  }
}
