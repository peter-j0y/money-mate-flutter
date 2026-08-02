import 'package:drift/drift.dart';
import 'package:money_mate/data/local/app_database.dart';
import 'package:money_mate/data/local/db_crashlytics_logger.dart';
import 'package:money_mate/data/model/entities/asset_entry.dart';

class AssetLocalDataSource {
  AssetLocalDataSource({AppDatabase? database})
    : _database = database ?? AppDatabase();

  final AppDatabase _database;

  Future<int> addAsset(AssetEntryDraft draft) {
    return logDbErrors(
      'Asset.add',
      () => _database.insertAsset(
        AssetsCompanion.insert(
          assetType: draft.assetType.code,
          assetName: draft.assetName,
          amount: draft.amount,
          currencyCode: Value(draft.currencyCode),
          shares: Value(draft.shares),
          includeInPortfolio: Value(draft.includeInPortfolio),
        ),
      ),
      context: {'assetType': draft.assetType.code},
    );
  }

  Stream<List<Asset>> watchAssets() {
    return logDbStreamErrors('Asset.watch', () => _database.watchAssets());
  }

  Future<bool> replaceAsset(int id, AssetEntryDraft draft) {
    return logDbErrors(
      'Asset.replace',
      () => _database.replaceAsset(
        id,
        AssetsCompanion(
          assetType: Value(draft.assetType.code),
          assetName: Value(draft.assetName),
          amount: Value(draft.amount),
          currencyCode: Value(draft.currencyCode),
          shares: Value(draft.shares),
          includeInPortfolio: Value(draft.includeInPortfolio),
        ),
      ),
      context: {'id': id, 'assetType': draft.assetType.code},
    );
  }

  Future<bool> deleteAsset(int id) {
    return logDbErrors(
      'Asset.delete',
      () => _database.deleteAsset(id),
      context: {'id': id},
    );
  }
}
