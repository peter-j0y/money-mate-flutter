enum AssetType {
  stock,
  cash,
  realEstate,
  crypto,
  savings,
  commodity,
  other;

  String get code {
    switch (this) {
      case AssetType.stock:
        return 'stock';
      case AssetType.cash:
        return 'cash';
      case AssetType.realEstate:
        return 'real_estate';
      case AssetType.crypto:
        return 'crypto';
      case AssetType.savings:
        return 'savings';
      case AssetType.commodity:
        return 'commodity';
      case AssetType.other:
        return 'other';
    }
  }
}

class AssetEntryDraft {
  const AssetEntryDraft({
    required this.assetType,
    required this.assetName,
    required this.amount,
    this.shares,
    required this.includeInPortfolio,
  });

  final AssetType assetType;
  final String assetName;
  final int amount;
  final double? shares;
  final bool includeInPortfolio;
}
