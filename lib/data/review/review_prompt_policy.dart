/// 자동 리뷰 요청 조건 (기획안 「인앱 리뷰 요청」 R2).
const int reviewPromptMinRecordCount = 7;
const Duration reviewPromptMinUsage = Duration(hours: 72);
const Duration reviewPromptMinInterval = Duration(days: 120);

/// OS 가용성(R2-d)을 제외한 조건을 판단한다. 기준 시각이 없으면 사용 기간을 알 수 없으므로 요청하지 않는다.
bool shouldRequestReview({
  required int recordCount,
  required DateTime? anchorAt,
  required DateTime? lastRequestedAt,
  required DateTime now,
}) {
  if (recordCount < reviewPromptMinRecordCount) return false;
  if (anchorAt == null) return false;
  if (now.difference(anchorAt) < reviewPromptMinUsage) return false;
  if (lastRequestedAt != null &&
      now.difference(lastRequestedAt) < reviewPromptMinInterval) {
    return false;
  }
  return true;
}
