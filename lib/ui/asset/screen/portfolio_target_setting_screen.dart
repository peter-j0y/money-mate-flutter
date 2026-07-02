import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class PortfolioTargetSettingScreen extends StatefulWidget {
  const PortfolioTargetSettingScreen({super.key});

  @override
  State<PortfolioTargetSettingScreen> createState() =>
      _PortfolioTargetSettingScreenState();
}

class _PortfolioTargetSettingScreenState
    extends State<PortfolioTargetSettingScreen> {
  final List<_TargetItem> _items = [
    _TargetItem(
      name: '주식',
      accentColor: AppColors.hexFF3B82F6,
      icon: Icons.show_chart_rounded,
      iconBackgroundColor: AppColors.hexFFDBEAFE,
      actualRatio: 40.3,
      targetRatio: 40,
      isIncluded: true,
    ),
    _TargetItem(
      name: '현금',
      accentColor: AppColors.hexFF10B981,
      icon: Icons.account_balance_wallet_rounded,
      iconBackgroundColor: AppColors.hexFFECFDF5,
      actualRatio: 9.4,
      targetRatio: 15,
      isIncluded: true,
    ),
    _TargetItem(
      name: '부동산',
      accentColor: AppColors.hexFF9CA3AF,
      icon: Icons.home_outlined,
      iconBackgroundColor: AppColors.hexFFF3F4F6,
      actualRatio: 0,
      targetRatio: 0,
      isIncluded: false,
    ),
    _TargetItem(
      name: '가상화폐',
      accentColor: AppColors.hexFF8B5CF6,
      icon: Icons.currency_bitcoin_rounded,
      iconBackgroundColor: AppColors.hexFFF5F3FF,
      actualRatio: 14.1,
      targetRatio: 10,
      isIncluded: true,
    ),
    _TargetItem(
      name: '예적금',
      accentColor: AppColors.hexFF0EA5E9,
      icon: Icons.savings_outlined,
      iconBackgroundColor: AppColors.hexFFE0F2FE,
      actualRatio: 29.4,
      targetRatio: 25,
      isIncluded: true,
    ),
    _TargetItem(
      name: '원자재',
      accentColor: AppColors.hexFFEF4444,
      icon: Icons.grain_outlined,
      iconBackgroundColor: AppColors.hexFFFEF2F2,
      actualRatio: 6.8,
      targetRatio: 10,
      isIncluded: true,
    ),
    _TargetItem(
      name: '기타',
      accentColor: AppColors.hexFF9CA3AF,
      icon: Icons.category_outlined,
      iconBackgroundColor: AppColors.hexFFF3F4F6,
      actualRatio: 0,
      targetRatio: 0,
      isIncluded: false,
    ),
  ];

  int get _includedTotal => _items
      .where((item) => item.isIncluded)
      .fold(0, (sum, item) => sum + item.targetRatio);

  bool get _isBalanced => _includedTotal == 100;

  void _applyEqualDistribution() {
    final includedIndexes = <int>[];
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].isIncluded) {
        includedIndexes.add(i);
      }
    }

    if (includedIndexes.isEmpty) {
      return;
    }

    final base = 100 ~/ includedIndexes.length;
    var remainder = 100 % includedIndexes.length;

    setState(() {
      for (final index in includedIndexes) {
        _items[index].targetRatio = base + (remainder > 0 ? 1 : 0);
        if (remainder > 0) {
          remainder -= 1;
        }
      }
    });
  }

  void _updateTargetRatio(int index, int nextValue) {
    setState(() {
      _items[index].targetRatio = nextValue.clamp(0, 100);
    });
  }

  void _toggleIncluded(int index, bool value) {
    setState(() {
      _items[index].isIncluded = value;
      if (!value) {
        _items[index].targetRatio = 0;
      } else if (_items[index].targetRatio == 0) {
        _items[index].targetRatio = 10;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              onBackTap: () => Navigator.of(context).pop(),
              onEqualTap: _applyEqualDistribution,
            ),
            _SummarySection(items: _items, includedTotal: _includedTotal),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _TargetSettingCard(
                    item: item,
                    onToggle: (value) => _toggleIncluded(index, value),
                    onDecrease:
                        item.isIncluded
                            ? () =>
                                _updateTargetRatio(index, item.targetRatio - 1)
                            : null,
                    onIncrease:
                        item.isIncluded
                            ? () =>
                                _updateTargetRatio(index, item.targetRatio + 1)
                            : null,
                    onSliderChanged:
                        item.isIncluded
                            ? (value) =>
                                _updateTargetRatio(index, value.round())
                            : null,
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: _items.length,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: context.appColors.surface,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: () {
                final message =
                    _isBalanced
                        ? '포트폴리오 목표 비율을 저장했습니다.'
                        : '목표 합계를 100%로 맞춰주세요.';
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              },
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text(
                '포트폴리오 설정 저장',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.hexFF3B82F6,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBackTap, required this.onEqualTap});

  final VoidCallback onBackTap;
  final VoidCallback onEqualTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 61,
      decoration: BoxDecoration(
        color: context.appColors.surface,
        border: Border(bottom: BorderSide(color: context.appColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 13),
      child: Row(
        children: [
          _RoundIconButton(
            backgroundColor: AppColors.hexFFF8FAFC,
            iconColor: context.appColors.textSecondary,
            icon: Icons.chevron_left_rounded,
            onTap: onBackTap,
          ),
          Expanded(
            child: Center(
              child: Text(
                '포트폴리오 설정',
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 28,
            child: TextButton.icon(
              onPressed: onEqualTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                backgroundColor: AppColors.hexFFF3F4F6,
                foregroundColor: context.appColors.textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.auto_awesome_rounded, size: 12),
              label: const Text(
                '균등 배분',
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.items, required this.includedTotal});

  final List<_TargetItem> items;
  final int includedTotal;

  @override
  Widget build(BuildContext context) {
    final isBalanced = includedTotal == 100;
    final guideColor =
        isBalanced ? context.appColors.success : context.appColors.danger;
    final totalProgress = (includedTotal / 100).clamp(0, 1).toDouble();
    final includedItems = items
        .where((item) => item.isIncluded)
        .toList(growable: false);

    return Container(
      height: 109,
      color: context.appColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '포함 유형 목표 합계',
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w400,
                      color: context.appColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$includedTotal',
                          style: TextStyle(
                            fontSize: 24,
                            height: 32 / 24,
                            fontWeight: FontWeight.w700,
                            color: guideColor,
                          ),
                        ),
                        TextSpan(
                          text: ' / 100%',
                          style: TextStyle(
                            fontSize: 14,
                            height: 20 / 14,
                            fontWeight: FontWeight.w400,
                            color: context.appColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color:
                      isBalanced
                          ? AppColors.hexFFECFDF5
                          : AppColors.hexFFFEF2F2,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      isBalanced
                          ? Icons.check_rounded
                          : Icons.error_outline_rounded,
                      size: 13,
                      color: guideColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isBalanced ? '완벽해요!' : '조정 필요',
                      style: TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w600,
                        color: guideColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: totalProgress,
              backgroundColor: AppColors.hexFFF3F4F6,
              valueColor: AlwaysStoppedAnimation<Color>(guideColor),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Row(
                children: includedItems
                    .map(
                      (item) => Expanded(
                        flex: item.targetRatio.clamp(1, 100),
                        child: Container(color: item.accentColor),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetSettingCard extends StatelessWidget {
  const _TargetSettingCard({
    required this.item,
    required this.onToggle,
    required this.onDecrease,
    required this.onIncrease,
    required this.onSliderChanged,
  });

  final _TargetItem item;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final ValueChanged<double>? onSliderChanged;

  @override
  Widget build(BuildContext context) {
    final isEnabled = item.isIncluded;
    final ratioDiff = (item.targetRatio - item.actualRatio).toStringAsFixed(1);
    final isOverTarget = item.targetRatio >= item.actualRatio;
    final diffColor =
        isOverTarget ? context.appColors.danger : context.appColors.success;
    final diffPrefix = isOverTarget ? '▲' : '▼';
    final displayOpacity = isEnabled ? 1.0 : 0.58;

    return Opacity(
      opacity: displayOpacity,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.rgba_0_0_0_005,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Switch(
                  value: isEnabled,
                  onChanged: onToggle,
                  activeColor: AppColors.white,
                  activeTrackColor: item.accentColor,
                  inactiveThumbColor: AppColors.white,
                  inactiveTrackColor: AppColors.hexFFCBD5E1,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(item.icon, size: 18, color: item.accentColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (isEnabled)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: item.iconBackgroundColor,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '실제 ${item.actualRatio.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  height: 16.5 / 11,
                                  fontWeight: FontWeight.w500,
                                  color: item.accentColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$diffPrefix${ratioDiff.replaceFirst('-', '')}%p',
                              style: TextStyle(
                                fontSize: 11,
                                height: 16.5 / 11,
                                fontWeight: FontWeight.w500,
                                color: diffColor,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          '포트폴리오 제외',
                          style: TextStyle(
                            fontSize: 11,
                            height: 16.5 / 11,
                            fontWeight: FontWeight.w400,
                            color: context.appColors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isEnabled)
                  Row(
                    children: [
                      _RatioStepper(
                        value: item.targetRatio,
                        color: item.accentColor,
                        onDecrease: onDecrease,
                        onIncrease: onIncrease,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '%',
                        style: TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          color: context.appColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (isEnabled) ...[
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 8,
                  inactiveTrackColor: AppColors.hexFFF3F4F6,
                  activeTrackColor: item.accentColor,
                  thumbColor: item.accentColor,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 7,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                ),
                child: Slider(
                  value: item.targetRatio.toDouble(),
                  max: 100,
                  min: 0,
                  onChanged: onSliderChanged,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Row(
                  children: [
                    Text(
                      '0%',
                      style: TextStyle(
                        fontSize: 10,
                        height: 15 / 10,
                        color: AppColors.hexFFCBD5E1,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '↑ 실제 ${item.actualRatio.round()}%',
                      style: TextStyle(
                        fontSize: 10,
                        height: 15 / 10,
                        color: item.accentColor.withValues(alpha: 0.7),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '100%',
                      style: TextStyle(
                        fontSize: 10,
                        height: 15 / 10,
                        color: AppColors.hexFFCBD5E1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RatioStepper extends StatelessWidget {
  const _RatioStepper({
    required this.value,
    required this.color,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int value;
  final Color color;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          _StepButton(symbol: '−', onTap: onDecrease),
          Expanded(
            child: Center(
              child: Text(
                '$value',
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          _StepButton(symbol: '+', onTap: onIncrease),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.symbol, required this.onTap});

  final String symbol;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 28,
        height: 32,
        child: Center(
          child: Text(
            symbol,
            style: TextStyle(
              fontSize: 16,
              height: 24 / 16,
              color: context.appColors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.backgroundColor,
    required this.iconColor,
    required this.icon,
    required this.onTap,
  });

  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}

class _TargetItem {
  _TargetItem({
    required this.name,
    required this.accentColor,
    required this.icon,
    required this.iconBackgroundColor,
    required this.actualRatio,
    required this.targetRatio,
    required this.isIncluded,
  });

  final String name;
  final Color accentColor;
  final IconData icon;
  final Color iconBackgroundColor;
  final double actualRatio;
  int targetRatio;
  bool isIncluded;
}
