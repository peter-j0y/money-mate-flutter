import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 92,
      ),
      itemBuilder: (context, index) {
        final option = options[index];
        final selected = selectedIndex == index;
        final hasTap = onCategoryTap != null;

        return _LedgerCategoryGridItem(
          option: option,
          selected: selected,
          onTap: hasTap ? () => onCategoryTap!(index) : null,
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
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: option.backgroundColor,
            shape: BoxShape.circle,
            border:
                selected
                    ? Border.all(color: const Color(0xFF137FEC), width: 2)
                    : null,
          ),
          alignment: Alignment.center,
          child: Icon(option.icon, size: 22, color: option.iconColor),
        ),
        const SizedBox(height: 8),
        Text(
          option.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            height: 16 / 12,
            fontWeight: FontWeight.w500,
            color: selected ? const Color(0xFF137FEC) : const Color(0xFF475569),
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
