import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class LedgerCategoryOption {
  const LedgerCategoryOption({
    required this.label,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final IconData icon;
  final Color accentColor;
}

const List<LedgerCategoryOption> ledgerIncomeCategoryOptions = [
  LedgerCategoryOption(
    label: '월급',
    icon: Icons.payments_outlined,
    accentColor: AppColors.hexFF22C55E,
  ),
  LedgerCategoryOption(
    label: '부업',
    icon: Icons.work_outline_rounded,
    accentColor: AppColors.hexFF137FEC,
  ),
  LedgerCategoryOption(
    label: '보너스',
    icon: Icons.card_giftcard_rounded,
    accentColor: AppColors.hexFFF97316,
  ),
  LedgerCategoryOption(
    label: '용돈',
    icon: Icons.savings_outlined,
    accentColor: AppColors.hexFFEC4899,
  ),
  LedgerCategoryOption(
    label: '이자/배당',
    icon: Icons.trending_up_rounded,
    accentColor: AppColors.hexFFA855F7,
  ),
  LedgerCategoryOption(
    label: '기타',
    icon: Icons.more_horiz_rounded,
    accentColor: AppColors.hexFF94A3B8,
  ),
];

const List<LedgerCategoryOption> ledgerExpenseCategoryOptions = [
  LedgerCategoryOption(
    label: '식비',
    icon: Icons.restaurant_rounded,
    accentColor: AppColors.hexFFF97316,
  ),
  LedgerCategoryOption(
    label: '교통',
    icon: Icons.directions_bus_filled_rounded,
    accentColor: AppColors.hexFF137FEC,
  ),
  LedgerCategoryOption(
    label: '쇼핑',
    icon: Icons.shopping_bag_outlined,
    accentColor: AppColors.hexFFEC4899,
  ),
  LedgerCategoryOption(
    label: '문화/취미',
    icon: Icons.theaters_outlined,
    accentColor: AppColors.hexFFA855F7,
  ),
  LedgerCategoryOption(
    label: '주거/통신',
    icon: Icons.home_outlined,
    accentColor: AppColors.hexFF22C55E,
  ),
  LedgerCategoryOption(
    label: '의료/건강',
    icon: Icons.medical_services_outlined,
    accentColor: AppColors.hexFF14B8A6,
  ),
  LedgerCategoryOption(
    label: '교육',
    icon: Icons.school_outlined,
    accentColor: AppColors.hexFFD97706,
  ),
  LedgerCategoryOption(
    label: '기타',
    icon: Icons.more_horiz_rounded,
    accentColor: AppColors.hexFF94A3B8,
  ),
];
