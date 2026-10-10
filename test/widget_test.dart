import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Bottom navigation switches tab content', (
    WidgetTester tester,
  ) async {
    // 앱은 기기 로케일로 언어를 고르므로 한국어 기기로 고정한다.
    tester.platformDispatcher.localeTestValue = const Locale('ko', 'KR');
    tester.platformDispatcher.localesTestValue = const [Locale('ko', 'KR')];
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    // 첫 실행 알림 권한 팝업이 탭 전환을 가리지 않도록 이미 요청한 상태로 시작한다.
    SharedPreferences.setMockInitialValues({
      'notification_permission_requested': true,
    });
    // 테스트에는 path_provider 플러그인이 없으므로 빈 임시 폴더에 DB를 만든다.
    final documentsDir = Directory.systemTemp.createTempSync('money_mate_test');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => documentsDir.path,
    );
    // 더보기 탭의 알림 카드가 권한 상태를 조회하므로 '권한 없음(0)'으로 응답한다.
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      (call) async => 0,
    );

    final l10n = lookupAppLocalizations(const Locale('ko'));
    final now = DateTime.now();

    Future<void> waitForDatabase() async {
      // DB는 백그라운드 isolate에서 열리고 결과도 여러 단계(연결 → 마이그레이션 → 조회)에 걸쳐
      // 도착하므로, 실제 시간을 흘려보내고 화면을 갱신하는 과정을 몇 번 반복한다.
      // pump()에 시간을 주지 않으면 테스트의 가짜 시간이 흐르지 않아 0초 타이머도 실행되지 않는다.
      for (var i = 0; i < 10; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump(const Duration(milliseconds: 1));
      }
    }

    await tester.pumpWidget(const MoneyMateApp(appVersion: '1.0.0'));
    await waitForDatabase();

    // 가계부 탭은 이번 달 달력으로 시작한다.
    expect(find.text(l10n.yearMonth(now.year, now.month)), findsOneWidget);
    expect(find.text(l10n.viewCalendar), findsOneWidget);

    // 자산 탭: 빈 DB이므로 첫 자산 등록 안내가 보인다.
    await tester.tap(find.text(l10n.navAsset));
    await waitForDatabase();
    expect(find.text(l10n.noAssetsYet), findsOneWidget);

    // 더보기 탭
    await tester.tap(find.text(l10n.navMore));
    await tester.pump();
    expect(find.text(l10n.sectionGeneral), findsOneWidget);

    // 화면을 내리면 drift가 DB 구독 정리용 0초 타이머를 걸어 두므로, 가짜 시간을 흘려 실행시킨다.
    await tester.pumpWidget(const SizedBox.shrink());
    await waitForDatabase();
  });
}
