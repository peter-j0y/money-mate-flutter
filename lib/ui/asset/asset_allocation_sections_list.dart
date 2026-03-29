import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class AssetAllocationSectionsList extends StatelessWidget {
  const AssetAllocationSectionsList({super.key});

  static const _aaplLogoUrl =
      'https://www.figma.com/api/mcp/asset/ba946b93-e5fe-4fe9-83a3-e7caf1894ded';
  static const _msftLogoUrl =
      'https://www.figma.com/api/mcp/asset/faae2c64-ce80-4b3b-8a30-f080516c0def';
  static const _tslaLogoUrl =
      'https://www.figma.com/api/mcp/asset/42677816-65cf-4559-a36e-00a65d663df6';

  static const List<_SectionData> _sections = [
    _SectionData(
      title: '미국 주식',
      summaryText: '목표보다 많아요 (+5%)',
      summaryBackground: AppColors.hexFFFFF1F2,
      summaryTextColor: AppColors.hexFFF43F5E,
      items: [
        _AssetItemData(
          name: '애플 (AAPL)',
          quantity: '145.20 주',
          amount: '₩24,503,200',
          target: '목표: 15%',
          current: '(현재 18%)',
          currentColor: AppColors.hexFF34D399,
          tip: '조금 줄여도 좋아요',
          tipBackground: AppColors.hexFFFFF1F2,
          tipColor: AppColors.hexFFFB7185,
          logoUrl: _aaplLogoUrl,
        ),
        _AssetItemData(
          name: '마이크로소프트',
          quantity: '82.10 주',
          amount: '₩18,240,500',
          target: '목표: 12%',
          current: '(현재 13%)',
          currentColor: AppColors.hexFF34D399,
          tip: '거의 딱 맞아요',
          tipBackground: AppColors.hexFFECFDF5,
          tipColor: AppColors.hexFF10B981,
          logoUrl: _msftLogoUrl,
        ),
        _AssetItemData(
          name: '테슬라 (TSLA)',
          quantity: '40.00 주',
          amount: '₩8,940,000',
          target: '목표: 10%',
          current: '(현재 6%)',
          currentColor: AppColors.hexFFFB7185,
          tip: '더 채워야 해요',
          tipBackground: AppColors.hexFFFFF1F2,
          tipColor: AppColors.hexFFF43F5E,
          logoUrl: _tslaLogoUrl,
        ),
      ],
    ),
    _SectionData(
      title: '코인',
      summaryText: '목표와 비슷해요',
      summaryBackground: AppColors.hexFFECFDF5,
      summaryTextColor: AppColors.hexFF10B981,
      items: [
        _AssetItemData(
          name: '비트코인 (BTC)',
          quantity: '0.85 BTC',
          amount: '₩12,000,000',
          target: '목표: 20%',
          current: '(현재 19%)',
          currentColor: AppColors.hexFF10B981,
          tip: '좋은 비중이에요',
          tipBackground: AppColors.hexFFECFDF5,
          tipColor: AppColors.hexFF10B981,
          fallbackIcon: Icons.currency_bitcoin_rounded,
        ),
        _AssetItemData(
          name: '이더리움 (ETH)',
          quantity: '4.20 ETH',
          amount: '₩6,850,000',
          target: '목표: 10%',
          current: '(현재 11%)',
          currentColor: AppColors.hexFF10B981,
          tip: '거의 딱 맞아요',
          tipBackground: AppColors.hexFFECFDF5,
          tipColor: AppColors.hexFF10B981,
          fallbackIcon: Icons.token_rounded,
        ),
      ],
    ),
    _SectionData(
      title: '현금',
      summaryText: '목표보다 적어요 (-3%)',
      summaryBackground: AppColors.hexFFFFF1F2,
      summaryTextColor: AppColors.hexFFF43F5E,
      items: [
        _AssetItemData(
          name: '원화 예수금',
          quantity: '₩3,200,000',
          amount: '₩3,200,000',
          target: '목표: 10%',
          current: '(현재 8%)',
          currentColor: AppColors.hexFFFB7185,
          tip: '더 채워야 해요',
          tipBackground: AppColors.hexFFFFF1F2,
          tipColor: AppColors.hexFFF43F5E,
          fallbackIcon: Icons.account_balance_wallet_rounded,
        ),
        _AssetItemData(
          name: '달러 현금',
          quantity: '\$4,300',
          amount: '₩5,940,000',
          target: '목표: 8%',
          current: '(현재 9%)',
          currentColor: AppColors.hexFF10B981,
          tip: '좋은 비중이에요',
          tipBackground: AppColors.hexFFECFDF5,
          tipColor: AppColors.hexFF10B981,
          fallbackIcon: Icons.attach_money_rounded,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _sections.length; i++) ...[
          _AssetSection(section: _sections[i]),
          if (i != _sections.length - 1) const SizedBox(height: 24),
        ],
      ],
    );
  }
}

class _AssetSection extends StatelessWidget {
  const _AssetSection({required this.section});

  final _SectionData section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 8, right: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                section.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  height: 28 / 18,
                  color: AppColors.hexFF1E293B,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: section.summaryBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  section.summaryText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    height: 16 / 12,
                    color: section.summaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < section.items.length; i++) ...[
          _AssetCard(item: section.items[i]),
          if (i != section.items.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _AssetCard extends StatelessWidget {
  const _AssetCard({required this.item});

  final _AssetItemData item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hexFFF3F4F6),
        boxShadow: const [
          BoxShadow(
            color: AppColors.rgba_0_0_0_005,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.hexFFF9FAFB,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.rgba_0_0_0_005,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                        blurStyle: BlurStyle.inner,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: _AssetLogo(item: item),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.hexFF1E293B,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.quantity,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          height: 16 / 12,
                          color: AppColors.hexFF64748B,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.amount,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.hexFF1E293B,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    item.target,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      height: 16 / 12,
                      color: AppColors.hexFF94A3B8,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.current,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      height: 16 / 12,
                      color: item.currentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: item.tipBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.tip,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    height: 16.5 / 11,
                    color: item.tipColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AssetLogo extends StatelessWidget {
  const _AssetLogo({required this.item});

  final _AssetItemData item;

  @override
  Widget build(BuildContext context) {
    if (item.logoUrl != null) {
      return Opacity(
        opacity: 0.9,
        child: Image.network(
          item.logoUrl!,
          width: 28,
          height: 28,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return Icon(
              item.fallbackIcon ?? Icons.insert_chart_rounded,
              size: 20,
              color: AppColors.hexFF64748B,
            );
          },
        ),
      );
    }

    return Icon(
      item.fallbackIcon ?? Icons.insert_chart_rounded,
      size: 20,
      color: AppColors.hexFF64748B,
    );
  }
}

class _SectionData {
  const _SectionData({
    required this.title,
    required this.summaryText,
    required this.summaryBackground,
    required this.summaryTextColor,
    required this.items,
  });

  final String title;
  final String summaryText;
  final Color summaryBackground;
  final Color summaryTextColor;
  final List<_AssetItemData> items;
}

class _AssetItemData {
  const _AssetItemData({
    required this.name,
    required this.quantity,
    required this.amount,
    required this.target,
    required this.current,
    required this.currentColor,
    required this.tip,
    required this.tipBackground,
    required this.tipColor,
    this.logoUrl,
    this.fallbackIcon,
  });

  final String name;
  final String quantity;
  final String amount;
  final String target;
  final String current;
  final Color currentColor;
  final String tip;
  final Color tipBackground;
  final Color tipColor;
  final String? logoUrl;
  final IconData? fallbackIcon;
}
