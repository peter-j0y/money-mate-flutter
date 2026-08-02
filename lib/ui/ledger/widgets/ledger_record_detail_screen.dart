import 'package:flutter/material.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/data/model/entities/currency.dart';
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
  bool _isDeleting = false;

  bool get _isMemoInitiallyEmpty {
    final initialMemo = widget.entry.memo?.trim();
    return initialMemo == null || initialMemo.isEmpty;
  }

  /// 수정 시에는 기록 원래의 통화를 그대로 유지한다.
  CurrencyCode get _entryCurrency =>
      CurrencyCode.fromCode(widget.entry.currencyCode);

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
      text: CurrencyAmountInputFormatter.formatMinorUnits(
        widget.entry.amount,
        _entryCurrency,
      ),
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

  String _dateText(DateTime date, AppLocalizations l10n) {
    final weekdays = weekdayShortLabels(l10n);
    return l10n.dateWithWeekday(
      date.year,
      date.month,
      date.day,
      weekdays[date.weekday - 1],
    );
  }

  int _findInitialCategoryIndex(int typeIndex) {
    final options =
        typeIndex == 0
            ? ledgerIncomeCategoryOptions
            : ledgerExpenseCategoryOptions;
    final index = options.indexWhere(
      (option) => option.code == widget.entry.category,
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
      locale: Localizations.localeOf(context),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() => _selectedDate = pickedDate);
  }

  void _onTypeChanged(int nextTypeIndex) {
    final previousOptions = _categoryOptions;
    final previousCode =
        _selectedCategoryIndex >= 0 &&
                _selectedCategoryIndex < previousOptions.length
            ? previousOptions[_selectedCategoryIndex].code
            : null;
    final nextOptions =
        nextTypeIndex == 0
            ? ledgerIncomeCategoryOptions
            : ledgerExpenseCategoryOptions;
    final mappedIndex =
        previousCode == null
            ? -1
            : nextOptions.indexWhere((option) => option.code == previousCode);

    setState(() {
      _selectedTypeIndex = nextTypeIndex;
      _selectedCategoryIndex = mappedIndex >= 0 ? mappedIndex : 0;
      _hasTappedAnyItem = true;
    });
  }

  int get _amountValue {
    return CurrencyAmountInputFormatter.parseToMinorUnits(
      _amountController.text,
      _entryCurrency,
    );
  }

  Future<void> _onSaveTap() async {
    final l10n = AppLocalizations.of(context)!;
    final recordId = widget.entry.id;
    if (recordId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorMissingEditId)));
      return;
    }

    if (_selectedCategoryIndex < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorCategoryRequired)));
      return;
    }

    if (_amountValue <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorAmountMustBePositive)));
      return;
    }

    setState(() => _isUpdating = true);

    final isExpense = _selectedTypeIndex == 1;
    final draft = LedgerEntryDraft(
      type: isExpense ? LedgerRecordType.expense : LedgerRecordType.income,
      category: _categoryOptions[_selectedCategoryIndex].code,
      amount: _amountValue,
      currencyCode: widget.entry.currencyCode,
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
        ).showSnackBar(SnackBar(content: Text(l10n.errorEditItemNotFound)));
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
      ).showSnackBar(SnackBar(content: Text(l10n.errorUpdateFailed)));
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _onDeleteTap() async {
    if (_isDeleting || _isUpdating) {
      return;
    }

    final shouldDelete = await _showDeleteConfirmDialog();
    if (!mounted) {
      return;
    }
    if (!shouldDelete) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final recordId = widget.entry.id;
    if (recordId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorMissingDeleteId)));
      return;
    }

    setState(() => _isDeleting = true);

    try {
      final deleted = await _repository.deleteRecord(recordId);
      if (!mounted) {
        return;
      }

      if (!deleted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorDeleteItemNotFound)));
        setState(() => _isDeleting = false);
        return;
      }

      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorDeleteFailed)));
      setState(() => _isDeleting = false);
    }
  }

  Future<bool> _showDeleteConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          backgroundColor: context.appColors.surface,
          content: Text(l10n.deleteRecordConfirm),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: context.appColors.primary,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: context.appColors.danger,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    final contentBottomPadding = safeAreaBottom + 120;

    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LedgerScreenHeader(
              title: l10n.recordDetailTitle,
              onCloseTap: () => Navigator.pop(context),
              actions: [
                LedgerScreenHeaderAction(
                  label: l10n.commonDelete,
                  color: context.appColors.danger,
                  onTap: _onDeleteTap,
                ),
              ],
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
                          currency: _entryCurrency,
                          inputFormatters: [
                            CurrencyAmountInputFormatter(
                              currency: _entryCurrency,
                            ),
                          ],
                          onTap: _markTapped,
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
                          onChanged: _onTypeChanged,
                        ),
                        const SizedBox(height: 24),
                        _SectionLabel(text: l10n.fieldCategory),
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
                        _SectionLabel(text: l10n.fieldMemo),
                        const SizedBox(height: 8),
                        LedgerMemoSection.editable(
                          controller: _memoController,
                          onTap: _markTapped,
                          placeholder:
                              _isMemoInitiallyEmpty
                                  ? l10n.memoEmptyPlaceholderEdit
                                  : null,
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child:
                          _hasTappedAnyItem
                              ? SizedBox(
                                key: const ValueKey('save-button'),
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
                                              context.appColors.background
                                                  .withValues(alpha: 0),
                                              context.appColors.background
                                                  .withValues(alpha: 0.65),
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
                                                context.appColors.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                            ),
                                            elevation: 0,
                                            shadowColor:
                                                AppColors.rgba_19_127_236_025,
                                          ),
                                          onPressed:
                                              _isUpdating || _isDeleting
                                                  ? null
                                                  : _onSaveTap,
                                          child:
                                              _isUpdating
                                                  ? const SizedBox(
                                                    width: 22,
                                                    height: 22,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2.4,
                                                          color:
                                                              AppColors.white,
                                                        ),
                                                  )
                                                  : Text(
                                                    l10n.commonUpdate,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      height: 28 / 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppColors.white,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : const SizedBox.shrink(),
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
