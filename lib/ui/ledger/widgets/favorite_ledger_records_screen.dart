import 'package:flutter/material.dart';
import 'package:money_mate/data/model/entities/favorite_ledger_record.dart';
import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/data/repositories/favorite_ledger_record_repository.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/ledger/view_models/favorite_ledger_records_view_model.dart';
import 'package:money_mate/ui/ledger/widgets/add_favorite_ledger_record_screen.dart';
import 'package:money_mate/ui/ledger/widgets/add_ledger_record_screen.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_record_item_content.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_screen_header.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_state_card.dart';

class FavoriteLedgerRecordsScreen extends StatefulWidget {
  const FavoriteLedgerRecordsScreen({super.key, this.isSelectMode = false});

  final bool isSelectMode;

  @override
  State<FavoriteLedgerRecordsScreen> createState() =>
      _FavoriteLedgerRecordsScreenState();
}

class _FavoriteLedgerRecordsScreenState
    extends State<FavoriteLedgerRecordsScreen> {
  final FavoriteLedgerRecordsViewModel _viewModel =
      FavoriteLedgerRecordsViewModel();

  bool _isEditMode = false;
  Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _openAddFavoriteScreen() {
    if (_viewModel.isAtLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.errorFavoriteLimitExceeded(maxFavoriteLedgerRecordCount),
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const AddFavoriteLedgerRecordScreen(),
      ),
    );
  }

  void _enterEditMode({int? initialSelectedId}) {
    setState(() {
      _isEditMode = true;
      _selectedIds = initialSelectedId == null ? {} : {initialSelectedId};
    });
  }

  void _exitEditMode() {
    setState(() {
      _isEditMode = false;
      _selectedIds = {};
    });
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _onDeleteSelectedTap() async {
    if (_selectedIds.isEmpty || _viewModel.isDeleting) {
      return;
    }

    final shouldDelete = await _showDeleteConfirmDialog();
    if (!mounted || !shouldDelete) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final isSuccess = await _viewModel.deleteFavorites(_selectedIds);
    if (!mounted) {
      return;
    }

    if (isSuccess) {
      setState(() => _selectedIds = {});
      return;
    }

    final message =
        _viewModel.actionErrorMessage(l10n) ?? l10n.errorDeleteFailed;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _showDeleteConfirmDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: context.appColors.surface,
          content: Text(l10n.deleteFavoritesConfirm(_selectedIds.length)),
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
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LedgerScreenHeader(
              title: AppLocalizations.of(context)!.favoriteTitle,
              onCloseTap:
                  _isEditMode ? _exitEditMode : () => Navigator.pop(context),
              trailing: _isEditMode ? null : _buildDefaultActions(),
            ),
            Expanded(
              child: Stack(
                children: [
                  if (_isEditMode)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _exitEditMode,
                      ),
                    ),
                  _buildBody(),
                ],
              ),
            ),
            if (_isEditMode) _buildDeleteBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _enterEditMode(),
          icon: Icon(Icons.edit_outlined, color: context.appColors.textPrimary),
        ),
        IconButton(
          onPressed: _openAddFavoriteScreen,
          icon: Icon(Icons.add_rounded, color: context.appColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildDeleteBottomBar() {
    final safeAreaBottom = MediaQuery.paddingOf(context).bottom;
    final canDelete = _selectedIds.isNotEmpty && !_viewModel.isDeleting;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, safeAreaBottom + 12),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: canDelete ? _onDeleteSelectedTap : null,
          style: FilledButton.styleFrom(
            backgroundColor:
                canDelete ? context.appColors.danger : context.appColors.border,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child:
              _viewModel.isDeleting
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.white,
                    ),
                  )
                  : Text(
                    AppLocalizations.of(context)!.commonDelete,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    if (_viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: LedgerStateCard(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final errorMessage = _viewModel.errorMessage(l10n);
    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: LedgerStateCard(
          child: Center(
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w500,
                color: context.appColors.danger,
              ),
            ),
          ),
        ),
      );
    }

    final items = _viewModel.records;
    if (items.isEmpty) {
      return Center(
        child: Text(
          l10n.noFavoriteRecords,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w500,
            color: context.appColors.textTertiary,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final favorite = items[index];
        return _FavoriteRecordTile(
          favorite: favorite,
          isEditMode: _isEditMode,
          isSelected: _selectedIds.contains(favorite.id),
          onTap: () {
            if (_isEditMode) {
              _toggleSelection(favorite.id);
            } else if (widget.isSelectMode) {
              Navigator.of(context).pop(favorite);
            } else {
              _openAddLedgerRecordScreen(favorite);
            }
          },
          onLongPress: () {
            if (_isEditMode) {
              _toggleSelection(favorite.id);
            } else {
              _enterEditMode(initialSelectedId: favorite.id);
            }
          },
        );
      },
    );
  }

  Future<void> _openAddLedgerRecordScreen(FavoriteLedgerEntry favorite) async {
    final didSave = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder:
            (context) => AddLedgerRecordScreen(
              initialDate: DateTime.now(),
              initialType: favorite.type,
              initialCategory: favorite.category,
              initialAmount: favorite.amount,
              initialPaymentMethod: favorite.paymentMethod,
              initialMemo: favorite.memo,
            ),
      ),
    );

    if (didSave == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }
}

class _FavoriteRecordTile extends StatelessWidget {
  const _FavoriteRecordTile({
    required this.favorite,
    required this.isEditMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  final FavoriteLedgerEntry favorite;
  final bool isEditMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (isEditMode) ...[
              Checkbox(
                value: isSelected,
                onChanged: (_) => onTap(),
                activeColor: context.appColors.primary,
                checkColor: AppColors.white,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: LedgerRecordItemContent(
                item: LedgerEntry(
                  id: favorite.id,
                  type: favorite.type,
                  category: favorite.category,
                  amount: favorite.amount,
                  date: favorite.createdAt,
                  paymentMethod: favorite.paymentMethod,
                  memo: favorite.memo,
                ),
                amountStyle: LedgerAmountStyle.signed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
