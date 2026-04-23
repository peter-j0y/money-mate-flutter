import 'package:flutter/foundation.dart';
import 'package:money_mate/data/local/asset_local_data_source.dart';
import 'package:money_mate/data/model/entities/asset_entry.dart';
import 'package:money_mate/data/model/entities/stock_lookup_result.dart';
import 'package:money_mate/data/repositories/stock_lookup_repository.dart';
import 'package:money_mate/data/repositories/stock_lookup_repository_impl.dart';

class AddAssetViewModel extends ChangeNotifier {
  AddAssetViewModel({
    AssetLocalDataSource? localDataSource,
    StockLookupRepository? stockLookupRepository,
  }) : _localDataSource = localDataSource ?? AssetLocalDataSource(),
       _stockLookupRepository =
           stockLookupRepository ?? StockLookupRepositoryImpl();

  final AssetLocalDataSource _localDataSource;
  final StockLookupRepository _stockLookupRepository;

  bool _isSaving = false;
  String? _errorMessage;

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<StockLookupResult?> lookupStockByCode(String code) {
    return _stockLookupRepository.lookupByCode(code);
  }

  Future<bool> saveAsset({
    required AssetType assetType,
    required String assetName,
    required int amount,
    double? shares,
    required bool includeInPortfolio,
  }) async {
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

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _localDataSource.addAsset(
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
}
