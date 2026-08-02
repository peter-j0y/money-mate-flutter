import 'package:flutter/material.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/ledger/view_models/add_favorite_ledger_record_view_model.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_record_item_content.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_screen_header.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_state_card.dart';

import '../../../data/model/entities/ledger_record.dart';

class AddFavoriteLedgerRecordScreen extends StatefulWidget {
  const AddFavoriteLedgerRecordScreen({super.key});

  @override
  State<AddFavoriteLedgerRecordScreen> createState() =>
      _AddFavoriteLedgerRecordScreenState();
}

class _AddFavoriteLedgerRecordScreenState
    extends State<AddFavoriteLedgerRecordScreen> {
  static const double _loadMoreTriggerOffset = 300;

  final AddFavoriteLedgerRecordViewModel _viewModel =
      AddFavoriteLedgerRecordViewModel();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
    _scrollController.addListener(_onScroll);
    _viewModel.loadInitial();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.maxScrollExtent - position.pixels <= _loadMoreTriggerOffset) {
      _viewModel.loadMore();
    }
  }

  Future<void> _onRecordTap(LedgerEntry entry) async {
    final l10n = AppLocalizations.of(context)!;
    final isSuccess = await _viewModel.addToFavorite(entry);
    if (!mounted) {
      return;
    }

    if (isSuccess) {
      Navigator.pop(context, true);
      return;
    }

    final message = _viewModel.errorMessage(l10n) ?? l10n.favoriteAddFailed;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
              title: AppLocalizations.of(context)!.selectFavoriteRecordTitle,
              onCloseTap: () => Navigator.pop(context),
              closeButtonSize: 40,
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    if (_viewModel.isLoadingInitial) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: LedgerStateCard(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final records = _viewModel.records;

    if (records.isEmpty) {
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

      return Center(
        child: Text(
          l10n.noSavedLedgerRecords,
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

    final showBottomLoader = _viewModel.hasMore || _viewModel.isLoadingMore;

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: records.length + (showBottomLoader ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index >= records.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            ),
          );
        }

        final entry = records[index];
        return _LedgerRecordTile(
          entry: entry,
          onTap: _viewModel.isAdding ? null : () => _onRecordTap(entry),
        );
      },
    );
  }
}

class _LedgerRecordTile extends StatelessWidget {
  const _LedgerRecordTile({required this.entry, required this.onTap});

  final LedgerEntry entry;
  final VoidCallback? onTap;

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
          item: entry,
          amountStyle: LedgerAmountStyle.signed,
        ),
      ),
    );
  }
}
