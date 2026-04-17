import 'package:flutter/material.dart';
import 'package:money_mate/ui/asset/asset_category_card.dart';
import 'package:money_mate/ui/asset/asset_total_header.dart';
import 'package:money_mate/ui/asset/portfolio_allocation_card.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

import '../add_asset_bottom_sheet.dart';

class AssetsTabScreen extends StatelessWidget {
  const AssetsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 140),
        children: [
          AssetTotalHeader(
            totalAssetText: '1.55억원',
            onAddAssetTap: () => showAddAssetBottomSheet(context),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: PortfolioAllocationCard(),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '자산 목록',
              style: TextStyle(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w600,
                color: context.appColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AssetCategoryCard(
              categoryName: '주식',
              totalAmountText: '1,370만원',
              actualRatio: 40.3,
              targetRatio: 40,
              accentColor: const Color(0xFF3B82F6),
              leadingIcon: Icons.trending_up_rounded,
              leadingBackgroundColor: const Color(0xFFEFF6FF),
              items: const [
                AssetCategoryItemData(
                  name: '삼성전자',
                  ticker: '005930',
                  innerRatioText: '주식 내 비중 62.0%',
                  amountText: '850만원',
                ),
                AssetCategoryItemData(
                  name: 'S&P500 ETF',
                  ticker: 'SPY',
                  innerRatioText: '주식 내 비중 38.0%',
                  amountText: '520만원',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AssetCategoryCard(
              categoryName: '현금',
              totalAmountText: '320만원',
              actualRatio: 9.4,
              targetRatio: 15,
              accentColor: const Color(0xFF10B981),
              leadingIcon: Icons.account_balance_wallet_rounded,
              leadingBackgroundColor: const Color(0xFFECFDF5),
              items: const [
                AssetCategoryItemData(
                  name: '국민은행 통장',
                  innerRatioText: '현금 내 비중 100.0%',
                  amountText: '320만원',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AssetCategoryCard(
              categoryName: '기타',
              totalAmountText: '70만원',
              actualRatio: 0,
              targetRatio: 0,
              accentColor: const Color(0xFF6B7280),
              leadingIcon: Icons.category_outlined,
              leadingBackgroundColor: const Color(0xFFF9FAFB),
              items: const [
                AssetCategoryItemData(
                  name: '기타 자산',
                  ticker: '포트폴리오 제외',
                  isExcludedFromPortfolio: true,
                  innerRatioText: '기타 내 비중 100.0%',
                  amountText: '70만원',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
