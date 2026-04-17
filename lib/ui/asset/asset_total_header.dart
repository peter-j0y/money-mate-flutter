import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class AssetTotalHeader extends StatelessWidget {
  const AssetTotalHeader({
    super.key,
    required this.totalAssetText,
    required this.onAddAssetTap,
  });

  final String totalAssetText;
  final VoidCallback onAddAssetTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      decoration: BoxDecoration(
        color: context.appColors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '총 자산',
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.15,
                  color: context.appColors.textTertiary,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 28,
                child: FilledButton(
                  onPressed: onAddAssetTap,
                  style: FilledButton.styleFrom(
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    backgroundColor: context.appColors.primary.withValues(
                      alpha: isDark ? 0.2 : 0.12,
                    ),
                    foregroundColor: context.appColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14),
                      SizedBox(width: 4),
                      Text(
                        '자산 추가',
                        style: TextStyle(
                          fontSize: 12,
                          height: 16 / 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            totalAssetText,
            style: TextStyle(
              fontSize: 30,
              height: 36 / 30,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
