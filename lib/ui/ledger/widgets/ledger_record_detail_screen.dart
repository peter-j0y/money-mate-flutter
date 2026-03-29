import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/data/repositories/ledger_record_repository.dart';
import 'package:money_mate/data/repositories/ledger_record_repository_impl.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_category_grid.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_category_options.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_date_amount_fields.dart';
import 'package:money_mate/ui/ledger/widgets/expense_payment_method_selector.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_memo_section.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_record_type_toggle.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_screen_header.dart';

class LedgerRecordDetailScreen extends StatefulWidget {
  const LedgerRecordDetailScreen({
    super.key,
    required this.entry,
    this.onEdit,
    this.onDelete,
  });

  final LedgerEntry entry;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  State<LedgerRecordDetailScreen> createState() =>
      _LedgerRecordDetailScreenState();
}

class _LedgerRecordDetailScreenState extends State<LedgerRecordDetailScreen> {
  final LedgerRecordRepository _repository = LedgerRecordRepositoryImpl();

  static const List<ExpensePaymentMethod> _expensePaymentMethods = [
    ExpensePaymentMethod.cash,
    ExpensePaymentMethod.creditCard,
    ExpensePaymentMethod.debitCard,
    ExpensePaymentMethod.bankTransfer,
    ExpensePaymentMethod.points,
    ExpensePaymentMethod.other,
  ];

  late int _selectedTypeIndex;
  late int _selectedCategoryIndex;
  late ExpensePaymentMethod _selectedExpensePaymentMethod;
  late DateTime _selectedDate;
  late FocusNode _amountFocusNode;
  late TextEditingController _amountController;
  late TextEditingController _memoController;
  bool _hasTappedAnyItem = false;
  bool _isUpdating = false;

  bool get _isMemoInitiallyEmpty {
    final initialMemo = widget.entry.memo?.trim();
    return initialMemo == null || initialMemo.isEmpty;
  }

  List<LedgerCategoryOption> get _categoryOptions {
    return _selectedTypeIndex == 0
        ? ledgerIncomeCategoryOptions
        : ledgerExpenseCategoryOptions;
  }

  @override
  void initState() {
    super.initState();
    _selectedTypeIndex = widget.entry.type == LedgerRecordType.income ? 0 : 1;
    _selectedCategoryIndex = _findInitialCategoryIndex(_selectedTypeIndex);
    _selectedExpensePaymentMethod =
        widget.entry.paymentMethod ?? ExpensePaymentMethod.creditCard;
    _selectedDate = widget.entry.date;
    _amountFocusNode = FocusNode();
    _amountController = TextEditingController(
      text: _formatWon(widget.entry.amount).replaceAll('원', ''),
    );
    _memoController = TextEditingController(text: widget.entry.memo ?? '');
  }

  @override
  void dispose() {
    _amountFocusNode.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  String _koreanDateText(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${date.year}년 ${date.month}월 ${date.day}일 (${weekdays[date.weekday - 1]})';
  }

  String _formatWon(int amount) {
    final reversed = amount.toString().split('').reversed.toList();
    final buffer = StringBuffer();
    for (var i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(reversed[i]);
    }
    return '${buffer.toString().split('').reversed.join()}원';
  }

  int _findInitialCategoryIndex(int typeIndex) {
    final options =
        typeIndex == 0
            ? ledgerIncomeCategoryOptions
            : ledgerExpenseCategoryOptions;
    final index = options.indexWhere(
      (option) => option.label == widget.entry.category,
    );
    return index >= 0 ? index : 0;
  }

  void _markTapped() {
    if (_hasTappedAnyItem) {
      return;
    }
    setState(() => _hasTappedAnyItem = true);
  }

  Future<void> _pickDate() async {
    _markTapped();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() => _selectedDate = pickedDate);
  }

  void _onTypeChanged(int nextTypeIndex) {
    final previousOptions = _categoryOptions;
    final previousLabel =
        _selectedCategoryIndex >= 0 &&
                _selectedCategoryIndex < previousOptions.length
            ? previousOptions[_selectedCategoryIndex].label
            : null;
    final nextOptions =
        nextTypeIndex == 0
            ? ledgerIncomeCategoryOptions
            : ledgerExpenseCategoryOptions;
    final mappedIndex =
        previousLabel == null
            ? -1
            : nextOptions.indexWhere((option) => option.label == previousLabel);

    setState(() {
      _selectedTypeIndex = nextTypeIndex;
      _selectedCategoryIndex = mappedIndex >= 0 ? mappedIndex : 0;
      _hasTappedAnyItem = true;
    });
  }

  int get _amountValue {
    final digits = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  Future<void> _onSaveTap() async {
    final recordId = widget.entry.id;
    if (recordId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('수정할 항목 ID가 없습니다.')));
      return;
    }

    if (_selectedCategoryIndex < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('카테고리를 선택해 주세요.')));
      return;
    }

    if (_amountValue <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('금액은 0원보다 커야 합니다.')));
      return;
    }

    setState(() => _isUpdating = true);

    final isExpense = _selectedTypeIndex == 1;
    final draft = LedgerEntryDraft(
      type: isExpense ? LedgerRecordType.expense : LedgerRecordType.income,
      category: _categoryOptions[_selectedCategoryIndex].label,
      amount: _amountValue,
      date: _selectedDate,
      paymentMethod: isExpense ? _selectedExpensePaymentMethod : null,
      memo:
          _memoController.text.trim().isEmpty
              ? null
              : _memoController.text.trim(),
    );

    try {
      final replaced = await _repository.replaceRecord(recordId, draft);
      if (!mounted) {
        return;
      }

      if (!replaced) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('수정할 항목을 찾지 못했어요.')));
        setState(() => _isUpdating = false);
        return;
      }

      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('수정 중 오류가 발생했습니다.')));
      setState(() => _isUpdating = false);
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
            LedgerScreenHeader(
              title: '기록 상세',
              onCloseTap: () => Navigator.pop(context),
              actions: [
                LedgerScreenHeaderAction(
                  label: '삭제',
                  color: const Color(0xFFF43F5E),
                  onTap: () {
                    if (widget.onDelete != null) {
                      widget.onDelete!();
                      return;
                    }
                    _showNotReadySnackBar(context, '삭제');
                  },
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
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
                      onTap: _markTapped,
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
                      onChanged: _onTypeChanged,
                    ),
                    const SizedBox(height: 24),
                    const _SectionLabel(text: '카테고리'),
                    const SizedBox(height: 8),
                    LedgerCategoryGrid(
                      options: _categoryOptions,
                      selectedIndex: _selectedCategoryIndex,
                      onCategoryTap: (index) {
                        setState(() {
                          _selectedCategoryIndex = index;
                          _hasTappedAnyItem = true;
                        });
                      },
                    ),
                    if (_selectedTypeIndex == 1) ...[
                      const SizedBox(height: 24),
                      ExpensePaymentMethodSelector(
                        options: _expensePaymentMethods,
                        selectedMethod: _selectedExpensePaymentMethod,
                        onChanged: (method) {
                          setState(() {
                            _selectedExpensePaymentMethod = method;
                            _hasTappedAnyItem = true;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    const _SectionLabel(text: '메모'),
                    const SizedBox(height: 8),
                    LedgerMemoSection.editable(
                      controller: _memoController,
                      onTap: _markTapped,
                      placeholder:
                          _isMemoInitiallyEmpty
                              ? '기존 메모가 없어요. 내용을 추가해 주세요.'
                              : null,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child:
                  _hasTappedAnyItem
                      ? Container(
                        key: const ValueKey('save-button'),
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
                        padding: EdgeInsets.fromLTRB(
                          16,
                          16,
                          16,
                          safeAreaBottom + 8,
                        ),
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
                              shadowColor: const Color.fromRGBO(
                                19,
                                127,
                                236,
                                0.25,
                              ),
                            ),
                            onPressed: _isUpdating ? null : _onSaveTap,
                            child:
                                _isUpdating
                                    ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text(
                                      '수정하기',
                                      style: TextStyle(
                                        fontSize: 18,
                                        height: 28 / 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                      )
                      : Container(
                        key: const ValueKey('empty-bottom'),
                        height: safeAreaBottom + 8,
                        color: Colors.white,
                      ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotReadySnackBar(BuildContext context, String action) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$action 기능은 준비 중이에요.')));
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
