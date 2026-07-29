import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

/// iOS 숫자 키패드에는 키보드를 내릴 수 있는 완료 버튼이 없어서,
/// 키보드가 올라와 있을 때 화면 하단에 완료 버튼을 붙여준다.
/// 안드로이드는 시스템 키보드에 완료 버튼이 기본 제공되므로 적용하지 않는다.
class KeyboardDoneBar extends StatelessWidget {
  const KeyboardDoneBar({super.key, required this.child});

  final Widget child;

  static const double _barHeight = 44;

  @override
  Widget build(BuildContext context) {
    final tapToDismiss = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );

    if (!Platform.isIOS) return tapToDismiss;

    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    // 완료 바 높이만큼 viewInsets.bottom을 늘려서, Scaffold의 자동 리사이즈나
    // 화면 하단에 고정된 CTA 버튼이 완료 바에 가려지지 않도록 공간을 미리 확보한다.
    final content = isKeyboardVisible
        ? MediaQuery(
            data: mediaQuery.copyWith(
              viewInsets: mediaQuery.viewInsets.copyWith(
                bottom: keyboardHeight + _barHeight,
              ),
            ),
            child: tapToDismiss,
          )
        : tapToDismiss;

    return Stack(
      children: [
        content,
        if (isKeyboardVisible)
          Positioned(
            left: 0,
            right: 0,
            bottom: keyboardHeight,
            child: const _DoneBar(),
          ),
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
          height: KeyboardDoneBar._barHeight,
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