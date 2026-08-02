import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:money_mate/data/repositories/favorite_ledger_record_repository.dart';
import 'package:money_mate/data/repositories/favorite_ledger_record_repository_impl.dart';
import 'package:money_mate/l10n/app_localizations.dart';

import '../../../data/model/entities/favorite_ledger_record.dart';

class FavoriteLedgerRecordsViewModel extends ChangeNotifier {
  FavoriteLedgerRecordsViewModel({FavoriteLedgerRecordRepository? repository})
    : _repository = repository ?? FavoriteLedgerRecordRepositoryImpl() {
    _subscribe();
  }

  final FavoriteLedgerRecordRepository _repository;
  StreamSubscription<List<FavoriteLedgerEntry>>? _subscription;

  bool _isLoading = true;
  bool _hasLoadError = false;
  List<FavoriteLedgerEntry> _records = const [];
  bool _isDeleting = false;
  bool _hasActionError = false;

  bool get isLoading => _isLoading;
  String? errorMessage(AppLocalizations l10n) =>
      _hasLoadError ? l10n.errorFavoriteListLoadFailed : null;
  List<FavoriteLedgerEntry> get records => _records;
  bool get isAtLimit => _records.length >= maxFavoriteLedgerRecordCount;
  bool get isDeleting => _isDeleting;
  String? actionErrorMessage(AppLocalizations l10n) =>
      _hasActionError ? l10n.errorDeleteFailedRetry : null;

  Future<bool> deleteFavorites(Set<int> ids) async {
    _isDeleting = true;
    _hasActionError = false;
    notifyListeners();

    try {
      for (final id in ids) {
        await _repository.deleteFavorite(id);
      }
      return true;
    } catch (_) {
      _hasActionError = true;
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
        _hasLoadError = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        _hasLoadError = true;
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
