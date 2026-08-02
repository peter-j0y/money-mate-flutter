import 'package:flutter/material.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_category_options.dart';

class LedgerCategoryGrid extends StatelessWidget {
  const LedgerCategoryGrid({
    super.key,
    required this.options,
    required this.selectedIndex,
    this.onCategoryTap,
  });

  final List<LedgerCategoryOption> options;
  final int selectedIndex;
  final ValueChanged<int>? onCategoryTap;

  static const int _crossAxisCount = 4;
  static const double _spacing = 12;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - _spacing * (_crossAxisCount - 1)) /
            _crossAxisCount;

        return Wrap(
          spacing: _spacing,
          runSpacing: _spacing,
          children: [
            for (var index = 0; index < options.length; index++)
              SizedBox(
                width: itemWidth,
                child: _LedgerCategoryGridItem(
                  option: options[index],
                  selected: selectedIndex == index,
                  onTap:
                      onCategoryTap != null
                          ? () => onCategoryTap!(index)
                          : null,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LedgerCategoryGridItem extends StatelessWidget {
  const _LedgerCategoryGridItem({
    required this.option,
    required this.selected,
    this.onTap,
  });

  final LedgerCategoryOption option;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = option.accentColor.withValues(
      alpha: isDark ? 0.2 : 0.1,
    );
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border:
                selected
                    ? Border.all(color: context.appColors.primary, width: 2)
                    : null,
          ),
          alignment: Alignment.center,
          child: Icon(option.icon, size: 22, color: option.accentColor),
        ),
        const SizedBox(height: 8),
        Text(
          option.label(l10n),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w500,
            color:
                selected
                    ? context.appColors.primary
                    : context.appColors.textSecondary,
          ),
        ),
      ],
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: content,
    );
  }
}
