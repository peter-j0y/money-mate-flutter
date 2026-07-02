import 'package:flutter/material.dart';
import 'package:money_mate/data/local/app_database.dart';
import 'package:money_mate/data/local/asset_local_data_source.dart';
import 'package:money_mate/ui/asset/asset_category_card.dart';
import 'package:money_mate/ui/asset/asset_total_header.dart';
import 'package:money_mate/ui/asset/portfolio_allocation_card.dart';
import 'package:money_mate/ui/asset/screen/add_asset_screen.dart';
import 'package:money_mate/ui/asset/screen/portfolio_target_setting_screen.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class AssetsTabScreen extends StatelessWidget {
  AssetsTabScreen({super.key, AssetLocalDataSource? localDataSource})
    : _localDataSource = localDataSource ?? AssetLocalDataSource();

  final AssetLocalDataSource _localDataSource;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Asset>>(
      stream: _localDataSource.watchAssets(),
      builder: (context, snapshot) {
        final assets = snapshot.data ?? const <Asset>[];

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const SafeArea(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (assets.isEmpty) {
          return _EmptyAssetsView(onAddAssetTap: () => _openAddAsset(context));
        }

        return _AssetContentView(
          onAddAssetTap: () => _openAddAsset(context),
          onSetTargetTap: () => _openPortfolioTargetSetting(context),
        );
      },
    );
  }

  void _openAddAsset(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const AddAssetScreen()),
    );
  }

  void _openPortfolioTargetSetting(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const PortfolioTargetSettingScreen(),
      ),
    );
  }
}

class _AssetContentView extends StatelessWidget {
  const _AssetContentView({
    required this.onAddAssetTap,
    required this.onSetTargetTap,
  });

  final VoidCallback onAddAssetTap;
  final VoidCallback onSetTargetTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 140),
        children: [
          AssetTotalHeader(
            totalAssetText: '1.55억원',
            onAddAssetTap: onAddAssetTap,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PortfolioAllocationCard(onSetTargetTap: onSetTargetTap),
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

class _EmptyAssetsView extends StatelessWidget {
  const _EmptyAssetsView({required this.onAddAssetTap});

  final VoidCallback onAddAssetTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
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
          const SizedBox(height: 4),
          Text(
            '0원',
            style: TextStyle(
              fontSize: 30,
              height: 36 / 30,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 96),
          _EmptyAssetCard(onAddAssetTap: onAddAssetTap),
        ],
      ),
    );
  }
}

class _EmptyAssetCard extends StatelessWidget {
  const _EmptyAssetCard({required this.onAddAssetTap});

  final VoidCallback onAddAssetTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: context.appColors.primary.withValues(
              alpha: isDark ? 0.18 : 0.1,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.account_balance_wallet_outlined,
            size: 44,
            color: context.appColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '아직 등록된 자산이 없어요',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            height: 28 / 20,
            fontWeight: FontWeight.w700,
            color: context.appColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '첫 자산을 추가하고\n포트폴리오를 한눈에 확인해 보세요',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w400,
            color: context.appColors.textTertiary,
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: onAddAssetTap,
            style: FilledButton.styleFrom(
              elevation: 0,
              backgroundColor: context.appColors.primary,
              foregroundColor: context.appColors.inverseText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 20),
                SizedBox(width: 6),
                Text(
                  '자산 추가하기',
                  style: TextStyle(
                    fontSize: 16,
                    height: 24 / 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
