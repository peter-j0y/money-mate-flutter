import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class _ReminderMessage {
  const _ReminderMessage(this.title, this.body);

  final String title;
  final String body;
}

List<_ReminderMessage> _reminderMessages(AppLocalizations l10n) => [
  _ReminderMessage(l10n.reminderNotificationTitle, l10n.reminderBody1),
  _ReminderMessage(l10n.reminderNotificationTitle, l10n.reminderBody2),
  _ReminderMessage(l10n.reminderNotificationTitle, l10n.reminderBody3),
  _ReminderMessage(l10n.reminderNotificationTitle, l10n.reminderBody4),
];

// Intl.getCurrentLocale()은 "ko_KR"처럼 밑줄로 연결된 문자열을 반환하는데,
// Locale(String) 단일 인자 생성자는 이를 파싱하지 않고 전체를 languageCode로
// 취급해버려 lookupAppLocalizations가 항상 지원하지 않는 로케일로 보고 예외를
// 던진다. 언어 코드만 분리해서 넘겨야 한다.
// 앱이 지원하지 않는 예기치 못한 언어 코드가 들어오는 경우를 대비해,
// 알림 예약 자체가 실패하지 않도록 영어로 안전하게 폴백한다.
AppLocalizations _currentLocalizations() {
  final languageCode = Intl.getCurrentLocale().split(RegExp('[_-]')).first;
  try {
    return lookupAppLocalizations(Locale(languageCode));
  } on FlutterError {
    return lookupAppLocalizations(const Locale('en'));
  }
}

/// 선택한 요일·시간에 매주 반복되는 기록 리마인드 알림을 예약/취소한다.
class ReminderNotificationScheduler {
  ReminderNotificationScheduler({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final Random _random = Random();
  bool _initialized = false;

  static const String _channelId = 'reminder_channel';

  // 알림 id는 요일(1~7)마다 하나씩 고정 배정한다.
  static int _notificationIdFor(int weekday) => 100 + weekday;

  _ReminderMessage _randomMessage(AppLocalizations l10n) {
    final messages = _reminderMessages(l10n);
    return messages[_random.nextInt(messages.length)];
  }

  Future<void> _ensureInitialized(AppLocalizations l10n) async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    const androidSettings = AndroidInitializationSettings('ic_stat_reminder');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestSoundPermission: false,
      requestBadgePermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    final channel = AndroidNotificationChannel(
      _channelId,
      l10n.reminderTitle,
      description: l10n.reminderSubtitle,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  Future<void> scheduleWeekly({
    required Set<int> weekdays,
    required int hour,
    required int minute,
  }) async {
    final l10n = _currentLocalizations();
    await _ensureInitialized(l10n);
    await cancelAll();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        l10n.reminderTitle,
        channelDescription: l10n.reminderSubtitle,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    for (final weekday in weekdays) {
      final message = _randomMessage(l10n);
      await _plugin.zonedSchedule(
        _notificationIdFor(weekday),
        message.title,
        message.body,
        _nextInstanceOfWeekday(weekday, hour, minute),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> cancelAll() async {
    for (var weekday = 1; weekday <= 7; weekday++) {
      await _plugin.cancel(_notificationIdFor(weekday));
    }
  }

  tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
