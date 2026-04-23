import 'package:money_mate/data/model/entities/stock_lookup_result.dart';

abstract class StockLookupRepository {
  Future<StockLookupResult?> lookupByCode(String code);
}
