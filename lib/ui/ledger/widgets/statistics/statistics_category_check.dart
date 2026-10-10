import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

/// 카테고리 체크 항목의 공통 앞부분: 체크박스(기본색) · ● 카테고리 색 라벨 · 이름.
/// 체크 해제된 항목은 색 라벨과 이름을 흐리게 표시한다.
class StatisticsCategoryCheck extends StatelessWidget {
  const StatisticsCategoryCheck({
    super.key,
    required this.label,
    required this.color,
    required this.isChecked,
    required this.onChanged,
    this.expandLabel = false,
  });

  final String label;
  final Color color;
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  /// 목록 행처럼 남은 폭을 이름이 차지해야 할 때 true.
  final bool expandLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        height: 20 / 14,
        color: isChecked ? colors.textPrimary : colors.textTertiary,
      ),
    );

    return Row(
      mainAxisSize: expandLabel ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Checkbox(
          value: isChecked,
          onChanged: (value) => onChanged(value ?? false),
          activeColor: colors.primary,
          side: BorderSide(color: colors.textTertiary, width: 1.5),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(width: 2),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isChecked ? color : color.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        if (expandLabel) Expanded(child: text) else Flexible(child: text),
      ],
    );
  }
}
