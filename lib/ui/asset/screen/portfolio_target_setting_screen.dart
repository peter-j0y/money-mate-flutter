import 'package:flutter/material.dart';
import 'package:money_mate/ui/asset/view_models/assets_tab_view_model.dart';
import 'package:money_mate/ui/asset/view_models/portfolio_target_setting_view_model.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class PortfolioTargetSettingScreen extends StatefulWidget {
  const PortfolioTargetSettingScreen({super.key});

  @override
  State<PortfolioTargetSettingScreen> createState() =>
      _PortfolioTargetSettingScreenState();
}

class _PortfolioTargetSettingScreenState
    extends State<PortfolioTargetSettingScreen> {
  late final PortfolioTargetSettingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PortfolioTargetSettingViewModel();
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_viewModel.isBalanced) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('목표 합계를 100%로 맞춰주세요.')),
      );
      return;
    }

    final success = await _viewModel.save();
    if (!mounted) return;

    final message = success ? '포트폴리오 목표 비율을 저장했습니다.' : '저장에 실패했습니다.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final bottomPadding = safeAreaBottom + 60 + 28 + 16;

    if (_viewModel.isLoading) {
      return Scaffold(
        backgroundColor: context.appColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final items = _viewModel.items;

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(onBackTap: () => Navigator.of(context).pop()),
            _SummarySection(
              items: items,
              includedTotal: _viewModel.includedTotal,
              onEqualTap: _viewModel.applyEqualDistribution,
            ),
            Expanded(
              child: Stack(
                children: [
                  ListView.separated(
                    padding: EdgeInsets.fromLTRB(16, 14, 16, bottomPadding),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _TargetSettingCard(
                        item: item,
                        onToggle: (value) =>
                            _viewModel.toggleEnabled(item.type, value),
                        onDecrease: item.isEnabled
                            ? () => _viewModel.updateTargetRatio(
                                  item.type,
                                  item.targetRatio - 1,
                                )
                            : null,
                        onIncrease: item.isEnabled
                            ? () => _viewModel.updateTargetRatio(
                                  item.type,
                                  item.targetRatio + 1,
                                )
                            : null,
                        onSliderChanged: item.isEnabled
                            ? (value) => _viewModel.updateTargetRatio(
                                  item.type,
                                  value.round(),
                                )
                            : null,
                        onValueChanged: item.isEnabled
                            ? (value) => _viewModel.updateTargetRatio(
                                  item.type,
                                  value,
                                )
                            : null,
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: items.length,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _BottomButtonBar(
                      isBalanced: _viewModel.isBalanced,
                      isSaving: _viewModel.isSaving,
                      onPressed: _onSave,
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBackTap});

  final VoidCallback onBackTap;

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
                width: 48,
                height: 48,
                child: IconButton(
                  onPressed: onBackTap,
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    size: 28,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                '포트폴리오 설정',
                style: TextStyle(
                  fontSize: 18,
                  height: 24 / 18,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({
    required this.items,
    required this.includedTotal,
    required this.onEqualTap,
  });

  final List<TargetItemState> items;
  final int includedTotal;
  final VoidCallback onEqualTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBalanced = includedTotal == 100;
    final guideColor =
        isBalanced ? context.appColors.success : context.appColors.danger;
    final totalProgress = (includedTotal / 100).clamp(0, 1).toDouble();
    final includedItems = items
        .where((item) => item.isEnabled)
        .toList(growable: false);

    return Container(
      color: context.appColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
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
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$includedTotal',
                      style: TextStyle(
                        fontSize: 28,
                        height: 34 / 28,
                        fontWeight: FontWeight.w700,
                        color: guideColor,
                      ),
                    ),
                    TextSpan(
                      text: ' / 100%',
                      style: TextStyle(
                        fontSize: 16,
                        height: 22 / 16,
                        fontWeight: FontWeight.w400,
                        color: context.appColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isBalanced) ...[
                const SizedBox(width: 10),
                Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: guideColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 12,
                        color: guideColor,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '조정 필요',
                        style: TextStyle(
                          fontSize: 11,
                          height: 15 / 11,
                          fontWeight: FontWeight.w600,
                          color: guideColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              SizedBox(
                height: 36,
                child: FilledButton.icon(
                  onPressed: onEqualTap,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    backgroundColor: context.appColors.primary,
                    foregroundColor: context.appColors.inverseText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 14),
                  label: const Text(
                    '균등 배분',
                    style: TextStyle(
                      fontSize: 13,
                      height: 18 / 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: totalProgress,
              backgroundColor: context.appColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(guideColor),
            ),
          ),
          const SizedBox(height: 6),
          if (includedItems.isNotEmpty)
            SizedBox(
              height: 6,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Row(
                  children: includedItems
                      .map(
                        (item) => Expanded(
                          flex: item.targetRatio.clamp(1, 100),
                          child: Container(
                            color: assetTypeMeta[item.type]!.accentColor,
                          ),
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
    required this.onValueChanged,
  });

  final TargetItemState item;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final ValueChanged<double>? onSliderChanged;
  final ValueChanged<int>? onValueChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meta = assetTypeMeta[item.type]!;
    final isEnabled = item.isEnabled;
    final ratioDiff = (item.targetRatio - item.actualRatio).toStringAsFixed(1);
    final isOverTarget = item.targetRatio >= item.actualRatio;
    final diffColor =
        isOverTarget ? context.appColors.danger : context.appColors.success;
    final diffPrefix = isOverTarget ? '▲' : '▼';
    final displayOpacity = isEnabled ? 1.0 : 0.58;
    final accentColor = meta.accentColor;
    final iconBgColor = accentColor.withValues(alpha: isDark ? 0.2 : 0.1);

    return Opacity(
      opacity: displayOpacity,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appColors.border),
          boxShadow: [
            BoxShadow(
              color: context.appColors.textPrimary.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header row: Icon + Name + Switch
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(meta.icon, size: 20, color: accentColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meta.label,
                        style: TextStyle(
                          fontSize: 15,
                          height: 20 / 15,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      if (!isEnabled) ...[
                        const SizedBox(height: 2),
                        Text(
                          '포트폴리오 제외',
                          style: TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            fontWeight: FontWeight.w400,
                            color: context.appColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Switch(
                  value: isEnabled,
                  onChanged: onToggle,
                  activeColor: context.appColors.inverseText,
                  activeTrackColor: accentColor,
                  inactiveThumbColor: context.appColors.inverseText,
                  inactiveTrackColor: context.appColors.border,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            // Expanded content when enabled
            if (isEnabled) ...[
              const SizedBox(height: 16),
              // Ratio info row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '실제 ${item.actualRatio.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w500,
                        color: accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$diffPrefix${ratioDiff.replaceFirst('-', '')}%p',
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w500,
                      color: diffColor,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _RatioStepper(
                        value: item.targetRatio,
                        color: accentColor,
                        onDecrease: onDecrease,
                        onIncrease: onIncrease,
                        onValueChanged: onValueChanged,
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
              const SizedBox(height: 12),
              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 8,
                  inactiveTrackColor: context.appColors.surfaceMuted,
                  activeTrackColor: accentColor,
                  thumbColor: accentColor,
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
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Text(
                      '0%',
                      style: TextStyle(
                        fontSize: 10,
                        height: 15 / 10,
                        color: context.appColors.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '100%',
                      style: TextStyle(
                        fontSize: 10,
                        height: 15 / 10,
                        color: context.appColors.textTertiary,
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

class _RatioStepper extends StatefulWidget {
  const _RatioStepper({
    required this.value,
    required this.color,
    required this.onDecrease,
    required this.onIncrease,
    required this.onValueChanged,
  });

  final int value;
  final Color color;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final ValueChanged<int>? onValueChanged;

  @override
  State<_RatioStepper> createState() => _RatioStepperState();
}

class _RatioStepperState extends State<_RatioStepper> {
  bool _isEditing = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _RatioStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing && oldWidget.value != widget.value) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _submitValue();
    }
  }

  void _startEditing() {
    if (widget.onValueChanged == null) return;
    setState(() {
      _isEditing = true;
      _controller.text = '${widget.value}';
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  void _submitValue() {
    final parsed = int.tryParse(_controller.text);
    if (parsed != null) {
      widget.onValueChanged?.call(parsed.clamp(0, 100));
    }
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.color, width: 2),
      ),
      child: Row(
        children: [
          _StepButton(symbol: '−', onTap: widget.onDecrease),
          Expanded(
            child: _isEditing
                ? TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w700,
                      color: widget.color,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onSubmitted: (_) => _submitValue(),
                  )
                : GestureDetector(
                    onTap: _startEditing,
                    child: Center(
                      child: Text(
                        '${widget.value}',
                        style: TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight: FontWeight.w700,
                          color: widget.color,
                        ),
                      ),
                    ),
                  ),
          ),
          _StepButton(symbol: '+', onTap: widget.onIncrease),
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

class _BottomButtonBar extends StatelessWidget {
  const _BottomButtonBar({
    required this.isBalanced,
    required this.isSaving,
    required this.onPressed,
  });

  final bool isBalanced;
  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    return Column(
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
          padding: EdgeInsets.fromLTRB(20, 0, 20, safeAreaBottom + 16),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: FilledButton(
              onPressed: (isSaving || !isBalanced) ? null : onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: context.appColors.primary,
                foregroundColor: context.appColors.inverseText,
                disabledBackgroundColor: context.appColors.primary.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: isSaving
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: context.appColors.inverseText,
                      ),
                    )
                  : const Text(
                      '포트폴리오 설정 저장',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
