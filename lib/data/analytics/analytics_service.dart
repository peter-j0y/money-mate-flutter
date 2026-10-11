import 'package:money_mate/data/analytics/analytics_events.dart';

/// 화면 진입·버튼 클릭 이벤트를 기록하는 추상 인터페이스.
///
/// 기본값은 아무것도 기록하지 않는 [NoopAnalyticsService]이며, 앱 시작 시
/// `main`에서 Firebase 구현체로 교체한다. 덕분에 위젯 테스트처럼 Firebase를
/// 초기화하지 않는 환경에서도 로깅 호출이 안전하다.
abstract class AnalyticsService {
  static AnalyticsService instance = const NoopAnalyticsService();

  Future<void> logScreenView(AnalyticsScreen screen);

  Future<void> logButtonClick(
    AnalyticsButton button, {
    Map<String, Object>? parameters,
  });
}

class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> logScreenView(AnalyticsScreen screen) async {}

  @override
  Future<void> logButtonClick(
    AnalyticsButton button, {
    Map<String, Object>? parameters,
  }) async {}
}
