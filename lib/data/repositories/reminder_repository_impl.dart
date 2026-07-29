import 'package:money_mate/data/local/reminder_local_data_source.dart';
import 'package:money_mate/data/local/reminder_notification_scheduler.dart';
import 'package:money_mate/data/repositories/reminder_repository.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl({
    ReminderLocalDataSource? localDataSource,
    ReminderNotificationScheduler? scheduler,
  }) : _localDataSource = localDataSource ?? ReminderLocalDataSource(),
       _scheduler = scheduler ?? ReminderNotificationScheduler();

  final ReminderLocalDataSource _localDataSource;
  final ReminderNotificationScheduler _scheduler;

  @override
  Future<bool> isEnabled() => _localDataSource.isEnabled();

  @override
  Future<Set<int>> getWeekdays() => _localDataSource.getWeekdays();

  @override
  Future<int> getHour() => _localDataSource.getHour();

  @override
  Future<int> getMinute() => _localDataSource.getMinute();

  @override
  Future<void> setEnabled(bool enabled) async {
    await _localDataSource.setEnabled(enabled);
    if (!enabled) {
      await _scheduler.cancelAll();
      return;
    }
    await _rescheduleFromStoredSettings();
  }

  @override
  Future<void> updateSchedule({
    required Set<int> weekdays,
    required int hour,
    required int minute,
  }) async {
    await _localDataSource.setWeekdays(weekdays);
    await _localDataSource.setTime(hour: hour, minute: minute);

    final enabled = await _localDataSource.isEnabled();
    if (!enabled) return;
    await _scheduler.scheduleWeekly(
      weekdays: weekdays,
      hour: hour,
      minute: minute,
    );
  }

  Future<void> _rescheduleFromStoredSettings() async {
    final weekdays = await _localDataSource.getWeekdays();
    final hour = await _localDataSource.getHour();
    final minute = await _localDataSource.getMinute();
    await _scheduler.scheduleWeekly(
      weekdays: weekdays,
      hour: hour,
      minute: minute,
    );
  }
}
