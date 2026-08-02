import 'package:flutter/material.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';

class LedgerCategoryOption {
  const LedgerCategoryOption({
    required this.code,
    required this.icon,
    required this.accentColor,
  });

  /// 저장/매칭에 쓰이는 안정적인 값(과거 데이터 호환을 위해 한글 문자열을 그대로 사용).
  final String code;
  final IconData icon;
  final Color accentColor;

  String label(AppLocalizations l10n) {
    switch (code) {
      case '월급':
        return l10n.categoryIncomeSalary;
      case '부업':
        return l10n.categoryIncomeSideJob;
      case '보너스':
        return l10n.categoryIncomeBonus;
      case '용돈':
        return l10n.categoryIncomeAllowance;
      case '이자/배당':
        return l10n.categoryIncomeInterestDividend;
      case '식비':
        return l10n.categoryExpenseFood;
      case '교통':
        return l10n.categoryExpenseTransport;
      case '쇼핑':
        return l10n.categoryExpenseShopping;
      case '문화/취미':
        return l10n.categoryExpenseCultureHobby;
      case '주거/통신':
        return l10n.categoryExpenseHousingUtilities;
      case '의료/건강':
        return l10n.categoryExpenseMedicalHealth;
      case '교육':
        return l10n.categoryExpenseEducation;
      case '기타':
      default:
        return l10n.categoryOther;
    }
  }
}

const List<LedgerCategoryOption> ledgerIncomeCategoryOptions = [
  LedgerCategoryOption(
    code: '월급',
    icon: Icons.payments_outlined,
    accentColor: AppColors.hexFF22C55E,
  ),
  LedgerCategoryOption(
    code: '부업',
    icon: Icons.work_outline_rounded,
    accentColor: AppColors.hexFF137FEC,
  ),
  LedgerCategoryOption(
    code: '보너스',
    icon: Icons.card_giftcard_rounded,
    accentColor: AppColors.hexFFF97316,
  ),
  LedgerCategoryOption(
    code: '용돈',
    icon: Icons.savings_outlined,
    accentColor: AppColors.hexFFEC4899,
  ),
  LedgerCategoryOption(
    code: '이자/배당',
    icon: Icons.trending_up_rounded,
    accentColor: AppColors.hexFFA855F7,
  ),
  LedgerCategoryOption(
    code: '기타',
    icon: Icons.more_horiz_rounded,
    accentColor: AppColors.hexFF94A3B8,
  ),
];

const List<LedgerCategoryOption> ledgerExpenseCategoryOptions = [
  LedgerCategoryOption(
    code: '식비',
    icon: Icons.restaurant_rounded,
    accentColor: AppColors.hexFFF97316,
  ),
  LedgerCategoryOption(
    code: '교통',
    icon: Icons.directions_bus_filled_rounded,
    accentColor: AppColors.hexFF137FEC,
  ),
  LedgerCategoryOption(
    code: '쇼핑',
    icon: Icons.shopping_bag_outlined,
    accentColor: AppColors.hexFFEC4899,
  ),
  LedgerCategoryOption(
    code: '문화/취미',
    icon: Icons.theaters_outlined,
    accentColor: AppColors.hexFFA855F7,
  ),
  LedgerCategoryOption(
    code: '주거/통신',
    icon: Icons.home_outlined,
    accentColor: AppColors.hexFF22C55E,
  ),
  LedgerCategoryOption(
    code: '의료/건강',
    icon: Icons.medical_services_outlined,
    accentColor: AppColors.hexFF14B8A6,
  ),
  LedgerCategoryOption(
    code: '교육',
    icon: Icons.school_outlined,
    accentColor: AppColors.hexFFD97706,
  ),
  LedgerCategoryOption(
    code: '기타',
    icon: Icons.more_horiz_rounded,
    accentColor: AppColors.hexFF94A3B8,
  ),
];
