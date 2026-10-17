import 'package:shared_preferences/shared_preferences.dart';

class ReviewPromptLocalDataSource {
  ReviewPromptLocalDataSource();

  static const String _anchorAtKey = 'review_prompt_anchor_at';
  static const String _lastRequestedAtKey = 'review_prompt_last_requested_at';

  Future<DateTime?> getAnchorAt() => _getDateTime(_anchorAtKey);

  Future<void> setAnchorAt(DateTime value) => _setDateTime(_anchorAtKey, value);

  Future<DateTime?> getLastRequestedAt() => _getDateTime(_lastRequestedAtKey);

  Future<void> setLastRequestedAt(DateTime value) =>
      _setDateTime(_lastRequestedAtKey, value);

  Future<DateTime?> _getDateTime(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(key);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> _setDateTime(String key, DateTime value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value.millisecondsSinceEpoch);
  }
}
