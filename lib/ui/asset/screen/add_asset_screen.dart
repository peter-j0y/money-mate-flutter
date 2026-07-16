import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_mate/data/local/app_database.dart';
import 'package:money_mate/data/model/entities/asset_entry.dart';
import 'package:money_mate/ui/asset/screen/portfolio_target_setting_screen.dart';
import 'package:money_mate/ui/asset/view_models/add_asset_view_model.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class AddAssetScreen extends StatefulWidget {
  const AddAssetScreen({super.key, this.initialAsset});

  final Asset? initialAsset;

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final AddAssetViewModel _viewModel = AddAssetViewModel();
  int _step = 1;
  int _selectedIndex = 0;

  final TextEditingController _assetNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController(
    text: '0',
  );
  final TextEditingController _sharesController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController(
    text: '0',
  );
  final FocusNode _assetNameFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _unitPriceFocusNode = FocusNode();
  final FocusNode _sharesFocusNode = FocusNode();
  int _amount = 0;
  int _unitPrice = 0;
  double? _shares;
  bool _includeInPortfolio = true;

  static const List<int> _quickAmounts = [
    500000,
    1000000,
    5000000,
    10000000,
    100000000,
  ];

  static const List<_AssetTypeOption> _assetTypes = [
    _AssetTypeOption(
      type: AssetType.stock,
      title: '주식',
      icon: Icons.trending_up_rounded,
      accentColor: AppColors.hexFF3B82F6,
    ),
    _AssetTypeOption(
      type: AssetType.cash,
      title: '현금',
      icon: Icons.account_balance_wallet_rounded,
      accentColor: AppColors.hexFF10B981,
    ),
    _AssetTypeOption(
      type: AssetType.realEstate,
      title: '부동산',
      icon: Icons.home_work_outlined,
      accentColor: AppColors.hexFFF59E0B,
    ),
    _AssetTypeOption(
      type: AssetType.crypto,
      title: '가상화폐',
      icon: Icons.currency_bitcoin_rounded,
      accentColor: AppColors.hexFF8B5CF6,
    ),
    _AssetTypeOption(
      type: AssetType.savings,
      title: '예적금',
      icon: Icons.savings_outlined,
      accentColor: AppColors.hexFF0EA5E9,
    ),
    _AssetTypeOption(
      type: AssetType.commodity,
      title: '원자재',
      icon: Icons.all_inclusive_rounded,
      accentColor: AppColors.hexFFEF4444,
    ),
    _AssetTypeOption(
      type: AssetType.other,
      title: '기타',
      icon: Icons.category_outlined,
      accentColor: AppColors.hexFF6B7280,
    ),
  ];

  _AssetTypeOption get _selectedAssetType => _assetTypes[_selectedIndex];
  bool get _isStockAsset => _selectedAssetType.type == AssetType.stock;
  bool get _isEditMode => widget.initialAsset != null;

  bool get _isSubmitEnabled =>
      _assetNameController.text.trim().isNotEmpty &&
      _amount > 0 &&
      !_viewModel.isSaving &&
      (!_includeInPortfolio ||
          _viewModel.isCategoryInPortfolio(_selectedAssetType.type));

  @override
  void initState() {
    super.initState();
    final initial = widget.initialAsset;
    if (initial == null) {
      return;
    }

    _step = 2;
    final type = AssetTypeFromCode.fromCode(initial.assetType);
    final index = _assetTypes.indexWhere((option) => option.type == type);
    _selectedIndex = index >= 0 ? index : 0;
    _assetNameController.text = initial.assetName;
    _setAmount(initial.amount);
    _includeInPortfolio = initial.includeInPortfolio;
    if (_isStockAsset && initial.shares != null && initial.shares! > 0) {
      _shares = initial.shares;
      _sharesController.text = _formatShares(_shares);
      _unitPrice = (initial.amount / initial.shares!).round();
      _unitPriceController.text = _formatWithComma(_unitPrice);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _assetNameController.dispose();
    _amountController.dispose();
    _sharesController.dispose();
    _unitPriceController.dispose();
    _assetNameFocusNode.dispose();
    _amountFocusNode.dispose();
    _unitPriceFocusNode.dispose();
    _sharesFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    final contentBottomPadding = safeAreaBottom + 120;

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                _TopBar(
                  currentStep: _step,
                  isEditMode: _isEditMode,
                  onCloseTap: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      if (_step == 1)
                        _buildStepOneContent(context, contentBottomPadding)
                      else
                        _buildStepTwoContent(context, contentBottomPadding),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: _BottomActionArea(
                          step: _step,
                          isEditMode: _isEditMode,
                          safeAreaBottom: safeAreaBottom,
                          selectedTypeTitle: _selectedAssetType.title,
                          isSubmitEnabled: _isSubmitEnabled,
                          onNextTap: () => setState(() => _step = 2),
                          onBackTap: () {
                            if (_isEditMode) {
                              Navigator.of(context).pop();
                            } else {
                              setState(() => _step = 1);
                            }
                          },
                          onSubmitTap: () {
                            _onSubmitTap();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _onSubmitTap() async {
    if (!_isSubmitEnabled) {
      return;
    }

    final initial = widget.initialAsset;
    final isSuccess =
        initial == null
            ? await _viewModel.saveAsset(
              assetType: _selectedAssetType.type,
              assetName: _assetNameController.text.trim(),
              amount: _amount,
              shares: _isStockAsset ? _shares : null,
              includeInPortfolio: _includeInPortfolio,
            )
            : await _viewModel.updateAsset(
              id: initial.id,
              assetType: _selectedAssetType.type,
              assetName: _assetNameController.text.trim(),
              amount: _amount,
              shares: _isStockAsset ? _shares : null,
              includeInPortfolio: _includeInPortfolio,
            );

    if (!mounted) {
      return;
    }

    if (isSuccess) {
      Navigator.of(context).pop(true);
      return;
    }

    final message = _viewModel.errorMessage ?? '저장에 실패했습니다.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onSharesChanged(String value) {
    final normalized = value.replaceAll(',', '.');
    setState(() {
      _shares = normalized.isEmpty ? null : double.tryParse(normalized);
      _recalculateStockAmount();
    });
  }

  void _onAssetTypeSelected(int index) {
    if (_selectedIndex == index) {
      return;
    }

    setState(() {
      _selectedIndex = index;
      _assetNameController.clear();
      _unitPriceController.text = '0';
      _unitPrice = 0;
    });
  }

  void _recalculateStockAmount() {
    final shares = _shares;
    if (shares == null || shares <= 0 || _unitPrice <= 0) {
      _setAmount(0);
      return;
    }

    _setAmount((shares * _unitPrice).round());
  }

  void _setAmount(int value) {
    _amount = value;
    _amountController.text = _formatWithComma(value);
  }

  Widget _buildStepOneContent(
    BuildContext context,
    double contentBottomPadding,
  ) {
    return Column(
      children: [
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '어떤 종류의 자산인가요?',
              style: TextStyle(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w400,
                color: context.appColors.textTertiary,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '자산 유형 선택',
              style: TextStyle(
                fontSize: 20,
                height: 30 / 20,
                fontWeight: FontWeight.w700,
                color: context.appColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(16, 0, 16, contentBottomPadding),
            itemCount: _assetTypes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final option = _assetTypes[index];
              final isSelected = _selectedIndex == index;
              return _AssetTypeCard(
                option: option,
                isSelected: isSelected,
                onTap: () => _onAssetTypeSelected(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStepTwoContent(
    BuildContext context,
    double contentBottomPadding,
  ) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, contentBottomPadding),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _AssetTypeChip(
            title: _selectedAssetType.title,
            icon: _selectedAssetType.icon,
            color: _selectedAssetType.accentColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '자산 정보를 입력해주세요',
          style: TextStyle(
            fontSize: 20,
            height: 30 / 20,
            fontWeight: FontWeight.w700,
            color: context.appColors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        if (!_isStockAsset) ...[
          _SectionLabel(text: '자산명'),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _assetNameController,
            hintText: '예: 국민은행 통장, 아파트...',
            onChanged: (_) => setState(() {}),
            focusNode: _assetNameFocusNode,
            textInputAction: TextInputAction.next,
            onSubmitted:
                (_) => FocusScope.of(context).requestFocus(_amountFocusNode),
          ),
          const SizedBox(height: 20),
        ],
        if (_isStockAsset) ...[
          _StockHoldingSection(
            nameController: _assetNameController,
            sharesController: _sharesController,
            unitPriceController: _unitPriceController,
            shares: _shares,
            evaluatedAmount: _amount,
            onNameChanged: (_) => setState(() {}),
            onSharesChanged: _onSharesChanged,
            onUnitPriceChanged: (value) {
              setState(() {
                _unitPrice = value;
                _recalculateStockAmount();
              });
            },
            nameFocusNode: _assetNameFocusNode,
            unitPriceFocusNode: _unitPriceFocusNode,
            sharesFocusNode: _sharesFocusNode,
          ),
        ] else ...[
          _SectionLabel(text: '현재 금액'),
          const SizedBox(height: 8),
          _AmountInputField(
            controller: _amountController,
            onChanged: (value) {
              _amount = value;
              setState(() {});
            },
            focusNode: _amountFocusNode,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _quickAmounts
                    .map(
                      (amount) => _QuickAmountButton(
                        label: '+${_toKoreanUnit(amount)}',
                        onTap: () {
                          _amount += amount;
                          _amountController.text = _formatWithComma(_amount);
                          setState(() {});
                        },
                      ),
                    )
                    .toList(),
          ),
        ],
        const SizedBox(height: 20),
        _SectionLabel(text: '포트폴리오 관리'),
        const SizedBox(height: 8),
        _PortfolioOptionCard(
          title: '포트폴리오에 포함',
          subtitle: '목표 비율 차트에 반영돼요',
          icon: Icons.pie_chart_outline_rounded,
          accentColor: AppColors.hexFF6B7280,
          selected: _includeInPortfolio,
          onTap: () => setState(() => _includeInPortfolio = true),
        ),
        if (_includeInPortfolio &&
            !_viewModel.isCategoryInPortfolio(_selectedAssetType.type))
          _PortfolioCategoryWarning(
            categoryName: _selectedAssetType.title,
            onSettingsTap: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => const PortfolioTargetSettingScreen(),
                ),
              );
              if (result == true) {
                _viewModel.refreshPortfolioTargets();
              }
            },
          ),
        const SizedBox(height: 8),
        _PortfolioOptionCard(
          title: '포트폴리오에서 제외',
          subtitle: '자산 총액에는 포함되지만 비율 계산에서 빠져요',
          icon: Icons.inventory_2_outlined,
          accentColor: AppColors.hexFF6B7280,
          selected: !_includeInPortfolio,
          onTap: () => setState(() => _includeInPortfolio = false),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.currentStep,
    required this.isEditMode,
    required this.onCloseTap,
  });

  final int currentStep;
  final bool isEditMode;
  final VoidCallback onCloseTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  onPressed: onCloseTap,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 24,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
            ),
            Center(
              child: _TitleWithStepDot(
                currentStep: currentStep,
                isEditMode: isEditMode,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleWithStepDot extends StatelessWidget {
  const _TitleWithStepDot({
    required this.currentStep,
    required this.isEditMode,
  });

  final int currentStep;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    final inactiveDotColor = context.appColors.primary.withValues(alpha: 0.35);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isEditMode ? '자산 수정' : '자산 추가',
          style: TextStyle(
            fontSize: 18,
            height: 20 / 14,
            fontWeight: FontWeight.w600,
            color: context.appColors.textPrimary,
          ),
        ),
        if (!isEditMode) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                currentStep == 1
                    ? [
                      _StepDot(width: 18, color: context.appColors.primary),
                      const SizedBox(width: 6),
                      _StepDot(width: 6, color: inactiveDotColor),
                    ]
                    : [
                      _StepDot(width: 6, color: inactiveDotColor),
                      const SizedBox(width: 6),
                      _StepDot(width: 18, color: context.appColors.primary),
                    ],
          ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.width, required this.color});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _BottomActionArea extends StatelessWidget {
  const _BottomActionArea({
    required this.step,
    required this.isEditMode,
    required this.safeAreaBottom,
    required this.selectedTypeTitle,
    required this.isSubmitEnabled,
    required this.onNextTap,
    required this.onBackTap,
    required this.onSubmitTap,
  });

  final int step;
  final bool isEditMode;
  final double safeAreaBottom;
  final String selectedTypeTitle;
  final bool isSubmitEnabled;
  final VoidCallback onNextTap;
  final VoidCallback onBackTap;
  final VoidCallback onSubmitTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 28,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.appColors.background.withValues(alpha: 0),
                    context.appColors.background.withValues(alpha: 0.65),
                    context.appColors.background,
                  ],
                  stops: const [0, 0.6, 1],
                ),
              ),
            ),
          ),
          Container(
            color: context.appColors.background,
            padding: EdgeInsets.fromLTRB(
              step == 1 ? 16 : 20,
              0,
              step == 1 ? 16 : 20,
              safeAreaBottom + 8,
            ),
            child:
                step == 1
                    ? SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: FilledButton(
                        onPressed: onNextTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: context.appColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                          shadowColor: AppColors.rgba_19_127_236_025,
                        ),
                        child: Text(
                          '$selectedTypeTitle 자산 추가',
                          style: TextStyle(
                            fontSize: 18,
                            height: 28 / 18,
                            fontWeight: FontWeight.w500,
                            color: context.appColors.inverseText,
                          ),
                        ),
                      ),
                    )
                    : Row(
                      children: [
                        if (!isEditMode) ...[
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: FilledButton(
                              onPressed: onBackTap,
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    context.appColors.surfaceMuted,
                                foregroundColor:
                                    context.appColors.textSecondary,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(56, 56),
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                alignment: Alignment.center,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: FilledButton(
                              onPressed: isSubmitEnabled ? onSubmitTap : null,
                              style: FilledButton.styleFrom(
                                backgroundColor: context.appColors.primary,
                                disabledBackgroundColor: context
                                    .appColors
                                    .primary
                                    .withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                isEditMode ? '수정하기' : '자산 추가',
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 24 / 16,
                                  fontWeight: FontWeight.w600,
                                  color: context.appColors.inverseText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}

class _AssetTypeCard extends StatelessWidget {
  const _AssetTypeCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _AssetTypeOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedBackgroundColor = option.accentColor.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.12,
    );
    final iconBackgroundColor = option.accentColor.withValues(alpha: 0.12);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 84,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color:
              isSelected ? selectedBackgroundColor : context.appColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? option.accentColor : context.appColors.border,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? option.accentColor : iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                option.icon,
                size: 22,
                color:
                    isSelected
                        ? context.appColors.inverseText
                        : option.accentColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option.title,
                style: TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected
                          ? option.accentColor
                          : context.appColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: option.accentColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: context.appColors.inverseText,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AssetTypeChip extends StatelessWidget {
  const _AssetTypeChip({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w500,
        color: context.appColors.textSecondary,
      ),
    );
  }
}

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.appColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.border, width: 2),
      ),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        focusNode: focusNode,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: context.appColors.textPrimary,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: context.appColors.textPrimary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

class _AmountInputField extends StatelessWidget {
  const _AmountInputField({
    required this.controller,
    required this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<int> onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
      decoration: BoxDecoration(
        color: context.appColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.border, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: textInputAction,
              onSubmitted: onSubmitted,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: context.appColors.textPrimary,
              ),
              onChanged: (value) {
                final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
                final parsed = digitsOnly.isEmpty ? 0 : int.parse(digitsOnly);
                final formatted = _formatWithComma(parsed);
                controller.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
                onChanged(parsed);
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: '0',
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: context.appColors.textPrimary.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          Text(
            '원',
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w400,
              color: context.appColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StockHoldingSection extends StatelessWidget {
  const _StockHoldingSection({
    required this.nameController,
    required this.sharesController,
    required this.unitPriceController,
    required this.shares,
    required this.evaluatedAmount,
    required this.onNameChanged,
    required this.onSharesChanged,
    required this.onUnitPriceChanged,
    required this.nameFocusNode,
    required this.unitPriceFocusNode,
    required this.sharesFocusNode,
  });

  final TextEditingController nameController;
  final TextEditingController sharesController;
  final TextEditingController unitPriceController;
  final double? shares;
  final int evaluatedAmount;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onSharesChanged;
  final ValueChanged<int> onUnitPriceChanged;
  final FocusNode nameFocusNode;
  final FocusNode unitPriceFocusNode;
  final FocusNode sharesFocusNode;

  @override
  Widget build(BuildContext context) {
    final summaryBg = context.appColors.primary.withValues(alpha: 0.12);
    final summaryPrimary = context.appColors.primary;
    final summarySecondary = context.appColors.primary.withValues(alpha: 0.55);
    final sharesText = _formatShares(shares);
    final evaluatedText = _toKoreanWon(evaluatedAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(text: '종목명'),
        const SizedBox(height: 8),
        _AppTextField(
          controller: nameController,
          hintText: '예: 삼성전자, Apple Inc.',
          onChanged: onNameChanged,
          focusNode: nameFocusNode,
          textInputAction: TextInputAction.next,
          onSubmitted:
              (_) => FocusScope.of(context).requestFocus(unitPriceFocusNode),
        ),
        const SizedBox(height: 20),
        _SectionLabel(text: '1주당 가격'),
        const SizedBox(height: 8),
        _AmountInputField(
          controller: unitPriceController,
          onChanged: onUnitPriceChanged,
          focusNode: unitPriceFocusNode,
          textInputAction: TextInputAction.next,
          onSubmitted:
              (_) => FocusScope.of(context).requestFocus(sharesFocusNode),
        ),
        const SizedBox(height: 20),
        _SectionLabel(text: '보유 주수'),
        const SizedBox(height: 8),
        Container(
          height: 56,
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
          decoration: BoxDecoration(
            color: context.appColors.surfaceMuted,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appColors.border, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: sharesController,
                  focusNode: sharesFocusNode,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (RegExp(r'^\d*\.?\d*$').hasMatch(newValue.text)) {
                        return newValue;
                      }
                      return oldValue;
                    }),
                  ],
                  onChanged: onSharesChanged,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: context.appColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: '예: 10 또는 10.5',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: context.appColors.textPrimary.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                '주',
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
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          decoration: BoxDecoration(
            color: summaryBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '평가금액',
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w400,
                  color: summaryPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '$sharesText주',
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w600,
                      color: summaryPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '×',
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w400,
                      color: summarySecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${unitPriceController.text}원',
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w600,
                      color: summaryPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '= $evaluatedText',
                style: TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w700,
                  color: summaryPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  const _QuickAmountButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: context.appColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w500,
                color: context.appColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioCategoryWarning extends StatelessWidget {
  const _PortfolioCategoryWarning({
    required this.categoryName,
    required this.onSettingsTap,
  });

  final String categoryName;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final warningColor = context.appColors.warning;
    final bgColor = warningColor.withValues(alpha: isDark ? 0.15 : 0.1);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: warningColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: warningColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$categoryName 카테고리가 포트폴리오에 없습니다',
                  style: TextStyle(
                    fontSize: 13,
                    height: 18 / 13,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '포트폴리오 설정에서 카테고리를 추가해주세요',
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w400,
                    color: context.appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: onSettingsTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: context.appColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '포트폴리오 설정',
                          style: TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            fontWeight: FontWeight.w500,
                            color: context.appColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: context.appColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioOptionCard extends StatelessWidget {
  const _PortfolioOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedColor = context.appColors.primary;
    final selectedBackgroundColor = selectedColor.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.18 : 0.12,
    );
    final iconBackgroundColor =
        selected
            ? selectedColor
            : context.appColors.textTertiary.withValues(alpha: 0.18);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? selectedBackgroundColor : context.appColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? selectedColor : context.appColors.border,
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 18,
                color: selected ? context.appColors.inverseText : accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w600,
                      color:
                          selected
                              ? selectedColor
                              : context.appColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w500,
                      color: context.appColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetTypeOption {
  const _AssetTypeOption({
    required this.type,
    required this.title,
    required this.icon,
    required this.accentColor,
  });

  final AssetType type;
  final String title;
  final IconData icon;
  final Color accentColor;
}

String _formatWithComma(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final reverseIndex = raw.length - i;
    buffer.write(raw[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}

String _toKoreanUnit(int amount) {
  if (amount >= 100000000) return '1억';
  return '${amount ~/ 10000}만';
}

String _formatShares(double? value) {
  if (value == null || value <= 0) {
    return '0';
  }
  if (value == value.truncateToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
}

String _toKoreanWon(int amount) {
  if (amount <= 0) {
    return '0원';
  }
  final eok = amount ~/ 100000000;
  final man = (amount % 100000000) ~/ 10000;
  final won = amount % 10000;

  final parts = <String>[];
  if (eok > 0) {
    parts.add('${_formatWithComma(eok)}억');
  }
  if (man > 0) {
    parts.add('${_formatWithComma(man)}만');
  }
  if (won > 0) {
    parts.add(_formatWithComma(won));
  }
  return '${parts.join(' ')}원';
}
