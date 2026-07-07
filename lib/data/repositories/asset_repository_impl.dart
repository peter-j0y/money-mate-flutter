import 'package:money_mate/data/local/app_database.dart';
import 'package:money_mate/data/local/asset_local_data_source.dart';
import 'package:money_mate/data/repositories/asset_repository.dart';

import '../model/entities/asset_entry.dart';

class AssetRepositoryImpl implements AssetRepository {
  AssetRepositoryImpl({AssetLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? AssetLocalDataSource();

  final AssetLocalDataSource _localDataSource;

  @override
  Future<int> addAsset(AssetEntryDraft draft) {
    return _localDataSource.addAsset(draft);
  }

  @override
  Future<bool> replaceAsset(int id, AssetEntryDraft draft) {
    return _localDataSource.replaceAsset(id, draft);
  }

  @override
  Future<bool> deleteAsset(int id) {
    return _localDataSource.deleteAsset(id);
  }

  @override
  Stream<List<Asset>> watchAssets() {
    return _localDataSource.watchAssets();
  }
}
