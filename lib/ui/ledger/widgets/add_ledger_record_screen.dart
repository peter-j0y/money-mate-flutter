import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:flutter/services.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_category_grid.dart';
import 'package:money_mate/ui/ledger/widgets/expense_payment_method_selector.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_category_options.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_date_amount_fields.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_memo_section.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_record_type_toggle.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_screen_header.dart';
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
  ExpensePaymentMethod? _selectedExpensePaymentMethod;
  final FocusNode _amountFocusNode = FocusNode();
  final TextEditingController _amountController = TextEditingController(
    text: '0',
  );
  final TextEditingController _memoController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  static const List<ExpensePaymentMethod> _expensePaymentMethods = [
    ExpensePaymentMethod.cash,
    ExpensePaymentMethod.creditCard,
    ExpensePaymentMethod.debitCard,
    ExpensePaymentMethod.bankTransfer,
    ExpensePaymentMethod.points,
    ExpensePaymentMethod.other,
  ];

  List<LedgerCategoryOption> get _categoryOptions {
    return _selectedTypeIndex == 0
        ? ledgerIncomeCategoryOptions
        : ledgerExpenseCategoryOptions;
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
    _amountController.addListener(_onAmountChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _amountFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _viewModel.dispose();
    _amountFocusNode.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  int get _amountValue {
    final digits = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  bool get _isTypeSelected {
    return _selectedTypeIndex == 0 || _selectedTypeIndex == 1;
  }

  bool get _isDateSelected => true;

  bool get _isFormValid {
    return _isDateSelected &&
        _amountValue > 0 &&
        _isTypeSelected &&
        _selectedCategoryIndex >= 0 &&
        (_selectedTypeIndex != 1 || _selectedExpensePaymentMethod != null);
  }

  String? get _validationMessage {
    if (!_isDateSelected) {
      return '날짜를 선택해 주세요.';
    }
    if (_amountValue <= 0) {
      return '금액은 0원보다 커야 합니다.';
    }
    if (!_isTypeSelected) {
      return '유형을 선택해 주세요.';
    }
    if (_selectedCategoryIndex < 0) {
      return '카테고리를 선택해 주세요.';
    }
    if (_selectedTypeIndex == 1 && _selectedExpensePaymentMethod == null) {
      return '지출 수단을 선택해 주세요.';
    }
    return null;
  }

  void _showValidationToast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onSubmitTap() async {
    final validationMessage = _validationMessage;
    if (validationMessage != null) {
      _showValidationToast(validationMessage);
      return;
    }
    await _saveRecord();
  }

  Future<void> _saveRecord() async {
    final validationMessage = _validationMessage;
    if (validationMessage != null) {
      _showValidationToast(validationMessage);
      return;
    }

    final selectedCategory = _categoryOptions[_selectedCategoryIndex].label;
    final isExpense = _selectedTypeIndex == 1;
    final selectedPaymentMethod =
        isExpense ? _selectedExpensePaymentMethod : null;
    final isSuccess = await _viewModel.saveRecord(
      type: isExpense ? LedgerRecordType.expense : LedgerRecordType.income,
      category: selectedCategory,
      amount: _amountValue,
      date: _selectedDate,
      paymentMethod: selectedPaymentMethod,
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
    final isSubmitEnabledUi = _isFormValid;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.zero,
              child: LedgerScreenHeader(
                title: '기록 추가',
                onCloseTap: () => Navigator.pop(context),
                closeButtonSize: 40,
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
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
                    LedgerDateCard(
                      date: _selectedDate,
                      dateTextBuilder: _koreanDateText,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 24),
                    const _SectionLabel(text: '금액'),
                    const SizedBox(height: 8),
                    LedgerAmountField.editable(
                      controller: _amountController,
                      focusNode: _amountFocusNode,
                      inputFormatters: const [_AmountInputFormatter()],
                    ),
                    const Divider(
                      height: 2,
                      thickness: 2,
                      color: AppColors.surfaceMuted,
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
                    LedgerCategoryGrid(
                      options: _categoryOptions,
                      selectedIndex: _selectedCategoryIndex,
                      onCategoryTap: _onCategoryTap,
                    ),
                    if (_selectedTypeIndex == 1) ...[
                      const SizedBox(height: 24),
                      ExpensePaymentMethodSelector(
                        options: _expensePaymentMethods,
                        selectedMethod: _selectedExpensePaymentMethod,
                        onChanged:
                            (method) => setState(
                              () => _selectedExpensePaymentMethod = method,
                            ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const _SectionLabel(text: '메모'),
                    const SizedBox(height: 8),
                    LedgerMemoSection.editable(controller: _memoController),
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
                        AppColors.rgba_255_255_255_0,
                        AppColors.rgba_255_255_255_09,
                        AppColors.white,
                      ],
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(16, 16, 16, safeAreaBottom + 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            isSubmitEnabledUi
                                ? AppColors.primary
                                : AppColors.hexFFCBD5E1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                        shadowColor:
                            isSubmitEnabledUi
                                ? AppColors.rgba_19_127_236_025
                                : AppColors.overlay,
                      ),
                      onPressed: _viewModel.isSaving ? null : _onSubmitTap,
                      child:
                          _viewModel.isSaving
                              ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: AppColors.white,
                                ),
                              )
                              : const Text(
                                '추가하기',
                                style: TextStyle(
                                  fontSize: 18,
                                  height: 28 / 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white,
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
        color: AppColors.textSecondary,
      ),
    );
  }
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
