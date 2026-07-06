import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class AssetCategoryCard extends StatefulWidget {
  const AssetCategoryCard({
    super.key,
    required this.categoryName,
    required this.totalAmountText,
    required this.actualRatio,
    required this.targetRatio,
    required this.accentColor,
    required this.leadingIcon,
    required this.leadingBackgroundColor,
    required this.items,
    this.isCategoryEnabled = true,
    this.isExpanded = false,
    this.onHeaderTap,
    this.onItemTap,
  });

  final String categoryName;
  final String totalAmountText;
  final double actualRatio;
  final double targetRatio;
  final Color accentColor;
  final IconData leadingIcon;
  final Color leadingBackgroundColor;
  final List<AssetCategoryItemData> items;
  final bool isCategoryEnabled;
  final bool isExpanded;
  final VoidCallback? onHeaderTap;
  final ValueChanged<AssetCategoryItemData>? onItemTap;

  @override
  State<AssetCategoryCard> createState() => _AssetCategoryCardState();
}

class _AssetCategoryCardState extends State<AssetCategoryCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  @override
  void didUpdateWidget(covariant AssetCategoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpanded != widget.isExpanded) {
      _isExpanded = widget.isExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratioDiff = widget.actualRatio - widget.targetRatio;
    final ratioDiffText = _ratioDiffLabel(ratioDiff);
    final ratioDiffColor = ratioDiff >= 0 ? context.appColors.danger : context.appColors.success;

    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              widget.onHeaderTap?.call();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.leadingBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.leadingIcon, size: 18, color: widget.accentColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.categoryName,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 20 / 14,
                                  fontWeight: FontWeight.w600,
                                  color: context.appColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              widget.totalAmountText,
                              style: TextStyle(
                                fontSize: 14,
                                height: 20 / 14,
                                fontWeight: FontWeight.w600,
                                color: context.appColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (widget.isCategoryEnabled) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 16 / 12,
                                    fontWeight: FontWeight.w500,
                                    color: context.appColors.textTertiary,
                                  ),
                                  children: [
                                    const TextSpan(text: '실제 '),
                                    TextSpan(
                                      text: '${widget.actualRatio.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        color: widget.accentColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 16 / 12,
                                    fontWeight: FontWeight.w500,
                                    color: context.appColors.textTertiary,
                                  ),
                                  children: [
                                    const TextSpan(text: '목표 '),
                                    TextSpan(
                                      text: '${widget.targetRatio.toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        color: context.appColors.textSecondary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ratioDiffText,
                                      style: TextStyle(color: ratioDiffColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: context.appColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded && widget.items.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: context.appColors.border)),
              ),
              child: Column(
                children: List.generate(widget.items.length, (index) {
                  final item = widget.items[index];
                  return _AssetCategoryItemRow(
                    item: item,
                    accentColor: widget.accentColor,
                    showDivider: index != widget.items.length - 1,
                    onTap:
                        widget.onItemTap == null
                            ? null
                            : () => widget.onItemTap!(item),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  String _ratioDiffLabel(double diff) {
    if (diff >= 0) {
      return '(+${diff.toStringAsFixed(1)}%)';
    }
    return '(${diff.toStringAsFixed(1)}%)';
  }
}

class AssetCategoryItemData {
  const AssetCategoryItemData({
    required this.name,
    required this.amountText,
    required this.innerRatioText,
    this.ticker,
    this.isExcludedFromPortfolio = false,
  });

  final String name;
  final String amountText;
  final String innerRatioText;
  final String? ticker;
  final bool isExcludedFromPortfolio;
}

class _RatioBar extends StatelessWidget {
  const _RatioBar({
    required this.actualRatio,
    required this.targetRatio,
    required this.color,
  });

  final double actualRatio;
  final double targetRatio;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final actual = actualRatio.clamp(0, 100).toDouble();
    final target = targetRatio.clamp(0, 100).toDouble();

    return SizedBox(
      height: 8,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final markerLeft =
              ((target / 100) * constraints.maxWidth - 1).clamp(
                0.0,
                constraints.maxWidth - 2,
              ).toDouble();
          return ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(color: context.appColors.surfaceMuted),
                FractionallySizedBox(
                  widthFactor: actual / 100,
                  alignment: Alignment.centerLeft,
                  child: Opacity(
                    opacity: 0.85,
                    child: Container(color: color),
                  ),
                ),
                Positioned(
                  left: markerLeft,
                  child: Container(
                    width: 2,
                    height: 8,
                    color: context.appColors.textTertiary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AssetCategoryItemRow extends StatelessWidget {
  const _AssetCategoryItemRow({
    required this.item,
    required this.accentColor,
    required this.showDivider,
    this.onTap,
  });

  final AssetCategoryItemData item;
  final Color accentColor;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      constraints: const BoxConstraints(minHeight: 62),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.appColors.surfaceMuted.withValues(alpha: 0.35),
        border:
            showDivider
                ? Border(bottom: BorderSide(color: context.appColors.border))
                : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight: FontWeight.w500,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ),
                    if (item.ticker != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        height: 19,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color:
                              item.isExcludedFromPortfolio
                                  ? context.appColors.surfaceMuted
                                  : accentColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item.ticker!,
                          style: TextStyle(
                            fontSize: 10,
                            height: 15 / 10,
                            fontWeight: FontWeight.w600,
                            color:
                                item.isExcludedFromPortfolio
                                    ? context.appColors.textTertiary
                                    : accentColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.innerRatioText,
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w500,
                    color:
                        item.isExcludedFromPortfolio
                            ? context.appColors.textSecondary
                            : accentColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              Text(
                item.amountText,
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: context.appColors.textTertiary,
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(onTap: onTap, child: content);
  }
}
