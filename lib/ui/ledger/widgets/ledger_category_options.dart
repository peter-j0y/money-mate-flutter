import 'package:flutter/material.dart';

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
    backgroundColor: Color(0xFFDCFCE7),
    iconColor: Color(0xFF22C55E),
  ),
  LedgerCategoryOption(
    label: '부업',
    icon: Icons.work_outline_rounded,
    backgroundColor: Color(0xFFDBEAFE),
    iconColor: Color(0xFF137FEC),
  ),
  LedgerCategoryOption(
    label: '보너스',
    icon: Icons.card_giftcard_rounded,
    backgroundColor: Color(0xFFFFEDD5),
    iconColor: Color(0xFFF97316),
  ),
  LedgerCategoryOption(
    label: '용돈',
    icon: Icons.savings_outlined,
    backgroundColor: Color(0xFFFCE7F3),
    iconColor: Color(0xFFEC4899),
  ),
  LedgerCategoryOption(
    label: '이자/배당',
    icon: Icons.trending_up_rounded,
    backgroundColor: Color(0xFFF3E8FF),
    iconColor: Color(0xFFA855F7),
  ),
  LedgerCategoryOption(
    label: '기타',
    icon: Icons.more_horiz_rounded,
    backgroundColor: Color(0xFFF1F5F9),
    iconColor: Color(0xFF94A3B8),
  ),
];

const List<LedgerCategoryOption> ledgerExpenseCategoryOptions = [
  LedgerCategoryOption(
    label: '식비',
    icon: Icons.restaurant_rounded,
    backgroundColor: Color(0xFFFFEDD5),
    iconColor: Color(0xFFF97316),
  ),
  LedgerCategoryOption(
    label: '교통',
    icon: Icons.directions_bus_filled_rounded,
    backgroundColor: Color(0xFFDBEAFE),
    iconColor: Color(0xFF137FEC),
  ),
  LedgerCategoryOption(
    label: '쇼핑',
    icon: Icons.shopping_bag_outlined,
    backgroundColor: Color(0xFFFCE7F3),
    iconColor: Color(0xFFEC4899),
  ),
  LedgerCategoryOption(
    label: '문화/취미',
    icon: Icons.theaters_outlined,
    backgroundColor: Color(0xFFF3E8FF),
    iconColor: Color(0xFFA855F7),
  ),
  LedgerCategoryOption(
    label: '주거/통신',
    icon: Icons.home_outlined,
    backgroundColor: Color(0xFFDCFCE7),
    iconColor: Color(0xFF22C55E),
  ),
  LedgerCategoryOption(
    label: '의료/건강',
    icon: Icons.medical_services_outlined,
    backgroundColor: Color(0xFFCCFBF1),
    iconColor: Color(0xFF14B8A6),
  ),
  LedgerCategoryOption(
    label: '교육',
    icon: Icons.school_outlined,
    backgroundColor: Color(0xFFFEF9C3),
    iconColor: Color(0xFFD97706),
  ),
  LedgerCategoryOption(
    label: '기타',
    icon: Icons.more_horiz_rounded,
    backgroundColor: Color(0xFFF1F5F9),
    iconColor: Color(0xFF94A3B8),
  ),
];
