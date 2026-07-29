import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class _ReminderMessage {
  const _ReminderMessage(this.title, this.body);

  final String title;
  final String body;
}

const List<_ReminderMessage> _reminderMessages = [
  _ReminderMessage(
    '오늘 가계부 작성하셨나요?',
    '1분만 투자해서 가계부 쓰고, 소비 습관을 만들어보아요.',
  ),
  _ReminderMessage(
    '오늘 가계부 작성하셨나요?',
    '잊기 전에 가계부에 적고 낭비된 돈이 없는지 찾아보세요.',
  ),
  _ReminderMessage(
    '오늘 가계부 작성하셨나요?',
    '오늘 하루 지출, 잊기 전에 빠르게 정리하러 가기!',
  ),
  _ReminderMessage(
    '오늘 가계부 작성하셨나요?',
    '지금 기록해두지 않으면 내일 또 같은 지출을 반복할지도 몰라요!',
  ),
];

/// 선택한 요일·시간에 매주 반복되는 기록 리마인드 알림을 예약/취소한다.
class ReminderNotificationScheduler {
  ReminderNotificationScheduler({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final Random _random = Random();
  bool _initialized = false;

  static const String _channelId = 'reminder_channel';
  static const String _channelName = '기록 리마인드';
  static const String _channelDescription = '설정한 시간에 오늘 기록을 잊지 않도록 알려드려요';

  // 알림 id는 요일(1~7)마다 하나씩 고정 배정한다.
  static int _notificationIdFor(int weekday) => 100 + weekday;

  _ReminderMessage _randomMessage() =>
      _reminderMessages[_random.nextInt(_reminderMessages.length)];

  Future<void> _ensureInitialized() async {
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

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
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
    await _ensureInitialized();
    await cancelAll();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
      ),
      iOS: DarwinNotificationDetails(),
    );

    for (final weekday in weekdays) {
      final message = _randomMessage();
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
