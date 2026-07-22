import 'package:flutter/material.dart';
import 'package:money_mate/data/model/entities/favorite_ledger_record.dart';
import 'package:money_mate/data/model/entities/ledger_record.dart';
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
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const AddFavoriteLedgerRecordScreen(),
      ),
    );
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
              onCloseTap: () => Navigator.pop(context),
              trailing: IconButton(
                onPressed: _openAddFavoriteScreen,
                icon: Icon(
                  Icons.add_rounded,
                  color: context.appColors.textPrimary,
                ),
              ),
            ),
            Expanded(child: _buildBody()),
          ],
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _FavoriteRecordTile(
          favorite: items[index],
          onTap: () => _openAddLedgerRecordScreen(items[index]),
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
  const _FavoriteRecordTile({required this.favorite, required this.onTap});

  final FavoriteLedgerEntry favorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
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
    );
  }
}