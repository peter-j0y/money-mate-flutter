import 'package:flutter/material.dart';
import 'package:money_mate/data/model/entities/asset_entry.dart';
import 'package:money_mate/data/model/entities/stock_lookup_result.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/asset/view_models/add_asset_view_model.dart';

class AddAssetScreen extends StatefulWidget {
  const AddAssetScreen({super.key});

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final AddAssetViewModel _viewModel = AddAssetViewModel();
  static const int _usdToKrwRate = 1380;
  int _step = 1;
  int _selectedIndex = 0;

  final TextEditingController _assetNameController = TextEditingController();
  final TextEditingController _stockCodeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController(
    text: '0',
  );
  final TextEditingController _sharesController = TextEditingController();
  int _amount = 0;
  int _calculatedStockAmount = 0;
  double? _shares;
  bool _includeInPortfolio = true;
  StockLookupResult? _stockLookupResult;
  String? _stockLookupError;
  bool _isStockLookupLoading = false;

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
      subtitle: '국내·해외 주식, ETF',
      icon: Icons.trending_up_rounded,
      accentColor: AppColors.hexFF3B82F6,
      iconBackgroundColor: AppColors.hexFFF3F4F6,
      selectedBackgroundColor: AppColors.hexFFEEF2FF,
    ),
    _AssetTypeOption(
      type: AssetType.cash,
      title: '현금',
      subtitle: '은행 잔고, 현금',
      icon: Icons.account_balance_wallet_rounded,
      accentColor: AppColors.hexFF10B981,
      iconBackgroundColor: AppColors.hexFFF3F4F6,
      selectedBackgroundColor: AppColors.hexFFECFDF5,
    ),
    _AssetTypeOption(
      type: AssetType.realEstate,
      title: '부동산',
      subtitle: '아파트, 토지, 보증금',
      icon: Icons.home_work_outlined,
      accentColor: AppColors.hexFFF59E0B,
      iconBackgroundColor: AppColors.hexFFF3F4F6,
      selectedBackgroundColor: AppColors.hexFFFFFBEB,
    ),
    _AssetTypeOption(
      type: AssetType.crypto,
      title: '가상화폐',
      subtitle: '비트코인, 이더리움 등',
      icon: Icons.currency_bitcoin_rounded,
      accentColor: AppColors.hexFF8B5CF6,
      iconBackgroundColor: AppColors.hexFFF3F4F6,
      selectedBackgroundColor: AppColors.hexFFF5F3FF,
    ),
    _AssetTypeOption(
      type: AssetType.savings,
      title: '예적금',
      subtitle: '정기예금, 적금',
      icon: Icons.savings_outlined,
      accentColor: AppColors.hexFF0EA5E9,
      iconBackgroundColor: AppColors.hexFFF3F4F6,
      selectedBackgroundColor: AppColors.hexFFE0F2FE,
    ),
    _AssetTypeOption(
      type: AssetType.commodity,
      title: '원자재',
      subtitle: '금, 은, 원유 등',
      icon: Icons.all_inclusive_rounded,
      accentColor: AppColors.hexFFEF4444,
      iconBackgroundColor: AppColors.hexFFF3F4F6,
      selectedBackgroundColor: AppColors.hexFFFEF2F2,
    ),
    _AssetTypeOption(
      type: AssetType.other,
      title: '기타',
      subtitle: '그 외 모든 자산',
      icon: Icons.category_outlined,
      accentColor: AppColors.hexFF6B7280,
      iconBackgroundColor: AppColors.hexFFF3F4F6,
      selectedBackgroundColor: AppColors.hexFFF3F4F6,
    ),
  ];

  _AssetTypeOption get _selectedAssetType => _assetTypes[_selectedIndex];
  bool get _isStockAsset => _selectedAssetType.type == AssetType.stock;

  bool get _isSubmitEnabled =>
      _assetNameController.text.trim().isNotEmpty &&
      _amount > 0 &&
      !_viewModel.isSaving;

  bool get _isStockLookupEnabled =>
      _stockCodeController.text.trim().isNotEmpty && !_isStockLookupLoading;

  @override
  void dispose() {
    _viewModel.dispose();
    _assetNameController.dispose();
    _stockCodeController.dispose();
    _amountController.dispose();
    _sharesController.dispose();
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
                          safeAreaBottom: safeAreaBottom,
                          selectedTypeTitle: _selectedAssetType.title,
                          isSubmitEnabled: _isSubmitEnabled,
                          onNextTap: () => setState(() => _step = 2),
                          onBackTap: () => setState(() => _step = 1),
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

    final isSuccess = await _viewModel.saveAsset(
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
      _stockCodeController.clear();
      _stockLookupResult = null;
      _stockLookupError = null;
      _isStockLookupLoading = false;
      _calculatedStockAmount = 0;
    });
  }

  void _onStockCodeChanged(String value) {
    final normalized = value.trim().toUpperCase();
    setState(() {
      if (_stockLookupResult != null &&
          normalized != _stockLookupResult!.code) {
        _stockLookupResult = null;
        _assetNameController.clear();
      }
      _stockLookupError = null;
    });
  }

  Future<void> _onLookupStockTap() async {
    final inputCode = _stockCodeController.text.trim().toUpperCase();
    if (inputCode.isEmpty) {
      return;
    }

    setState(() {
      _isStockLookupLoading = true;
      _stockLookupResult = null;
      _stockLookupError = null;
    });

    final result = await _viewModel.lookupStockByCode(inputCode);

    if (!mounted) {
      return;
    }

    setState(() {
      _isStockLookupLoading = false;
      if (result == null) {
        _assetNameController.clear();
        _calculatedStockAmount = 0;
        _setAmount(0);
        _stockLookupError = '"$inputCode" 코드를 찾을 수 없어요. (예: 005930, AAPL, SPY)';
        return;
      }

      _stockLookupResult = result;
      _stockCodeController.text = result.code;
      _assetNameController.text = result.companyName;
      _recalculateStockAmount();
    });
  }

  void _onClearStockCodeTap() {
    setState(() {
      _stockCodeController.clear();
      _stockLookupResult = null;
      _stockLookupError = null;
      _assetNameController.clear();
      _calculatedStockAmount = 0;
      _setAmount(0);
    });
  }

  void _onApplyStockNameTap() {
    final result = _stockLookupResult;
    if (result == null) {
      return;
    }
    setState(() {
      _assetNameController.text = result.companyName;
      _recalculateStockAmount();
    });
  }

  void _recalculateStockAmount() {
    final result = _stockLookupResult;
    final shares = _shares;
    if (result == null || shares == null || shares <= 0) {
      _calculatedStockAmount = 0;
      _setAmount(0);
      return;
    }

    final unitPrice = _extractNumeric(result.latestPriceText);
    final exchangeRate = _exchangeRateForMarket(result.market);
    _calculatedStockAmount = (shares * unitPrice * exchangeRate).round();
    _setAmount(_calculatedStockAmount);
  }

  int _exchangeRateForMarket(String market) {
    final normalized = market.trim().toUpperCase();
    if (normalized == 'KRX' ||
        normalized == 'KOSPI' ||
        normalized == 'KOSDAQ') {
      return 1;
    }
    return _usdToKrwRate;
  }

  double _extractNumeric(String value) {
    final sanitized = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(sanitized) ?? 0;
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
        if (_isStockAsset)
          _StockLookupSection(
            codeController: _stockCodeController,
            result: _stockLookupResult,
            errorMessage: _stockLookupError,
            isLookupEnabled: _isStockLookupEnabled,
            isLookupLoading: _isStockLookupLoading,
            onCodeChanged: _onStockCodeChanged,
            onLookupTap: () {
              _onLookupStockTap();
            },
            onClearCodeTap: _onClearStockCodeTap,
            onApplyStockNameTap: _onApplyStockNameTap,
          )
        else ...[
          _SectionLabel(text: '자산명'),
          const SizedBox(height: 8),
          _AppTextField(
            controller: _assetNameController,
            hintText: '예: 국민은행 통장, 아파트...',
            onChanged: (_) => setState(() {}),
          ),
        ],
        const SizedBox(height: 20),
        if (_isStockAsset)
          _StockHoldingSection(
            stockName: _stockLookupResult?.companyName,
            sharesController: _sharesController,
            shares: _shares,
            unitPriceText: _stockLookupResult?.latestPriceText,
            exchangeRate:
                _stockLookupResult == null
                    ? _usdToKrwRate
                    : _exchangeRateForMarket(_stockLookupResult!.market),
            evaluatedAmount: _calculatedStockAmount,
            onSharesChanged: _onSharesChanged,
          ),
        const SizedBox(height: 20),
        _SectionLabel(text: '현재 금액'),
        const SizedBox(height: 8),
        _AmountInputField(
          controller: _amountController,
          onChanged: (value) {
            _amount = value;
            setState(() {});
          },
        ),
        if (!_isStockAsset) ...[
          const SizedBox(height: 12),
          Text(
            '빠른 입력',
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w400,
              color: context.appColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
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
          subtitle: '목표 비율 차트에 반영되고 리밸런싱 신호를 받아요',
          icon: Icons.pie_chart_outline_rounded,
          accentColor: AppColors.hexFF6B7280,
          selected: _includeInPortfolio,
          onTap: () => setState(() => _includeInPortfolio = true),
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
  const _TopBar({required this.currentStep, required this.onCloseTap});

  final int currentStep;
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
            Center(child: _TitleWithStepDot(currentStep: currentStep)),
          ],
        ),
      ),
    );
  }
}

class _TitleWithStepDot extends StatelessWidget {
  const _TitleWithStepDot({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const inactiveDotColor = AppColors.hexFF93C5FD;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '자산 추가',
          style: TextStyle(
            fontSize: 18,
            height: 20 / 14,
            fontWeight: FontWeight.w600,
            color: context.appColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              currentStep == 1
                  ? [
                    _StepDot(width: 18, color: context.appColors.primary),
                    const SizedBox(width: 6),
                    const _StepDot(width: 6, color: inactiveDotColor),
                  ]
                  : [
                    const _StepDot(width: 6, color: inactiveDotColor),
                    const SizedBox(width: 6),
                    _StepDot(width: 18, color: context.appColors.primary),
                  ],
        ),
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
    required this.safeAreaBottom,
    required this.selectedTypeTitle,
    required this.isSubmitEnabled,
    required this.onNextTap,
    required this.onBackTap,
    required this.onSubmitTap,
  });

  final int step;
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
                          style: const TextStyle(
                            fontSize: 18,
                            height: 28 / 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    )
                    : Row(
                      children: [
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: FilledButton(
                            onPressed: onBackTap,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.hexFFF3F4F6,
                              foregroundColor: context.appColors.textSecondary,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(56, 56),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                              child: const Text(
                                '자산 추가',
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 24 / 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 84,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? option.selectedBackgroundColor
                  : context.appColors.surface,
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
                color:
                    isSelected
                        ? option.accentColor
                        : option.iconBackgroundColor,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
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
                  const SizedBox(height: 2),
                  Text(
                    option.subtitle,
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
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: option.accentColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: AppColors.white,
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
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.hexFFF8FAFC,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hexFFF3F4F6, width: 2),
      ),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
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

class _StockLookupSection extends StatelessWidget {
  const _StockLookupSection({
    required this.codeController,
    required this.result,
    required this.errorMessage,
    required this.isLookupEnabled,
    required this.isLookupLoading,
    required this.onCodeChanged,
    required this.onLookupTap,
    required this.onClearCodeTap,
    required this.onApplyStockNameTap,
  });

  final TextEditingController codeController;
  final StockLookupResult? result;
  final String? errorMessage;
  final bool isLookupEnabled;
  final bool isLookupLoading;
  final ValueChanged<String> onCodeChanged;
  final VoidCallback onLookupTap;
  final VoidCallback onClearCodeTap;
  final VoidCallback onApplyStockNameTap;

  @override
  Widget build(BuildContext context) {
    final isMatched = result != null;
    final successColor = context.appColors.success;
    final successBackground = successColor.withValues(alpha: 0.12);
    final successBorder = successColor.withValues(alpha: 0.55);
    final primaryBadgeBackground = context.appColors.primary.withValues(
      alpha: 0.18,
    );
    final successBadgeBackground = successColor.withValues(alpha: 0.18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: context.appColors.textSecondary,
                ),
                children: [
                  const TextSpan(text: '종목 코드 '),
                  TextSpan(
                    text: '(선택)',
                    style: TextStyle(
                      color: context.appColors.textTertiary.withValues(
                        alpha: 0.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              height: 21,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: context.appColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: Text(
                '추후 가격 자동 연동',
                style: TextStyle(
                  fontSize: 11,
                  height: 16.5 / 11,
                  fontWeight: FontWeight.w500,
                  color: context.appColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: context.appColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isMatched ? successColor : context.appColors.border,
                    width: 2,
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: codeController,
                        onChanged: onCodeChanged,
                        textCapitalization: TextCapitalization.characters,
                        style: TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight:
                              isMatched ? FontWeight.w600 : FontWeight.w400,
                          color:
                              isMatched
                                  ? successColor.withValues(alpha: 0.7)
                                  : context.appColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                          hintText: '예: 005930, AAPL, SPY',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: context.appColors.textPrimary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (isMatched)
                      InkWell(
                        onTap: onClearCodeTap,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: context.appColors.textTertiary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 77,
              height: 52,
              child: FilledButton.icon(
                onPressed: isLookupEnabled ? onLookupTap : null,
                icon: Icon(
                  isLookupLoading
                      ? Icons.hourglass_top_rounded
                      : Icons.search_rounded,
                  size: 15,
                ),
                label: Text(
                  isLookupLoading ? '조회중' : '조회',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  backgroundColor: context.appColors.primary,
                  disabledBackgroundColor: context.appColors.primary.withValues(
                    alpha: 0.4,
                  ),
                  foregroundColor: context.appColors.inverseText,
                  disabledForegroundColor: context.appColors.inverseText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorMessage!,
              style: TextStyle(
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w400,
                color: context.appColors.danger,
              ),
            ),
          ),
        ],
        if (result != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 79),
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 16),
            decoration: BoxDecoration(
              color: successBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: successBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            result!.companyName,
                            style: TextStyle(
                              fontSize: 14,
                              height: 20 / 14,
                              fontWeight: FontWeight.w700,
                              color: successColor,
                            ),
                          ),
                          _StockTag(
                            text: result!.code,
                            backgroundColor: successBadgeBackground,
                            textColor: successColor,
                          ),
                          _StockTag(
                            text: result!.market,
                            backgroundColor: primaryBadgeBackground,
                            textColor: context.appColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result!.latestPriceText,
                        style: TextStyle(
                          fontSize: 16,
                          height: 24 / 16,
                          fontWeight: FontWeight.w700,
                          color: successColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 28,
                  child: FilledButton(
                    onPressed: onApplyStockNameTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: successColor,
                      foregroundColor: context.appColors.inverseText,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '종목명 적용',
                      style: TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StockTag extends StatelessWidget {
  const _StockTag({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  final String text;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 19,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          height: 15 / 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _AmountInputField extends StatelessWidget {
  const _AmountInputField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
      decoration: BoxDecoration(
        color: AppColors.hexFFF8FAFC,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hexFFF3F4F6, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
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
    required this.stockName,
    required this.sharesController,
    required this.shares,
    required this.unitPriceText,
    required this.exchangeRate,
    required this.evaluatedAmount,
    required this.onSharesChanged,
  });

  final String? stockName;
  final TextEditingController sharesController;
  final double? shares;
  final String? unitPriceText;
  final int exchangeRate;
  final int evaluatedAmount;
  final ValueChanged<String> onSharesChanged;

  @override
  Widget build(BuildContext context) {
    final hasQuote = stockName != null && unitPriceText != null;
    final summaryBg = context.appColors.primary.withValues(alpha: 0.12);
    final summaryPrimary = context.appColors.primary;
    final summarySecondary = context.appColors.primary.withValues(alpha: 0.55);
    final sharesText = _formatShares(shares);
    final exchangeRateText = _formatWithComma(exchangeRate);
    final evaluatedText = _toKoreanWon(evaluatedAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(text: '종목명'),
        const SizedBox(height: 8),
        Container(
          height: 56,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.appColors.surfaceMuted,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appColors.primary, width: 2),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            stockName ?? '종목 조회 후 자동 입력',
            style: TextStyle(
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w400,
              color: context.appColors.textPrimary.withValues(alpha: 0.55),
            ),
          ),
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
            border: Border.all(color: context.appColors.primary, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: sharesController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: onSharesChanged,
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
                    unitPriceText ?? '-',
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
                    '$exchangeRateText원',
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
                '= ${hasQuote ? evaluatedText : '-'}',
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
          color: AppColors.hexFFF3F4F6,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? AppColors.hexFFEEF2FF : AppColors.hexFFF9FAFB,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.hexFF3B82F6 : AppColors.hexFFF3F4F6,
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
                color: selected ? AppColors.hexFF3B82F6 : AppColors.hexFFE5E7EB,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 18,
                color: selected ? AppColors.white : accentColor,
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
                              ? AppColors.hexFF3B82F6
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
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.iconBackgroundColor,
    required this.selectedBackgroundColor,
  });

  final AssetType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color iconBackgroundColor;
  final Color selectedBackgroundColor;
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
