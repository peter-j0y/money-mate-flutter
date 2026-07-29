abstract class ReminderRepository {
  Future<bool> isEnabled();
  Future<Set<int>> getWeekdays();
  Future<int> getHour();
  Future<int> getMinute();

  Future<void> setEnabled(bool enabled);
  Future<void> updateSchedule({
    required Set<int> weekdays,
    required int hour,
    required int minute,
  });
}
