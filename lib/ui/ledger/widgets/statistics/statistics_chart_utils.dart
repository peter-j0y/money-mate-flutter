import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show Intl, NumberFormat;
import 'package:money_mate/data/model/entities/currency.dart';
import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_category_options.dart';

const String _otherCategoryCode = '기타';

List<LedgerCategoryOption> _optionsFor(LedgerRecordType type) =>
    type == LedgerRecordType.expense
        ? ledgerExpenseCategoryOptions
        : ledgerIncomeCategoryOptions;

/// 차트 축처럼 공간이 좁은 곳에 쓰는 축약 금액(예: "120만", "1.2M").
/// 소수점 통화는 최소단위를 실제 금액 단위로 바꿔서 축약한다.
String statisticsCompactAmount(int amount, CurrencyCode currency) {
  final value = amount / currency.minorUnitScale;
  return NumberFormat.compact(locale: Intl.getCurrentLocale()).format(value);
}

/// 카테고리별 차트 색상. 카테고리 정의 순서대로 팔레트를 배정하고,
/// '기타'는 항상 팔레트 마지막의 중립색을 쓴다.
Color statisticsCategoryColor(
  BuildContext context,
  LedgerRecordType type,
  String category,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final palette =
      isDark ? AppColors.chartCategoryDark : AppColors.chartCategoryLight;
  if (category == _otherCategoryCode) return palette.last;

  final codes = [
    for (final option in _optionsFor(type))
      if (option.code != _otherCategoryCode) option.code,
  ];
  final index = codes.indexOf(category);
  if (index < 0) return palette.last;
  return palette[index % (palette.length - 1)];
}

String statisticsCategoryLabel(
  AppLocalizations l10n,
  LedgerRecordType type,
  String category,
) {
  final options = _optionsFor(type);
  final option = options.firstWhere(
    (option) => option.code == category,
    orElse: () => options.last,
  );
  return option.label(l10n);
}

/// 축 눈금이 [divisions]등분으로 깔끔하게 떨어지도록 [maxValue] 이상인 최대값을 고른다.
double statisticsNiceAxisMax(int maxValue, {int divisions = 4}) {
  if (maxValue <= 0) return divisions.toDouble();
  final rawStep = maxValue / divisions;
  final magnitude =
      math.pow(10, (math.log(rawStep) / math.ln10).floor()).toDouble();
  for (final factor in const [1.0, 2.0, 2.5, 5.0, 10.0]) {
    final step = factor * magnitude;
    if (step >= rawStep) return step * divisions;
  }
  return 10 * magnitude * divisions;
}
