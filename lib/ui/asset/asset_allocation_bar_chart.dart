import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class AssetAllocationBarChart extends StatelessWidget {
  const AssetAllocationBarChart({
    super.key,
    this.onHeaderTap,
    this.onAddAssetTap,
  });

  final VoidCallback? onHeaderTap;
  final VoidCallback? onAddAssetTap;

  static const List<_AssetSegment> _segments = [
    _AssetSegment(label: '미국 주식', ratio: 0.45, color: AppColors.hexFF34D399),
    _AssetSegment(label: '코인', ratio: 0.30, color: AppColors.hexFFA78BFA),
    _AssetSegment(label: '현금', ratio: 0.15, color: AppColors.hexFF38BDF8),
    _AssetSegment(label: '기타', ratio: 0.10, color: AppColors.hexFFFB923C),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionPillButton(
                backgroundColor: AppColors.hexFFFFE69A,
                icon: Icons.add_rounded,
                label: '자산 추가',
                onTap: onAddAssetTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionPillButton(
                backgroundColor: AppColors.hexFFB8F2E6,
                icon: Icons.tune_rounded,
                label: '비중 설정하기',
                onTap: onHeaderTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.hexFFF3F4F6,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: const [
              BoxShadow(color: AppColors.hexFFF9FAFB, spreadRadius: 4),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children:
                _segments
                    .map(
                      (segment) => Expanded(
                        flex: (segment.ratio * 1000).round(),
                        child: ColoredBox(color: segment.color),
                      ),
                    )
                    .toList(),
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LegendItem(label: _segments[0].label, color: _segments[0].color),
              _LegendItem(label: _segments[1].label, color: _segments[1].color),
              _LegendItem(label: _segments[2].label, color: _segments[2].color),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionPillButton extends StatelessWidget {
  const _ActionPillButton({
    required this.backgroundColor,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final Color backgroundColor;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(9999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: AppColors.hexFFF3F4F6),
            boxShadow: const [
              BoxShadow(
                color: AppColors.rgba_0_0_0_005,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 14, color: AppColors.hexFF4A4A4A),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.hexFF4A4A4A,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: AppColors.rgba_0_0_0_005,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 12,
            height: 16 / 12,
            color: AppColors.hexFF64748B,
          ),
        ),
      ],
    );
  }
}

class _AssetSegment {
  const _AssetSegment({
    required this.label,
    required this.ratio,
    required this.color,
  });

  final String label;
  final double ratio;
  final Color color;
}
