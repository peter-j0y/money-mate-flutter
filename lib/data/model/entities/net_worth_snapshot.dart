/// 하루치 순자산 스냅샷의 한 행: 자산 유형·통화별 합계.
/// 통화가 다른 금액은 환율 없이 더할 수 없어서 통화별로 따로 저장한다.
class NetWorthSnapshotItem {
  const NetWorthSnapshotItem({
    required this.assetType,
    required this.currencyCode,
    required this.amount,
  });

  final String assetType;
  final String currencyCode;
  final int amount;

  @override
  bool operator ==(Object other) =>
      other is NetWorthSnapshotItem &&
      other.assetType == assetType &&
      other.currencyCode == currencyCode &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(assetType, currencyCode, amount);

  @override
  String toString() =>
      'NetWorthSnapshotItem($assetType, $currencyCode, $amount)';
}
