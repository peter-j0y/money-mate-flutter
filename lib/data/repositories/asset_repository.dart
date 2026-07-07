import '../local/app_database.dart';
import '../model/entities/asset_entry.dart';

abstract class AssetRepository {
  Future<int> addAsset(AssetEntryDraft draft);
  Future<bool> replaceAsset(int id, AssetEntryDraft draft);
  Future<bool> deleteAsset(int id);
  Stream<List<Asset>> watchAssets();
}
