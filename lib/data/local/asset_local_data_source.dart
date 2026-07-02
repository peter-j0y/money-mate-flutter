import 'package:drift/drift.dart';
import 'package:money_mate/data/local/app_database.dart';
import 'package:money_mate/data/model/entities/asset_entry.dart';

class AssetLocalDataSource {
  AssetLocalDataSource({AppDatabase? database})
    : _database = database ?? AppDatabase();

  final AppDatabase _database;

  Future<int> addAsset(AssetEntryDraft draft) {
    return _database.insertAsset(
      AssetsCompanion.insert(
        assetType: draft.assetType.code,
        assetName: draft.assetName,
        amount: draft.amount,
        shares: Value(draft.shares),
        includeInPortfolio: Value(draft.includeInPortfolio),
      ),
    );
  }

  Stream<List<Asset>> watchAssets() {
    return _database.watchAssets();
  }
}
