import 'package:flutter/material.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class LedgerCategoryOption {
  const LedgerCategoryOption({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
}

const List<LedgerCategoryOption> ledgerIncomeCategoryOptions = [
  LedgerCategoryOption(
    label: '월급',
    icon: Icons.payments_outlined,
    backgroundColor: AppColors.hexFFDCFCE7,
    iconColor: AppColors.hexFF22C55E,
  ),
  LedgerCategoryOption(
    label: '부업',
    icon: Icons.work_outline_rounded,
    backgroundColor: AppColors.hexFFDBEAFE,
    iconColor: AppColors.hexFF137FEC,
  ),
  LedgerCategoryOption(
    label: '보너스',
    icon: Icons.card_giftcard_rounded,
    backgroundColor: AppColors.hexFFFFEDD5,
    iconColor: AppColors.hexFFF97316,
  ),
  LedgerCategoryOption(
    label: '용돈',
    icon: Icons.savings_outlined,
    backgroundColor: AppColors.hexFFFCE7F3,
    iconColor: AppColors.hexFFEC4899,
  ),
  LedgerCategoryOption(
    label: '이자/배당',
    icon: Icons.trending_up_rounded,
    backgroundColor: AppColors.hexFFF3E8FF,
    iconColor: AppColors.hexFFA855F7,
  ),
  LedgerCategoryOption(
    label: '기타',
    icon: Icons.more_horiz_rounded,
    backgroundColor: AppColors.hexFFF1F5F9,
    iconColor: AppColors.hexFF94A3B8,
  ),
];

const List<LedgerCategoryOption> ledgerExpenseCategoryOptions = [
  LedgerCategoryOption(
    label: '식비',
    icon: Icons.restaurant_rounded,
    backgroundColor: AppColors.hexFFFFEDD5,
    iconColor: AppColors.hexFFF97316,
  ),
  LedgerCategoryOption(
    label: '교통',
    icon: Icons.directions_bus_filled_rounded,
    backgroundColor: AppColors.hexFFDBEAFE,
    iconColor: AppColors.hexFF137FEC,
  ),
  LedgerCategoryOption(
    label: '쇼핑',
    icon: Icons.shopping_bag_outlined,
    backgroundColor: AppColors.hexFFFCE7F3,
    iconColor: AppColors.hexFFEC4899,
  ),
  LedgerCategoryOption(
    label: '문화/취미',
    icon: Icons.theaters_outlined,
    backgroundColor: AppColors.hexFFF3E8FF,
    iconColor: AppColors.hexFFA855F7,
  ),
  LedgerCategoryOption(
    label: '주거/통신',
    icon: Icons.home_outlined,
    backgroundColor: AppColors.hexFFDCFCE7,
    iconColor: AppColors.hexFF22C55E,
  ),
  LedgerCategoryOption(
    label: '의료/건강',
    icon: Icons.medical_services_outlined,
    backgroundColor: AppColors.hexFFCCFBF1,
    iconColor: AppColors.hexFF14B8A6,
  ),
  LedgerCategoryOption(
    label: '교육',
    icon: Icons.school_outlined,
    backgroundColor: AppColors.hexFFFEF9C3,
    iconColor: AppColors.hexFFD97706,
  ),
  LedgerCategoryOption(
    label: '기타',
    icon: Icons.more_horiz_rounded,
    backgroundColor: AppColors.hexFFF1F5F9,
    iconColor: AppColors.hexFF94A3B8,
  ),
];
