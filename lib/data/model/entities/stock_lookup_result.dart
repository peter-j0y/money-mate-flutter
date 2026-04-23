class StockLookupResult {
  const StockLookupResult({
    required this.code,
    required this.companyName,
    required this.market,
    required this.latestPriceText,
  });

  final String code;
  final String companyName;
  final String market;
  final String latestPriceText;
}
