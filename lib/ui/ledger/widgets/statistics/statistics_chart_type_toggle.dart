import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class StatisticsChartTypeOption<T> {
  const StatisticsChartTypeOption({
    required this.value,
    required this.icon,
    required this.label,
  });

  final T value;
  final IconData icon;
  final String label;
}

/// 그래프 유형(꺾은선/막대/원형)을 고르는 작은 아이콘 토글.
class StatisticsChartTypeToggle<T> extends StatelessWidget {
  const StatisticsChartTypeToggle({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<StatisticsChartTypeOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.appColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options)
            _ToggleItem(
              icon: option.icon,
              label: option.label,
              isSelected: option.value == selected,
              onTap: () => onChanged(option.value),
            ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  const _ToggleItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36,
            height: 28,
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? context.appColors.surface
                      : context.appColors.overlay,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color:
                  isSelected
                      ? context.appColors.primary
                      : context.appColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}
