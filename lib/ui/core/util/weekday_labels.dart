import 'package:money_mate/l10n/app_localizations.dart';

/// 월요일(1)부터 일요일(7)까지, [DateTime.weekday] 인덱스(1~7)에 대응하는 요일 약어 목록.
List<String> weekdayShortLabels(AppLocalizations l10n) => [
  l10n.weekdayMon,
  l10n.weekdayTue,
  l10n.weekdayWed,
  l10n.weekdayThu,
  l10n.weekdayFri,
  l10n.weekdaySat,
  l10n.weekdaySun,
];

/// 일요일부터 시작하는 달력 헤더용 요일 약어 목록.
List<String> weekdaySundayFirstLabels(AppLocalizations l10n) => [
  l10n.weekdaySun,
  l10n.weekdayMon,
  l10n.weekdayTue,
  l10n.weekdayWed,
  l10n.weekdayThu,
  l10n.weekdayFri,
  l10n.weekdaySat,
];
