import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// 로컬 DB(Drift) CRUD 작업 중 발생한 예외를 Crashlytics에 비치명적(non-fatal) 에러로
/// 기록한 뒤 그대로 다시 던진다. 호출부의 에러 처리 흐름(catch, UI 표시 등)은 바뀌지 않는다.
Future<T> logDbErrors<T>(
  String operation,
  Future<T> Function() action, {
  Map<String, Object?>? context,
}) async {
  try {
    return await action();
  } catch (error, stackTrace) {
    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: 'Local DB operation failed: $operation',
      information: _contextLines(context),
      fatal: false,
    );
    rethrow;
  }
}

/// [logDbErrors]의 Stream 버전. Drift `.watch()` 스트림에서 발생하는 에러를 기록한 뒤
/// 동일한 에러를 스트림 구독자에게 다시 전달한다.
Stream<T> logDbStreamErrors<T>(
  String operation,
  Stream<T> Function() action, {
  Map<String, Object?>? context,
}) {
  return action().handleError((Object error, StackTrace stackTrace) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: 'Local DB stream failed: $operation',
      information: _contextLines(context),
      fatal: false,
    );
    throw error;
  });
}

List<String> _contextLines(Map<String, Object?>? context) {
  if (context == null || context.isEmpty) return const [];
  return context.entries.map((entry) => '${entry.key}: ${entry.value}').toList(growable: false);
}
