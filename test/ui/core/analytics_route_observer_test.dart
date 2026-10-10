import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_mate/data/analytics/analytics_events.dart';
import 'package:money_mate/data/analytics/analytics_service.dart';
import 'package:money_mate/ui/core/analytics/analytics_route_observer.dart';

class _RecordingAnalyticsService implements AnalyticsService {
  final List<AnalyticsScreen> screens = [];

  @override
  Future<void> logScreenView(AnalyticsScreen screen) async {
    screens.add(screen);
  }

  @override
  Future<void> logButtonClick(
    AnalyticsButton button, {
    Map<String, Object>? parameters,
  }) async {}
}

void main() {
  late _RecordingAnalyticsService analytics;

  setUp(() {
    analytics = _RecordingAnalyticsService();
    AnalyticsService.instance = analytics;
  });

  tearDown(() {
    AnalyticsService.instance = const NoopAnalyticsService();
  });

  testWidgets('이름 붙은 페이지 진입과 복귀는 기록하고 다이얼로그는 무시한다', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [AnalyticsRouteObserver()],
        home: const SizedBox(),
      ),
    );
    expect(analytics.screens, isEmpty);

    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        settings: AnalyticsScreen.assetDetail.routeSettings,
        builder: (_) => const SizedBox(),
      ),
    );
    await tester.pumpAndSettle();
    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        settings: AnalyticsScreen.editAsset.routeSettings,
        builder: (_) => const SizedBox(),
      ),
    );
    await tester.pumpAndSettle();

    showDialog<void>(
      context: navigatorKey.currentContext!,
      builder: (_) => const SizedBox(),
    );
    await tester.pumpAndSettle();
    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    expect(analytics.screens, [
      AnalyticsScreen.assetDetail,
      AnalyticsScreen.editAsset,
      AnalyticsScreen.assetDetail,
    ]);
  });
}
