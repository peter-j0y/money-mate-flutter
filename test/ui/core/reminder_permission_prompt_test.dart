import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_mate/data/model/entities/currency.dart';
import 'package:money_mate/data/repositories/app_settings_repository.dart';
import 'package:money_mate/data/repositories/reminder_repository.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/core/reminder_permission_prompt.dart';

class _FakeAppSettingsRepository implements AppSettingsRepository {
  bool requested = false;

  @override
  Future<bool> hasRequestedNotificationPermission() async => requested;

  @override
  Future<void> setNotificationPermissionRequested() async => requested = true;

  @override
  Future<CurrencyCode?> getMainCurrency() async => null;

  @override
  Future<void> setMainCurrency(CurrencyCode currency) async {}
}

class _FakeReminderRepository implements ReminderRepository {
  bool enabled = false;
  int hour = 21;
  int minute = 0;
  final List<bool> setEnabledCalls = [];

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<int> getHour() async => hour;

  @override
  Future<int> getMinute() async => minute;

  @override
  Future<void> setEnabled(bool value) async {
    setEnabledCalls.add(value);
    enabled = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _FakeAppSettingsRepository settings;
  late _FakeReminderRepository reminder;
  late int systemRequestCount;
  late bool systemGrants;
  final l10n = lookupAppLocalizations(const Locale('ko'));

  setUp(() {
    settings = _FakeAppSettingsRepository();
    reminder = _FakeReminderRepository();
    systemRequestCount = 0;
    systemGrants = true;
  });

  DefaultReminderPermissionPrompt buildPrompt() {
    return DefaultReminderPermissionPrompt(
      appSettingsRepository: settings,
      reminderRepository: reminder,
      requestSystemPermission: () async {
        systemRequestCount++;
        return systemGrants;
      },
      showDelay: Duration.zero,
    );
  }

  Future<NavigatorState> pumpApp(WidgetTester tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ko'),
        home: const SizedBox.shrink(),
      ),
    );
    return navigatorKey.currentState!;
  }

  testWidgets('이미 물어본 사용자에게는 다이얼로그를 띄우지 않는다', (tester) async {
    settings.requested = true;
    final navigator = await pumpApp(tester);

    await buildPrompt().maybePrompt(navigator);
    await tester.pumpAndSettle();

    expect(find.text(l10n.notificationDialogTitle), findsNothing);
    expect(reminder.setEnabledCalls, isEmpty);
  });

  testWidgets('더보기에서 이미 켠 사용자는 묻지 않고 요청 완료로 기록한다', (tester) async {
    reminder.enabled = true;
    final navigator = await pumpApp(tester);

    await buildPrompt().maybePrompt(navigator);
    await tester.pumpAndSettle();

    expect(find.text(l10n.notificationDialogTitle), findsNothing);
    expect(settings.requested, isTrue);
    expect(reminder.setEnabledCalls, isEmpty);
  });

  testWidgets('허용하면 시스템 권한을 요청하고 결과대로 리마인더를 켠다', (tester) async {
    final navigator = await pumpApp(tester);

    final pending = buildPrompt().maybePrompt(navigator);
    await tester.pumpAndSettle();
    expect(find.text(l10n.notificationDialogTitle), findsOneWidget);

    await tester.tap(find.text(l10n.notificationDialogAllow));
    await tester.pumpAndSettle();
    await pending;

    expect(systemRequestCount, 1);
    expect(reminder.setEnabledCalls, [true]);
    expect(settings.requested, isTrue);
  });

  testWidgets('나중에를 누르면 시스템 권한을 요청하지 않고 다시 묻지 않는다', (tester) async {
    final navigator = await pumpApp(tester);

    final pending = buildPrompt().maybePrompt(navigator);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.notificationDialogLater));
    await tester.pumpAndSettle();
    await pending;

    expect(systemRequestCount, 0);
    expect(reminder.setEnabledCalls, [false]);
    expect(settings.requested, isTrue);
  });

  testWidgets('본문에 기본값이 아니라 저장된 리마인더 시각을 보여준다', (tester) async {
    reminder.hour = 8;
    reminder.minute = 30;
    final navigator = await pumpApp(tester);

    final pending = buildPrompt().maybePrompt(navigator);
    await tester.pumpAndSettle();

    final formatted = MaterialLocalizations.of(
      navigator.context,
    ).formatTimeOfDay(const TimeOfDay(hour: 8, minute: 30));
    expect(find.text(l10n.notificationDialogBody(formatted)), findsOneWidget);

    await tester.tap(find.text(l10n.notificationDialogLater));
    await tester.pumpAndSettle();
    await pending;
  });
}
