import 'dart:math';
import 'dart:ui';

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

AppLocalizations _currentLocalizations() =>
    lookupAppLocalizations(Locale(Intl.getCurrentLocale()));

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
