import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:money_mate/data/analytics/analytics_events.dart';
import 'package:money_mate/data/analytics/analytics_service.dart';

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService({FirebaseAnalytics? analytics})
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logScreenView(AnalyticsScreen screen) {
    return _guard(
      () => _analytics.logScreenView(
        screenName: screen.screenName,
        screenClass: screen.screenName,
      ),
    );
  }

  @override
  Future<void> logButtonClick(
    AnalyticsButton button, {
    Map<String, Object>? parameters,
  }) {
    return _guard(
      () => _analytics.logEvent(name: button.eventName, parameters: parameters),
    );
  }

  /// 분석 이벤트 실패가 사용자 동작(저장, 화면 이동 등)을 막지 않도록 예외를 삼킨다.
  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {}
  }
}
