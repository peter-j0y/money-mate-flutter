import 'dart:async';

import 'package:flutter/material.dart';
import 'package:money_mate/data/repositories/app_settings_repository.dart';
import 'package:money_mate/data/repositories/app_settings_repository_impl.dart';
import 'package:money_mate/data/repositories/reminder_repository.dart';
import 'package:money_mate/data/repositories/reminder_repository_impl.dart';
import 'package:money_mate/ui/core/notification_permission_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

/// 가계부 기록을 저장한 직후, 리마인더 알림을 켤지 한 번만 묻는다.
///
/// 첫 실행이 아니라 첫 기록 시점에 묻는 이유는, 방금 기록을 마친 사용자가 "매일 기록"의
/// 가치를 가장 잘 이해하는 순간이기 때문이다. `ReviewPromptService`처럼 기본값은
/// 아무것도 하지 않는 [NoopReminderPermissionPrompt]이고 `main`에서 교체한다.
abstract class ReminderPermissionPrompt {
  static ReminderPermissionPrompt instance =
      const NoopReminderPermissionPrompt();

  /// 가계부 기록 신규 저장 성공 직후, 기록 화면을 닫기 전에 호출한다.
  /// [navigator]는 기록 화면이 닫힌 뒤에도 살아 있는 화면 위에 다이얼로그를 띄우는 데 쓴다.
  void onLedgerRecordSaved(NavigatorState navigator);
}

class NoopReminderPermissionPrompt implements ReminderPermissionPrompt {
  const NoopReminderPermissionPrompt();

  @override
  void onLedgerRecordSaved(NavigatorState navigator) {}
}

class DefaultReminderPermissionPrompt implements ReminderPermissionPrompt {
  DefaultReminderPermissionPrompt({
    AppSettingsRepository? appSettingsRepository,
    ReminderRepository? reminderRepository,
    Future<bool> Function()? requestSystemPermission,
    Duration showDelay = const Duration(milliseconds: 400),
  }) : _appSettingsRepository =
           appSettingsRepository ?? AppSettingsRepositoryImpl(),
       _reminderRepository = reminderRepository ?? ReminderRepositoryImpl(),
       _requestSystemPermission =
           requestSystemPermission ?? _requestNotificationPermission,
       _showDelay = showDelay;

  final AppSettingsRepository _appSettingsRepository;
  final ReminderRepository _reminderRepository;
  final Future<bool> Function() _requestSystemPermission;
  final Duration _showDelay;

  static Future<bool> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  @override
  void onLedgerRecordSaved(NavigatorState navigator) {
    unawaited(maybePrompt(navigator));
  }

  @visibleForTesting
  Future<void> maybePrompt(NavigatorState navigator) async {
    try {
      if (await _appSettingsRepository.hasRequestedNotificationPermission()) {
        return;
      }
      // 더보기에서 이미 리마인더를 켠 사용자에게는 다시 묻지 않는다.
      if (await _reminderRepository.isEnabled()) {
        await _appSettingsRepository.setNotificationPermissionRequested();
        return;
      }

      // 기본값(21:00)이 아니라 저장된 시각을 보여준다. 더보기에서 시간을 바꾼 뒤 끈 경우도 있다.
      final reminderTime = TimeOfDay(
        hour: await _reminderRepository.getHour(),
        minute: await _reminderRepository.getMinute(),
      );

      // 기록 화면이 닫히는 전환이 끝난 뒤 아래 화면 위에 띄운다.
      await Future<void>.delayed(_showDelay);
      if (!navigator.mounted) return;

      final agreed = await NotificationPermissionDialog.show(
        navigator.context,
        reminderTime: reminderTime,
      );
      final granted = agreed && await _requestSystemPermission();
      await _reminderRepository.setEnabled(granted);
      await _appSettingsRepository.setNotificationPermissionRequested();
    } catch (_) {
      // 권한 안내에 실패해도 기록 저장 흐름에는 영향을 주지 않는다.
    }
  }
}
