import 'package:flutter/material.dart';
import 'package:money_mate/data/model/entities/currency.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/currency/current_currency.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_category_grid.dart';
import 'package:money_mate/ui/ledger/widgets/expense_payment_method_selector.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_category_options.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_date_amount_fields.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_memo_section.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_record_type_toggle.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_screen_header.dart';
import 'package:money_mate/ui/ledger/widgets/favorite_ledger_records_screen.dart';
import 'package:money_mate/ui/ledger/view_models/add_ledger_record_view_model.dart';

import '../../../data/model/entities/favorite_ledger_record.dart';
import '../../../data/model/entities/ledger_record.dart';

class AddLedgerRecordScreen extends StatefulWidget {
  const AddLedgerRecordScreen({
    super.key,
    this.initialDate,
    this.initialType = LedgerRecordType.expense,
    this.initialCategory,
    this.initialAmount,
    this.initialCurrencyCode,
    this.initialPaymentMethod,
    this.initialMemo,
  });

  final DateTime? initialDate;
  final LedgerRecordType initialType;
  final String? initialCategory;
  final int? initialAmount;
  // 즐겨찾기에서 바로 이동해 초기값을 채우는 경우, 즐겨찾기가 저장될 당시의
  // 통화를 그대로 유지하기 위해 사용한다. 없으면 현재 주 통화를 사용한다.
  final String? initialCurrencyCode;
  final ExpensePaymentMethod? initialPaymentMethod;
  final String? initialMemo;

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
  late CurrencyCode _activeCurrency;

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
    _activeCurrency =
        widget.initialCurrencyCode != null
            ? CurrencyCode.fromCode(widget.initialCurrencyCode)
            : CurrentCurrency.code;
    _selectedTypeIndex = widget.initialType == LedgerRecordType.income ? 0 : 1;
    _selectedDate = widget.initialDate ?? DateTime.now();
    final initialCategory = widget.initialCategory;
    if (initialCategory != null) {
      final categoryIndex = _categoryOptions.indexWhere(
        (option) => option.code == initialCategory,
      );
      if (_selectedTypeIndex == 0) {
        _selectedIncomeCategoryIndex = categoryIndex;
      } else {
        _selectedExpenseCategoryIndex = categoryIndex;
      }
    }
    final initialAmount = widget.initialAmount;
    if (initialAmount != null && initialAmount > 0) {
      _amountController.text = CurrencyAmountInputFormatter.formatMinorUnits(
        initialAmount,
        _activeCurrency,
      );
    }
    _selectedExpensePaymentMethod = widget.initialPaymentMethod;
    if (widget.initialMemo != null) {
      _memoController.text = widget.initialMemo!;
    }
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
    return CurrencyAmountInputFormatter.parseToMinorUnits(
      _amountController.text,
      _activeCurrency,
    );
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

  String? _validationMessage(AppLocalizations l10n) {
    if (!_isDateSelected) {
      return l10n.errorDateRequired;
    }
    if (_amountValue <= 0) {
      return l10n.errorAmountMustBePositive;
    }
    if (!_isTypeSelected) {
      return l10n.errorTypeRequired;
    }
    if (_selectedCategoryIndex < 0) {
      return l10n.errorCategoryRequired;
    }
    if (_selectedTypeIndex == 1 && _selectedExpensePaymentMethod == null) {
      return l10n.errorPaymentMethodRequired;
    }
    return null;
  }

  void _showValidationToast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onSubmitTap() async {
    final validationMessage = _validationMessage(AppLocalizations.of(context)!);
    if (validationMessage != null) {
      _showValidationToast(validationMessage);
      return;
    }
    await _saveRecord();
  }

  Future<void> _saveRecord() async {
    final l10n = AppLocalizations.of(context)!;
    final validationMessage = _validationMessage(l10n);
    if (validationMessage != null) {
      _showValidationToast(validationMessage);
      return;
    }

    final selectedCategory = _categoryOptions[_selectedCategoryIndex].code;
    final isExpense = _selectedTypeIndex == 1;
    final selectedPaymentMethod =
        isExpense ? _selectedExpensePaymentMethod : null;
    final isSuccess = await _viewModel.saveRecord(
      type: isExpense ? LedgerRecordType.expense : LedgerRecordType.income,
      category: selectedCategory,
      amount: _amountValue,
      currencyCode: _activeCurrency.isoCode,
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

    final message = _viewModel.errorMessage(l10n) ?? l10n.errorSaveFailed;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openFavoriteRecordsScreen() async {
    final selectedFavorite = await Navigator.of(
      context,
    ).push<FavoriteLedgerEntry>(
      MaterialPageRoute<FavoriteLedgerEntry>(
        builder:
            (context) => const FavoriteLedgerRecordsScreen(isSelectMode: true),
      ),
    );

    if (selectedFavorite == null || !mounted) {
      return;
    }

    _applyFavorite(selectedFavorite);
  }

  void _applyFavorite(FavoriteLedgerEntry favorite) {
    setState(() {
      // 즐겨찾기는 과거 기록 기반이라 저장 당시의 통화를 그대로 따른다.
      // (현재 주 통화가 바뀌었더라도 즐겨찾기 금액이 재해석되면 안 된다)
      _activeCurrency = CurrencyCode.fromCode(favorite.currencyCode);
      _selectedTypeIndex = favorite.type == LedgerRecordType.income ? 0 : 1;
      final categoryIndex = _categoryOptions.indexWhere(
        (option) => option.code == favorite.category,
      );
      if (_selectedTypeIndex == 0) {
        _selectedIncomeCategoryIndex = categoryIndex;
      } else {
        _selectedExpenseCategoryIndex = categoryIndex;
      }
      _selectedExpensePaymentMethod = favorite.paymentMethod;
      _memoController.text = favorite.memo ?? '';
    });
    _amountController.text = CurrencyAmountInputFormatter.formatMinorUnits(
      favorite.amount,
      _activeCurrency,
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: Localizations.localeOf(context),
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    final contentBottomPadding = safeAreaBottom + 120;
    final isSubmitEnabledUi = _isFormValid;

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.zero,
              child: LedgerScreenHeader(
                title: l10n.addRecordTitle,
                onCloseTap: () => Navigator.pop(context),
                closeButtonSize: 40,
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                trailing: IconButton(
                  onPressed: _openFavoriteRecordsScreen,
                  icon: Icon(
                    Icons.bookmark_border_rounded,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      contentBottomPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel(text: l10n.fieldDate),
                        const SizedBox(height: 8),
                        LedgerDateCard(
                          date: _selectedDate,
                          dateTextBuilder: (date) => _dateText(date, l10n),
                          onTap: _pickDate,
                        ),
                        const SizedBox(height: 24),
                        _SectionLabel(text: l10n.fieldAmount),
                        const SizedBox(height: 8),
                        LedgerAmountField.editable(
                          controller: _amountController,
                          focusNode: _amountFocusNode,
                          currency: _activeCurrency,
                          inputFormatters: [
                            CurrencyAmountInputFormatter(
                              currency: _activeCurrency,
                            ),
                          ],
                        ),
                        Divider(
                          height: 2,
                          thickness: 2,
                          color: context.appColors.surfaceMuted,
                        ),
                        const SizedBox(height: 24),
                        _SectionLabel(text: l10n.fieldType),
                        const SizedBox(height: 8),
                        LedgerRecordTypeToggle(
                          selectedIndex: _selectedTypeIndex,
                          onChanged:
                              (index) =>
                                  setState(() => _selectedTypeIndex = index),
                        ),
                        const SizedBox(height: 24),
                        _SectionLabel(text: l10n.fieldCategory),
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
                        _SectionLabel(text: l10n.fieldMemo),
                        const SizedBox(height: 8),
                        LedgerMemoSection.editable(controller: _memoController),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedBuilder(
                      animation: _viewModel,
                      builder: (context, child) {
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
                                        context.appColors.background.withValues(
                                          alpha: 0,
                                        ),
                                        context.appColors.background.withValues(
                                          alpha: 0.65,
                                        ),
                                        context.appColors.background,
                                      ],
                                      stops: [0, 0.6, 1],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                color: context.appColors.background,
                                padding: EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  safeAreaBottom + 8,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 60,
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          isSubmitEnabledUi
                                              ? context.appColors.primary
                                              : context.appColors.border,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      elevation: 0,
                                      shadowColor:
                                          isSubmitEnabledUi
                                              ? AppColors.rgba_19_127_236_025
                                              : context.appColors.overlay,
                                    ),
                                    onPressed:
                                        _viewModel.isSaving
                                            ? null
                                            : _onSubmitTap,
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
                                            : Text(
                                              l10n.actionAdd,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                height: 28 / 18,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.white,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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

  String _dateText(DateTime date, AppLocalizations l10n) {
    final weekdays = weekdayShortLabels(l10n);
    return l10n.dateWithWeekday(
      date.year,
      date.month,
      date.day,
      weekdays[date.weekday - 1],
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
