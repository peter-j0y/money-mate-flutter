import 'package:money_mate/data/model/entities/ledger_record.dart';

extension ExpensePaymentMethodLocalizationX on ExpensePaymentMethod {
  String get koreanLabel {
    switch (this) {
      case ExpensePaymentMethod.cash:
        return '현금';
      case ExpensePaymentMethod.creditCard:
        return '신용카드';
      case ExpensePaymentMethod.debitCard:
        return '체크카드';
      case ExpensePaymentMethod.bankTransfer:
        return '계좌이체';
      case ExpensePaymentMethod.points:
        return '포인트';
      case ExpensePaymentMethod.other:
        return '기타';
    }
  }
}
