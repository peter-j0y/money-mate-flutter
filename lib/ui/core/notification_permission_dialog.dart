import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:permission_handler/permission_handler.dart';

/// 시스템 알림 권한을 요청하기 전에, 왜 알림이 필요한지 먼저 설명하는 다이얼로그.
/// iOS는 시스템 권한 팝업을 거부하면 앱에서 다시 띄울 수 없기 때문에,
/// 실제 시스템 권한 요청 전에 사용자 동의를 먼저 구한다.
class NotificationPermissionDialog {
  const NotificationPermissionDialog._();

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: context.appColors.surface,
          title: const Text('기록하는 습관 만들기'),
          content: const Text(
            '설정한 시간에 기록을 잊지 않도록 알려드려요.\n알림은 언제든지 설정에서 끌 수 있어요.',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: context.appColors.textSecondary,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('다음에'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: context.appColors.primary,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('알림 받기'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  /// 시스템 알림 팝업을 더 이상 띄울 수 없는 상태(영구 거부)일 때,
  /// 설정 앱의 알림 화면으로 이동할지 확인받는 다이얼로그.
  /// 반환값은 사용자가 실제로 설정 화면으로 이동했는지 여부.
  static Future<bool> showSettingsRedirect(BuildContext context) async {
    final shouldOpenSettings = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: context.appColors.surface,
          title: const Text('알림 권한이 꺼져 있어요'),
          content: const Text('설정에서 알림 권한을 켜야 리마인드를 받을 수 있어요.'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: context.appColors.textSecondary,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: context.appColors.primary,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('설정으로 이동'),
            ),
          ],
        );
      },
    );
    if (shouldOpenSettings != true) return false;
    await openAppSettings();
    return true;
  }
}
