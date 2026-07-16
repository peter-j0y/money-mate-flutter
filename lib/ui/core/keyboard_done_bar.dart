import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

/// iOS 숫자 키패드에는 키보드를 내릴 수 있는 완료 버튼이 없어서,
/// 키보드가 올라와 있을 때 화면 하단에 완료 버튼을 붙여준다.
/// 안드로이드는 시스템 키보드에 완료 버튼이 기본 제공되므로 적용하지 않는다.
class KeyboardDoneBar extends StatelessWidget {
  const KeyboardDoneBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tapToDismiss = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );

    if (!Platform.isIOS) return tapToDismiss;

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return Stack(
      children: [
        tapToDismiss,
        if (isKeyboardVisible)
          Positioned(left: 0, right: 0, bottom: keyboardHeight, child: const _DoneBar()),
      ],
    );
  }
}

class _DoneBar extends StatelessWidget {
  const _DoneBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.surfaceMuted,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: context.appColors.border)),
          ),
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Text(
              '완료',
              style: TextStyle(color: context.appColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}