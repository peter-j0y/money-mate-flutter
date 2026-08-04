import 'package:flutter/foundation.dart';
import 'package:money_mate/data/model/entities/asset_entry.dart';
import 'package:money_mate/data/model/entities/currency.dart';
import 'package:money_mate/data/repositories/asset_repository.dart';
import 'package:money_mate/data/repositories/asset_repository_impl.dart';
import 'package:money_mate/data/repositories/portfolio_target_repository.dart';
import 'package:money_mate/data/repositories/portfolio_target_repository_impl.dart';
import 'package:money_mate/l10n/app_localizations.dart';

enum _AddAssetError {
  emptyName,
  invalidAmount,
  invalidShares,
  saveFailed,
  updateNotFound,
  updateFailed,
}

class AddAssetViewModel extends ChangeNotifier {
  AddAssetViewModel({
    AssetRepository? assetRepository,
    PortfolioTargetRepository? portfolioTargetRepository,
  }) : _assetRepository = assetRepository ?? AssetRepositoryImpl(),
       _portfolioTargetRepository =
           portfolioTargetRepository ?? PortfolioTargetRepositoryImpl() {
    _loadPortfolioTargets();
  }

  final AssetRepository _assetRepository;
  final PortfolioTargetRepository _portfolioTargetRepository;

  bool _isSaving = false;
  _AddAssetError? _errorKind;
  Map<AssetType, PortfolioTargetEntry> _targetMap = {};

  bool get isSaving => _isSaving;

  String? errorMessage(AppLocalizations l10n) {
    switch (_errorKind) {
      case _AddAssetError.emptyName:
        return l10n.errorAssetNameRequired;
      case _AddAssetError.invalidAmount:
        return l10n.errorAmountMustBePositive;
      case _AddAssetError.invalidShares:
        return l10n.errorSharesMustBePositive;
      case _AddAssetError.saveFailed:
        return l10n.errorAssetSaveFailed;
      case _AddAssetError.updateNotFound:
        return l10n.errorAssetNotFound;
      case _AddAssetError.updateFailed:
        return l10n.errorAssetUpdateFailed;
      case null:
        return null;
    }
  }

  bool isCategoryInPortfolio(AssetType type) {
    final target = _targetMap[type];
    return target?.isEnabled ?? false;
  }

  Future<void> _loadPortfolioTargets() async {
    final targets = await _portfolioTargetRepository.getTargets();
    _targetMap = {for (final t in targets) t.assetType: t};
    notifyListeners();
  }

  Future<void> refreshPortfolioTargets() async {
    await _loadPortfolioTargets();
  }

  Future<bool> saveAsset({
    required AssetType assetType,
    required String assetName,
    required int amount,
    double? shares,
    required bool includeInPortfolio,
  }) async {
    if (!_validate(assetName: assetName, amount: amount, shares: shares)) {
      return false;
    }

    _isSaving = true;
    _errorKind = null;
    notifyListeners();

    try {
      await _assetRepository.addAsset(
        AssetEntryDraft(
          assetType: assetType,
          assetName: assetName.trim(),
          amount: amount,
          // 자산 입력 화면은 환율 연동 전까지 원화로만 입력을 받으므로
          // (add_asset_screen.dart의 _activeCurrency 참고), 저장 통화도
          // 사용자의 주 통화가 아닌 KRW로 고정한다.
          currencyCode: CurrencyCode.krw.isoCode,
          shares: shares,
          includeInPortfolio: includeInPortfolio,
        ),
      );
      return true;
    } catch (_) {
      _errorKind = _AddAssetError.saveFailed;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateAsset({
    required int id,
    required AssetType assetType,
    required String assetName,
    required int amount,
    required String currencyCode,
    double? shares,
    required bool includeInPortfolio,
  }) async {
    if (!_validate(assetName: assetName, amount: amount, shares: shares)) {
      return false;
    }

    _isSaving = true;
    _errorKind = null;
    notifyListeners();

    try {
      final updated = await _assetRepository.replaceAsset(
        id,
        AssetEntryDraft(
          assetType: assetType,
          assetName: assetName.trim(),
          amount: amount,
          currencyCode: currencyCode,
          shares: shares,
          includeInPortfolio: includeInPortfolio,
        ),
      );
      if (!updated) {
        _errorKind = _AddAssetError.updateNotFound;
      }
      return updated;
    } catch (_) {
      _errorKind = _AddAssetError.updateFailed;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  bool _validate({
    required String assetName,
    required int amount,
    double? shares,
  }) {
    if (assetName.trim().isEmpty) {
      _errorKind = _AddAssetError.emptyName;
      notifyListeners();
      return false;
    }
    if (amount <= 0) {
      _errorKind = _AddAssetError.invalidAmount;
      notifyListeners();
      return false;
    }
    if (shares != null && shares <= 0) {
      _errorKind = _AddAssetError.invalidShares;
      notifyListeners();
      return false;
    }
    return true;
  }
}
