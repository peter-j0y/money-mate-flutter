import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/l10n/app_localizations.dart';

extension ExpensePaymentMethodLocalizationX on ExpensePaymentMethod {
  String label(AppLocalizations l10n) {
    switch (this) {
      case ExpensePaymentMethod.cash:
        return l10n.paymentMethodCash;
      case ExpensePaymentMethod.creditCard:
        return l10n.paymentMethodCreditCard;
      case ExpensePaymentMethod.debitCard:
        return l10n.paymentMethodDebitCard;
      case ExpensePaymentMethod.bankTransfer:
        return l10n.paymentMethodBankTransfer;
      case ExpensePaymentMethod.points:
        return l10n.paymentMethodPoints;
      case ExpensePaymentMethod.other:
        return l10n.paymentMethodOther;
    }
  }
}
