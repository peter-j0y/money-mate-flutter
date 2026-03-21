import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_record_type_toggle.dart';
import 'package:money_mate/ui/ledger/view_models/add_ledger_record_view_model.dart';

import '../../../data/model/entities/ledger_record.dart';

class AddLedgerRecordScreen extends StatefulWidget {
  const AddLedgerRecordScreen({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  State<AddLedgerRecordScreen> createState() => _AddLedgerRecordScreenState();
}

class _AddLedgerRecordScreenState extends State<AddLedgerRecordScreen> {
  final AddLedgerRecordViewModel _viewModel = AddLedgerRecordViewModel();
  int _selectedTypeIndex = 1;
  int _selectedExpenseCategoryIndex = -1;
  int _selectedIncomeCategoryIndex = -1;
  final FocusNode _amountFocusNode = FocusNode();
  final TextEditingController _amountController = TextEditingController(
    text: '0',
  );
  final TextEditingController _memoController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  static const List<_LedgerCategoryOption> _incomeCategoryOptions = [
    _LedgerCategoryOption(
      label: '월급',
      icon: Icons.payments_outlined,
      backgroundColor: Color(0xFFDCFCE7),
      iconColor: Color(0xFF22C55E),
    ),
    _LedgerCategoryOption(
      label: '부업',
      icon: Icons.work_outline_rounded,
      backgroundColor: Color(0xFFDBEAFE),
      iconColor: Color(0xFF137FEC),
    ),
    _LedgerCategoryOption(
      label: '보너스',
      icon: Icons.card_giftcard_rounded,
      backgroundColor: Color(0xFFFFEDD5),
      iconColor: Color(0xFFF97316),
    ),
    _LedgerCategoryOption(
      label: '용돈',
      icon: Icons.savings_outlined,
      backgroundColor: Color(0xFFFCE7F3),
      iconColor: Color(0xFFEC4899),
    ),
    _LedgerCategoryOption(
      label: '이자/배당',
      icon: Icons.trending_up_rounded,
      backgroundColor: Color(0xFFF3E8FF),
      iconColor: Color(0xFFA855F7),
    ),
    _LedgerCategoryOption(
      label: '기타',
      icon: Icons.more_horiz_rounded,
      backgroundColor: Color(0xFFF1F5F9),
      iconColor: Color(0xFF94A3B8),
    ),
  ];

  static const List<_LedgerCategoryOption> _expenseCategoryOptions = [
    _LedgerCategoryOption(
      label: '식비',
      icon: Icons.restaurant_rounded,
      backgroundColor: Color(0xFFFFEDD5),
      iconColor: Color(0xFFF97316),
    ),
    _LedgerCategoryOption(
      label: '교통',
      icon: Icons.directions_bus_filled_rounded,
      backgroundColor: Color(0xFFDBEAFE),
      iconColor: Color(0xFF137FEC),
    ),
    _LedgerCategoryOption(
      label: '쇼핑',
      icon: Icons.shopping_bag_outlined,
      backgroundColor: Color(0xFFFCE7F3),
      iconColor: Color(0xFFEC4899),
    ),
    _LedgerCategoryOption(
      label: '문화/취미',
      icon: Icons.theaters_outlined,
      backgroundColor: Color(0xFFF3E8FF),
      iconColor: Color(0xFFA855F7),
    ),
    _LedgerCategoryOption(
      label: '주거/통신',
      icon: Icons.home_outlined,
      backgroundColor: Color(0xFFDCFCE7),
      iconColor: Color(0xFF22C55E),
    ),
    _LedgerCategoryOption(
      label: '의료/건강',
      icon: Icons.medical_services_outlined,
      backgroundColor: Color(0xFFCCFBF1),
      iconColor: Color(0xFF14B8A6),
    ),
    _LedgerCategoryOption(
      label: '교육',
      icon: Icons.school_outlined,
      backgroundColor: Color(0xFFFEF9C3),
      iconColor: Color(0xFFD97706),
    ),
    _LedgerCategoryOption(
      label: '기타',
      icon: Icons.more_horiz_rounded,
      backgroundColor: Color(0xFFF1F5F9),
      iconColor: Color(0xFF94A3B8),
    ),
  ];

  List<_LedgerCategoryOption> get _categoryOptions {
    return _selectedTypeIndex == 0
        ? _incomeCategoryOptions
        : _expenseCategoryOptions;
  }

  int get _selectedCategoryIndex {
    return _selectedTypeIndex == 0
        ? _selectedIncomeCategoryIndex
        : _selectedExpenseCategoryIndex;
  }

  void _onCategoryTap(int index) {
    setState(() {
      if (_selectedTypeIndex == 0) {
        _selectedIncomeCategoryIndex = index;
      } else {
        _selectedExpenseCategoryIndex = index;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _amountFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _amountFocusNode.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  int get _amountValue {
    final digits = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  Future<void> _saveRecord() async {
    if (_selectedCategoryIndex < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('카테고리를 선택해 주세요.')));
      return;
    }

    final selectedCategory = _categoryOptions[_selectedCategoryIndex].label;
    final isSuccess = await _viewModel.saveRecord(
      type:
          _selectedTypeIndex == 0
              ? LedgerRecordType.income
              : LedgerRecordType.expense,
      category: selectedCategory,
      amount: _amountValue,
      date: _selectedDate,
      memo:
          _memoController.text.trim().isEmpty
              ? null
              : _memoController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (isSuccess) {
      Navigator.pop(context, true);
      return;
    }

    final message = _viewModel.errorMessage ?? '저장에 실패했습니다.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 24,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      '내역 추가',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        height: 22.5 / 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48, height: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel(text: '날짜'),
                    const SizedBox(height: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: _pickDate,
                      child: Ink(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _koreanDateText(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 24 / 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 20,
                              color: Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _SectionLabel(text: '금액'),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            focusNode: _amountFocusNode,
                            keyboardType: TextInputType.number,
                            inputFormatters: const [_AmountInputFormatter()],
                            style: const TextStyle(
                              fontSize: 36,
                              height: 36 / 30,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                            decoration: const InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(bottom: 6),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            '원',
                            style: TextStyle(
                              fontSize: 20,
                              height: 28 / 20,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      height: 2,
                      thickness: 2,
                      color: Color(0xFFF1F5F9),
                    ),
                    const SizedBox(height: 24),
                    const _SectionLabel(text: '유형'),
                    const SizedBox(height: 8),
                    LedgerRecordTypeToggle(
                      selectedIndex: _selectedTypeIndex,
                      onChanged:
                          (index) => setState(() => _selectedTypeIndex = index),
                    ),
                    const SizedBox(height: 24),
                    const _SectionLabel(text: '카테고리'),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _categoryOptions.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            mainAxisExtent: 92,
                          ),
                      itemBuilder: (context, index) {
                        final option = _categoryOptions[index];
                        final selected = _selectedCategoryIndex == index;
                        return _CategoryItem(
                          option: option,
                          selected: selected,
                          onTap: () => _onCategoryTap(index),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const _SectionLabel(text: '메모'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(5),
                      child: TextField(
                        controller: _memoController,
                        maxLines: 4,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 24 / 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          hintText: '내용을 입력해주세요 (예: 퇴근길 버스비)',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            height: 24 / 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF94A3B8),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _viewModel,
              builder: (context, child) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(255, 255, 255, 0),
                        Color.fromRGBO(255, 255, 255, 0.9),
                        Colors.white,
                      ],
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(16, 16, 16, safeAreaBottom + 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF137FEC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                        shadowColor: const Color.fromRGBO(19, 127, 236, 0.25),
                      ),
                      onPressed: _viewModel.isSaving ? null : _saveRecord,
                      child:
                          _viewModel.isSaving
                              ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                '저장하기',
                                style: TextStyle(
                                  fontSize: 18,
                                  height: 28 / 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _koreanDateText(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${date.year}년 ${date.month}월 ${date.day}일 (${weekdays[date.weekday - 1]})';
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF64748B),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _LedgerCategoryOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: option.backgroundColor,
              shape: BoxShape.circle,
              border:
                  selected
                      ? Border.all(color: const Color(0xFF137FEC), width: 2)
                      : null,
            ),
            alignment: Alignment.center,
            child: Icon(option.icon, size: 22, color: option.iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            option.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w500,
              color:
                  selected ? const Color(0xFF137FEC) : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerCategoryOption {
  const _LedgerCategoryOption({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
}

class _AmountInputFormatter extends TextInputFormatter {
  const _AmountInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '0',
        selection: TextSelection.collapsed(offset: 1),
      );
    }

    final trimmedLeadingZero = digitsOnly.replaceFirst(RegExp(r'^0+'), '');
    final normalizedDigits =
        trimmedLeadingZero.isEmpty ? '0' : trimmedLeadingZero;
    final formatted = _formatWithComma(normalizedDigits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }

  String _formatWithComma(String digits) {
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }
}
