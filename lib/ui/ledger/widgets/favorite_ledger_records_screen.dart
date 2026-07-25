import 'package:flutter/material.dart';
import 'package:money_mate/data/model/entities/favorite_ledger_record.dart';
import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/data/repositories/favorite_ledger_record_repository.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/ledger/view_models/favorite_ledger_records_view_model.dart';
import 'package:money_mate/ui/ledger/widgets/add_favorite_ledger_record_screen.dart';
import 'package:money_mate/ui/ledger/widgets/add_ledger_record_screen.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_record_item_content.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_screen_header.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_state_card.dart';

class FavoriteLedgerRecordsScreen extends StatefulWidget {
  const FavoriteLedgerRecordsScreen({super.key});

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
          content: Text('즐겨찾기는 최대 $maxFavoriteLedgerRecordCount개까지 저장할 수 있어요.'),
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

    final isSuccess = await _viewModel.deleteFavorites(_selectedIds);
    if (!mounted) {
      return;
    }

    if (isSuccess) {
      setState(() => _selectedIds = {});
      return;
    }

    final message = _viewModel.actionErrorMessage ?? '삭제 중 오류가 발생했습니다.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _showDeleteConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: context.appColors.surface,
          content: Text('선택한 ${_selectedIds.length}개 항목을 즐겨찾기에서 삭제할까요?'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: context.appColors.primary,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: context.appColors.danger,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('삭제'),
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
              title: '즐겨찾기',
              onCloseTap:
                  _isEditMode ? _exitEditMode : () => Navigator.pop(context),
              trailing:
                  _isEditMode ? _buildDeleteAction() : _buildDefaultActions(),
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

  Widget _buildDeleteAction() {
    final canDelete = _selectedIds.isNotEmpty && !_viewModel.isDeleting;
    return TextButton(
      onPressed: canDelete ? _onDeleteSelectedTap : null,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        '삭제',
        style: TextStyle(
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w500,
          color:
              canDelete
                  ? context.appColors.danger
                  : context.appColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: LedgerStateCard(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final errorMessage = _viewModel.errorMessage;
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
          '즐겨찾기한 내역이 없어요',
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
              ),
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
