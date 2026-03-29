import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

void showAddAssetBottomSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
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
  final _assetNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _pricePerShareController = TextEditingController();
  final _targetWeightController = TextEditingController(text: '5.0');

  static const _assetTypes = [
    _AddAssetTypeOption(
      label: '주식',
      icon: Icons.stacked_line_chart_rounded,
      color: AppColors.hexFFFEF2F2,
      iconColor: AppColors.hexFFEF4444,
    ),
    _AddAssetTypeOption(
      label: '예적금',
      icon: Icons.savings_rounded,
      color: AppColors.hexFFEEF2FF,
      iconColor: AppColors.hexFF6366F1,
    ),
    _AddAssetTypeOption(
      label: '부동산',
      icon: Icons.apartment_rounded,
      color: AppColors.hexFFFFFBEB,
      iconColor: AppColors.hexFFF59E0B,
    ),
    _AddAssetTypeOption(
      label: '가상화폐',
      icon: Icons.currency_bitcoin_rounded,
      color: AppColors.hexFFF3E8FF,
      iconColor: AppColors.hexFF7C3AED,
    ),
  ];

  @override
  void dispose() {
    _assetNameController.dispose();
    _quantityController.dispose();
    _pricePerShareController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return SafeArea(
      top: false,
      child: Container(
        height: maxHeight,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.hexFFE5E7EB,
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
                            color: AppColors.hexFF1E293B,
                          ),
                        ),
                        Text(
                          '추가할 자산 정보를 입력해 주세요',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            color: AppColors.hexFF64748B,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.hexFFF3F4F6,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.hexFF64748B,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.hexFFF9FAFB,
            ),
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
                    _AssetTextField(
                      controller: _assetNameController,
                      hintText: '종목명을 입력해 주세요',
                      prefixIcon: Icons.search_rounded,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _AssetTextField(
                            controller: _quantityController,
                            hintText: '보유 수량',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AssetTextField(
                            controller: _targetWeightController,
                            hintText: '목표 비중(%)',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _AssetTextField(
                      controller: _pricePerShareController,
                      hintText: '1주당 가격',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      decoration: BoxDecoration(
                        color: AppColors.rgba_224_242_254_03,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.hexFFE0F2FE),
                      ),
                      child: Text(
                        '입력한 목표 비중을 기준으로 포트폴리오 균형을 계산합니다.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.hexFF334155,
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
                        color: AppColors.hexFFF9FAFB,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.hexFFF3F4F6),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: AppColors.hexFF94A3B8,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '저장 후 자산 구성 비중이 자동으로 업데이트됩니다.',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: AppColors.hexFF64748B,
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
                    backgroundColor: AppColors.hexFF34D399,
                    foregroundColor: AppColors.white,
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
          color: selected ? AppColors.rgba_209_250_229_03 : AppColors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? AppColors.hexFF34D399 : AppColors.hexFFF3F4F6,
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
                color: AppColors.hexFF334155,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetTextField extends StatelessWidget {
  const _AssetTextField({
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.hexFFF9FAFB,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hexFFF3F4F6),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: hintText,
          hintStyle: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.hexFF94A3B8),
          prefixIcon:
              prefixIcon == null
                  ? null
                  : Icon(prefixIcon, color: AppColors.hexFF94A3B8, size: 20),
          prefixIconConstraints:
              prefixIcon == null
                  ? null
                  : const BoxConstraints(minWidth: 24, minHeight: 24),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
