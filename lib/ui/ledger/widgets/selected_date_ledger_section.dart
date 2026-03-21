import 'package:flutter/material.dart';
import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/ui/ledger/extensions/expense_payment_method_localization.dart';

class SelectedDateLedgerSection extends StatelessWidget {
  const SelectedDateLedgerSection({
    super.key,
    required this.selectedDate,
    required this.items,
    required this.isLoading,
    required this.errorMessage,
    required this.selectedDateLabelBuilder,
  });

  final DateTime? selectedDate;
  final List<LedgerEntry> items;
  final bool isLoading;
  final String? errorMessage;
  final String Function(DateTime) selectedDateLabelBuilder;

  @override
  Widget build(BuildContext context) {
    if (selectedDate == null) {
      return const SizedBox.shrink();
    }

    final totalAmount = items.fold<int>(
      0,
      (sum, item) =>
          sum +
          (item.type == LedgerRecordType.income ? item.amount : -item.amount),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedDateLabelBuilder(selectedDate!),
                style: const TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                '합계 ${_wonText(totalAmount)}',
                style: const TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isLoading)
            _StateCard(child: const Center(child: CircularProgressIndicator()))
          else if (errorMessage != null)
            _StateCard(
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFEF4444),
                ),
              ),
            )
          else if (items.isEmpty)
            const _StateCard(
              child: Text(
                '해당 날짜에 등록된 내역이 없어요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _DailyLedgerListTile(item: item),
              ),
            ),
        ],
      ),
    );
  }

  String _wonText(int amount) {
    final sign = amount < 0 ? '-' : '';
    final reversed = amount.abs().toString().split('').reversed.toList();
    final buffer = StringBuffer();

    for (var i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(reversed[i]);
    }

    return '$sign${buffer.toString().split('').reversed.join()}원';
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _DailyLedgerListTile extends StatelessWidget {
  const _DailyLedgerListTile({required this.item});

  final LedgerEntry item;

  @override
  Widget build(BuildContext context) {
    final isIncome = item.type == LedgerRecordType.income;
    final amountColor =
        isIncome ? const Color(0xFF137FEC) : const Color(0xFFF43F5E);
    final amountPrefix = isIncome ? '+' : '-';
    final style = _LedgerCategoryStyle.from(item);
    final subtitle = _truncateSubtitle(item.memo?.trim());
    final hasSubtitle = subtitle != null && subtitle.isNotEmpty;
    final rightBottomText =
        isIncome ? null : item.paymentMethod?.koreanLabel;
    final hasRightBottomText =
        rightBottomText != null && rightBottomText.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: style.iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(style.icon, color: style.iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (hasSubtitle) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountPrefix${_wonText(item.amount)}',
                style: TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w500,
                  color: amountColor,
                ),
              ),
              if (hasRightBottomText) ...[
                const SizedBox(height: 1),
                Text(
                  rightBottomText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 15 / 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _wonText(int amount) {
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

  String? _truncateSubtitle(String? text) {
    if (text == null || text.isEmpty) {
      return null;
    }
    if (text.length <= 10) {
      return text;
    }
    return '${text.substring(0, 10)}...';
  }
}

class _LedgerCategoryStyle {
  const _LedgerCategoryStyle({
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;

  static _LedgerCategoryStyle from(LedgerEntry entry) {
    switch (entry.category) {
      case '월급':
      case '부업':
      case '보너스':
      case '용돈':
      case '이자/배당':
        return const _LedgerCategoryStyle(
          icon: Icons.payments_outlined,
          iconBackgroundColor: Color(0xFFDDEAF6),
          iconColor: Color(0xFF137FEC),
        );
      case '식비':
        return const _LedgerCategoryStyle(
          icon: Icons.restaurant_rounded,
          iconBackgroundColor: Color(0xFFFFE4E6),
          iconColor: Color(0xFFF43F5E),
        );
      case '쇼핑':
        return const _LedgerCategoryStyle(
          icon: Icons.shopping_cart_outlined,
          iconBackgroundColor: Color(0xFFFEF3C7),
          iconColor: Color(0xFFD97706),
        );
      case '교통':
        return const _LedgerCategoryStyle(
          icon: Icons.directions_bus_filled_rounded,
          iconBackgroundColor: Color(0xFFDBEAFE),
          iconColor: Color(0xFF137FEC),
        );
      case '문화/취미':
        return const _LedgerCategoryStyle(
          icon: Icons.theaters_outlined,
          iconBackgroundColor: Color(0xFFF3E8FF),
          iconColor: Color(0xFFA855F7),
        );
      case '주거/통신':
        return const _LedgerCategoryStyle(
          icon: Icons.home_outlined,
          iconBackgroundColor: Color(0xFFDCFCE7),
          iconColor: Color(0xFF22C55E),
        );
      case '의료/건강':
        return const _LedgerCategoryStyle(
          icon: Icons.medical_services_outlined,
          iconBackgroundColor: Color(0xFFCCFBF1),
          iconColor: Color(0xFF14B8A6),
        );
      case '교육':
        return const _LedgerCategoryStyle(
          icon: Icons.school_outlined,
          iconBackgroundColor: Color(0xFFFEF9C3),
          iconColor: Color(0xFFD97706),
        );
      default:
        final isIncome = entry.type == LedgerRecordType.income;
        return _LedgerCategoryStyle(
          icon:
              isIncome ? Icons.payments_outlined : Icons.receipt_long_outlined,
          iconBackgroundColor:
              isIncome ? const Color(0xFFDDEAF6) : const Color(0xFFF1F5F9),
          iconColor:
              isIncome ? const Color(0xFF137FEC) : const Color(0xFF94A3B8),
        );
    }
  }
}
