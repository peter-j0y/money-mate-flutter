abstract class ReviewPromptRepository {
  /// 사용 기간(72시간)을 재는 기준 시각. 아직 정해지지 않았으면 null.
  Future<DateTime?> getAnchorAt();
  Future<void> setAnchorAt(DateTime value);

  /// 자동 요청 또는 수동 메뉴로 마지막으로 리뷰를 요청한 시각. 없으면 null.
  Future<DateTime?> getLastRequestedAt();
  Future<void> setLastRequestedAt(DateTime value);
}
