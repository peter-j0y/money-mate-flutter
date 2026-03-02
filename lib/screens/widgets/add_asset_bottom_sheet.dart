import 'package:flutter/material.dart';

void showAddAssetBottomSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _AddAssetBottomSheet(),
  );
}

class _AddAssetBottomSheet extends StatefulWidget {
  const _AddAssetBottomSheet();

  @override
  State<_AddAssetBottomSheet> createState() => _AddAssetBottomSheetState();
}

class _AddAssetBottomSheetState extends State<_AddAssetBottomSheet> {
  int _selectedType = 0;
  int _quantity = 5;

  static const _assetTypes = [
    _AddAssetTypeOption(
      label: '주식',
      icon: Icons.stacked_line_chart_rounded,
      color: Color(0xFFFEF2F2),
      iconColor: Color(0xFFEF4444),
    ),
    _AddAssetTypeOption(
      label: '예적금',
      icon: Icons.savings_rounded,
      color: Color(0xFFEEF2FF),
      iconColor: Color(0xFF6366F1),
    ),
    _AddAssetTypeOption(
      label: '부동산',
      icon: Icons.apartment_rounded,
      color: Color(0xFFFFFBEB),
      iconColor: Color(0xFFF59E0B),
    ),
    _AddAssetTypeOption(
      label: '가상화폐',
      icon: Icons.currency_bitcoin_rounded,
      color: Color(0xFFF3E8FF),
      iconColor: Color(0xFF7C3AED),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return SafeArea(
      top: false,
      child: Container(
        height: maxHeight,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '자산 추가',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontSize: 22,
                            height: 32 / 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          '추가할 자산 정보를 입력해 주세요',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF9FAFB)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_assetTypes.length, (index) {
                          final option = _assetTypes[index];
                          final selected = index == _selectedType;
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index == _assetTypes.length - 1 ? 0 : 12,
                            ),
                            child: _AssetTypeCard(
                              option: option,
                              selected: selected,
                              onTap:
                                  () => setState(() => _selectedType = index),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '종목 또는 자산명을 검색해 주세요',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: const Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _InputCard(
                            title: '수량',
                            value: '$_quantity',
                            onMinus: () {
                              if (_quantity > 0) {
                                setState(() => _quantity -= 1);
                              }
                            },
                            onPlus: () => setState(() => _quantity += 1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: _InputCard(title: '목표 비중(%)', value: '5.0'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(224, 242, 254, 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0F2FE)),
                      ),
                      child: Text(
                        '입력한 목표 비중을 기준으로 포트폴리오 균형을 계산합니다.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF334155),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '저장 후 자산 구성 비중이 자동으로 업데이트됩니다.',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF34D399),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text(
                    '자산 추가하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetTypeCard extends StatelessWidget {
  const _AssetTypeCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _AddAssetTypeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 104,
        height: 90,
        decoration: BoxDecoration(
          color:
              selected
                  ? const Color.fromRGBO(209, 250, 229, 0.3)
                  : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? const Color(0xFF34D399) : const Color(0xFFF3F4F6),
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: option.color,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Icon(option.icon, size: 22, color: option.iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              option.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.title,
    required this.value,
    this.onMinus,
    this.onPlus,
  });

  final String title;
  final String value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$title  $value',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _CircleIconButton(icon: Icons.remove_rounded, onTap: onMinus),
          const SizedBox(width: 6),
          _CircleIconButton(icon: Icons.add_rounded, onTap: onPlus),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Ink(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFDBEAFE)),
          ),
          child: Center(
            child: Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
          ),
        ),
      ),
    );
  }
}

class _AddAssetTypeOption {
  const _AddAssetTypeOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color iconColor;
}
