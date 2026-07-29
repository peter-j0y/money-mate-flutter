import 'package:shared_preferences/shared_preferences.dart';

class ReminderLocalDataSource {
  ReminderLocalDataSource();

  static const String _enabledKey = 'reminder_enabled';
  static const String _weekdaysKey = 'reminder_weekdays';
  static const String _hourKey = 'reminder_hour';
  static const String _minuteKey = 'reminder_minute';

  static const Set<int> _defaultWeekdays = {1, 2, 3, 4, 5, 6, 7};
  static const int _defaultHour = 21;
  static const int _defaultMinute = 0;

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
  }

  Future<Set<int>> getWeekdays() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_weekdaysKey);
    if (stored == null) return Set<int>.of(_defaultWeekdays);
    return stored.map(int.parse).toSet();
  }

  Future<void> setWeekdays(Set<int> weekdays) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _weekdaysKey,
      weekdays.map((weekday) => weekday.toString()).toList(),
    );
  }

  Future<int> getHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_hourKey) ?? _defaultHour;
  }

  Future<int> getMinute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_minuteKey) ?? _defaultMinute;
  }

  Future<void> setTime({required int hour, required int minute}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hourKey, hour);
    await prefs.setInt(_minuteKey, minute);
  }
}
