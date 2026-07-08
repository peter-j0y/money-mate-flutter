import 'package:flutter/foundation.dart';
import 'package:money_mate/data/model/entities/asset_entry.dart';
import 'package:money_mate/data/repositories/asset_repository.dart';
import 'package:money_mate/data/repositories/asset_repository_impl.dart';
import 'package:money_mate/data/repositories/portfolio_target_repository.dart';
import 'package:money_mate/data/repositories/portfolio_target_repository_impl.dart';

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
  String? _errorMessage;
  Map<AssetType, PortfolioTargetEntry> _targetMap = {};

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

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
    _errorMessage = null;
    notifyListeners();

    try {
      await _assetRepository.addAsset(
        AssetEntryDraft(
          assetType: assetType,
          assetName: assetName.trim(),
          amount: amount,
          shares: shares,
          includeInPortfolio: includeInPortfolio,
        ),
      );
      return true;
    } catch (_) {
      _errorMessage = '자산 저장 중 오류가 발생했습니다. 다시 시도해 주세요.';
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
    double? shares,
    required bool includeInPortfolio,
  }) async {
    if (!_validate(assetName: assetName, amount: amount, shares: shares)) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _assetRepository.replaceAsset(
        id,
        AssetEntryDraft(
          assetType: assetType,
          assetName: assetName.trim(),
          amount: amount,
          shares: shares,
          includeInPortfolio: includeInPortfolio,
        ),
      );
      if (!updated) {
        _errorMessage = '수정할 자산을 찾지 못했어요.';
      }
      return updated;
    } catch (_) {
      _errorMessage = '자산 수정 중 오류가 발생했습니다. 다시 시도해 주세요.';
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
      _errorMessage = '자산명을 입력해 주세요.';
      notifyListeners();
      return false;
    }
    if (amount <= 0) {
      _errorMessage = '금액은 0원보다 커야 합니다.';
      notifyListeners();
      return false;
    }
    if (shares != null && shares <= 0) {
      _errorMessage = '주수는 0보다 커야 합니다.';
      notifyListeners();
      return false;
    }
    return true;
  }
}
