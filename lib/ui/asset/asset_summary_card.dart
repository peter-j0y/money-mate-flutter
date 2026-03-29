import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class AssetSummaryCard extends StatelessWidget {
  const AssetSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.rgba_255_255_255_05,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '내 모든 자산',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.hexFF8C8C8C,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '12억 4,539만원',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 36,
                      height: 40 / 36,
                      letterSpacing: -0.9,
                      fontWeight: FontWeight.w900,
                      color: AppColors.hexFF4A4A4A,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '지난달보다',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          height: 16 / 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.hexFF9CA3AF,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.hexFFFEF2F2,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.trending_up_rounded,
                              size: 12,
                              color: AppColors.hexFFEF4444,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+1,245만원 (1.02%)',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                height: 20 / 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.hexFFEF4444,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
