import 'package:money_mate/data/model/entities/stock_lookup_result.dart';
import 'package:money_mate/data/repositories/stock_lookup_repository.dart';

class StockLookupRepositoryImpl implements StockLookupRepository {
  static const Map<String, StockLookupResult> _mockCatalog = {
    '005930': StockLookupResult(
      code: '005930',
      companyName: '삼성전자',
      market: 'KRX',
      latestPriceText: '₩81,500',
    ),
    '000660': StockLookupResult(
      code: '000660',
      companyName: 'SK하이닉스',
      market: 'KRX',
      latestPriceText: '₩214,000',
    ),
    'AAPL': StockLookupResult(
      code: 'AAPL',
      companyName: 'Apple Inc.',
      market: 'NASDAQ',
      latestPriceText: '\$189.30',
    ),
    'MSFT': StockLookupResult(
      code: 'MSFT',
      companyName: 'Microsoft Corporation',
      market: 'NASDAQ',
      latestPriceText: '\$420.55',
    ),
    'SPY': StockLookupResult(
      code: 'SPY',
      companyName: 'SPDR S&P 500 ETF Trust',
      market: 'NYSE ARCA',
      latestPriceText: '\$510.23',
    ),
  };

  @override
  Future<StockLookupResult?> lookupByCode(String code) async {
    // TODO(seungmin): 실제 종목 조회 API 연동 시 이 mock 데이터를 대체하세요.
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return _mockCatalog[code.toUpperCase()];
  }
}
