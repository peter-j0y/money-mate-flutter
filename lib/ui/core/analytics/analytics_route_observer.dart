import 'package:flutter/widgets.dart';
import 'package:money_mate/data/analytics/analytics_events.dart';
import 'package:money_mate/data/analytics/analytics_service.dart';

extension AnalyticsScreenRoute on AnalyticsScreen {
  RouteSettings get routeSettings => RouteSettings(name: screenName);
}

/// 앱 전체에서 공유하는 라우트 옵저버. `MaterialApp.navigatorObservers`에 등록하고,
/// 홈 화면은 `RouteAware`로 구독해 하위 화면에서 돌아왔을 때 현재 탭을 다시 기록한다.
final AnalyticsRouteObserver analyticsRouteObserver = AnalyticsRouteObserver();

/// [AnalyticsScreen] 이름이 붙은 페이지 라우트의 진입을 기록한다.
///
/// 이름 없는 라우트(다이얼로그, 바텀시트, 홈 `/`)는 무시한다. 하단 탭 전환은
/// 라우트가 바뀌지 않으므로 `HomeScreen`에서 직접 기록한다.
class AnalyticsRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  void _log(Route<dynamic>? route) {
    if (route is! PageRoute) {
      return;
    }
    final name = route.settings.name;
    for (final screen in AnalyticsScreen.values) {
      if (screen.screenName == name) {
        AnalyticsService.instance.logScreenView(screen);
        return;
      }
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _log(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _log(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // 다이얼로그가 닫힐 때는 아래 화면이 그대로 보이고 있었으므로 다시 기록하지 않는다.
    if (route is PageRoute) {
      _log(previousRoute);
    }
  }
}
