// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navLedger => 'Ledger';

  @override
  String get navAsset => 'Assets';

  @override
  String get navMore => 'More';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonDone => 'Done';

  @override
  String get commonUpdate => 'Update';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String dateWithWeekday(int year, int month, int day, String weekday) {
    return '$month/$day/$year ($weekday)';
  }

  @override
  String monthDayWithWeekday(int month, int day, String weekday) {
    return '$month/$day ($weekday)';
  }

  @override
  String yearMonth(int year, int month) {
    return '$month/$year';
  }

  @override
  String get paymentMethodCash => 'Cash';

  @override
  String get paymentMethodCreditCard => 'Credit Card';

  @override
  String get paymentMethodDebitCard => 'Debit Card';

  @override
  String get paymentMethodBankTransfer => 'Bank Transfer';

  @override
  String get paymentMethodPoints => 'Points';

  @override
  String get paymentMethodOther => 'Other';

  @override
  String get categoryIncomeSalary => 'Salary';

  @override
  String get categoryIncomeSideJob => 'Side Job';

  @override
  String get categoryIncomeBonus => 'Bonus';

  @override
  String get categoryIncomeAllowance => 'Allowance';

  @override
  String get categoryIncomeInterestDividend => 'Interest/Dividend';

  @override
  String get categoryOther => 'Other';

  @override
  String get categoryExpenseFood => 'Food';

  @override
  String get categoryExpenseTransport => 'Transport';

  @override
  String get categoryExpenseShopping => 'Shopping';

  @override
  String get categoryExpenseCultureHobby => 'Culture/Hobby';

  @override
  String get categoryExpenseHousingUtilities => 'Housing/Utilities';

  @override
  String get categoryExpenseMedicalHealth => 'Medical/Health';

  @override
  String get categoryExpenseEducation => 'Education';

  @override
  String get errorLedgerLoadFailed => 'Failed to load ledger records.';

  @override
  String get errorDeleteFailedRetry => 'Failed to delete. Please try again.';

  @override
  String get errorFavoriteListLoadFailed => 'Failed to load favorites.';

  @override
  String get errorAmountMustBePositive => 'Amount must be greater than 0.';

  @override
  String get errorSaveFailedRetry => 'Failed to save. Please try again.';

  @override
  String get errorLoadLedgerRecordsFailed => 'Failed to load ledger records. Please try again.';

  @override
  String errorFavoriteLimitExceeded(int count) {
    return 'You can save up to $count favorites.';
  }

  @override
  String get errorAddFavoriteFailed => 'Failed to add favorite. Please try again.';

  @override
  String get errorAssetSaveFailed => 'Failed to save asset. Please try again.';

  @override
  String get errorAssetNotFound => 'Couldn\'t find the asset to update.';

  @override
  String get errorAssetUpdateFailed => 'Failed to update asset. Please try again.';

  @override
  String get errorAssetNameRequired => 'Please enter an asset name.';

  @override
  String get errorSharesMustBePositive => 'Shares must be greater than 0.';

  @override
  String get errorDateRequired => 'Please select a date.';

  @override
  String get errorTypeRequired => 'Please select a type.';

  @override
  String get errorCategoryRequired => 'Please select a category.';

  @override
  String get errorPaymentMethodRequired => 'Please select a payment method.';

  @override
  String get errorSaveFailed => 'Failed to save.';

  @override
  String get errorMissingEditId => 'Missing item ID to update.';

  @override
  String get errorEditItemNotFound => 'Couldn\'t find the item to update.';

  @override
  String get errorUpdateFailed => 'Failed to update.';

  @override
  String get errorMissingDeleteId => 'Missing item ID to delete.';

  @override
  String get errorDeleteItemNotFound => 'Couldn\'t find the item to delete.';

  @override
  String get errorDeleteFailed => 'Failed to delete.';

  @override
  String get deleteRecordConfirm => 'Once deleted, this record can\'t be recovered. Delete anyway?';

  @override
  String get deleteAssetConfirm => 'Once deleted, this asset can\'t be recovered. Delete anyway?';

  @override
  String get errorAssetDeleteNotFound => 'Couldn\'t find the asset to delete.';

  @override
  String get recordDetailTitle => 'Record Details';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldAmount => 'Amount';

  @override
  String get fieldType => 'Type';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldMemo => 'Memo';

  @override
  String get memoEmptyPlaceholderEdit => 'No memo yet. Add one here.';

  @override
  String get addRecordTitle => 'Add Record';

  @override
  String get actionAdd => 'Add';

  @override
  String get viewCalendar => 'Calendar';

  @override
  String get viewList => 'List';

  @override
  String get typeIncome => 'Income';

  @override
  String get typeExpense => 'Expense';

  @override
  String get summaryTotal => 'Total';

  @override
  String get addShort => '+ Add';

  @override
  String get memoInputPlaceholder => 'Enter a memo (e.g. bus fare home)';

  @override
  String get emptyMonthlyIncome => 'No income entries this month';

  @override
  String get totalIncomeLabel => 'Total Income';

  @override
  String get emptyMonthlyExpense => 'No expense entries this month';

  @override
  String get totalExpenseLabel => 'Total Expense';

  @override
  String totalWithAmount(String amount) {
    return 'Total $amount';
  }

  @override
  String get emptyDateRecords => 'No records for this date';

  @override
  String get favoriteAddFailed => 'Failed to add favorite.';

  @override
  String get selectFavoriteRecordTitle => 'Select a Record to Favorite';

  @override
  String get noSavedLedgerRecords => 'No saved ledger records';

  @override
  String get favoriteTitle => 'Favorites';

  @override
  String get noFavoriteRecords => 'No favorite records';

  @override
  String deleteFavoritesConfirm(int count) {
    return 'Delete $count selected favorites?';
  }

  @override
  String get expensePaymentMethodLabel => 'Payment Method';

  @override
  String supportEmailBody(String appVersion, String osVersion, String deviceModel) {
    return '✍️ Issue report / inquiry:\n\n\n\n----------------------------------\n💡 The information below is technical data used only to help resolve the issue.\n• App version: $appVersion\n• OS version: $osVersion\n• Device: $deviceModel\n----------------------------------';
  }

  @override
  String get cannotOpenPageRetry => 'Couldn\'t open the page. Please try again shortly.';

  @override
  String get inquirySubject => '[Money Mate] Inquiry';

  @override
  String cannotOpenMailApp(String email) {
    return 'Couldn\'t open the mail app. Please contact $email.';
  }

  @override
  String get sectionGeneral => 'General';

  @override
  String get notices => 'Notices';

  @override
  String get sectionSettings => 'Settings';

  @override
  String get sectionSupport => 'Support';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get sectionTermsPolicy => 'Terms & Policies';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get appInfo => 'App Info';

  @override
  String get moreTabTitle => 'More';

  @override
  String get reminderTitle => 'Record Reminder';

  @override
  String get reminderSubtitle => 'We\'ll remind you at your chosen time so you don\'t forget today\'s entry';

  @override
  String get reminderWeekdayLabel => 'Reminder Days';

  @override
  String get reminderTimeLabel => 'Reminder Time';

  @override
  String get reminderNotificationTitle => 'Did you log today\'s expenses?';

  @override
  String get reminderBody1 => 'Spend just a minute logging your ledger and build a spending habit.';

  @override
  String get reminderBody2 => 'Log it before you forget and check for any wasted spending.';

  @override
  String get reminderBody3 => 'Quickly wrap up today\'s spending before you forget!';

  @override
  String get reminderBody4 => 'If you don\'t log it now, you might repeat the same spending tomorrow!';

  @override
  String get notificationDialogTitle => 'Build a Logging Habit';

  @override
  String get notificationDialogBody => 'We\'ll remind you at your set time so you don\'t forget.\nYou can turn off notifications anytime in settings.';

  @override
  String get notificationDialogLater => 'Later';

  @override
  String get notificationDialogAllow => 'Allow Notifications';

  @override
  String get notificationOffTitle => 'Notifications are turned off';

  @override
  String get notificationOffBody => 'Turn on notification permission in settings to receive reminders.';

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get assetTypeStock => 'Stocks';

  @override
  String get assetTypeCash => 'Cash';

  @override
  String get assetTypeRealEstate => 'Real Estate';

  @override
  String get assetTypeCrypto => 'Crypto';

  @override
  String get assetTypeSavings => 'Savings';

  @override
  String get assetTypeCommodity => 'Commodities';

  @override
  String get assetTypeOther => 'Other';

  @override
  String get hintStockName => 'e.g. Samsung Electronics, S&P 500 ETF';

  @override
  String get hintCashName => 'e.g. Cash, USD, emergency fund';

  @override
  String get hintRealEstateName => 'e.g. Deposit, retail space';

  @override
  String get hintCryptoName => 'e.g. Bitcoin, Ethereum';

  @override
  String get hintSavingsName => 'e.g. Housing subscription, youth savings';

  @override
  String get hintCommodityName => 'e.g. Gold, silver, crude oil';

  @override
  String get hintOtherName => 'e.g. Reward points';

  @override
  String get whatAssetType => 'What kind of asset is this?';

  @override
  String get selectAssetType => 'Select Asset Type';

  @override
  String get enterAssetInfo => 'Please enter the asset details';

  @override
  String get assetNameLabel => 'Asset Name';

  @override
  String get currentAmountLabel => 'Current Amount';

  @override
  String get portfolioManagementLabel => 'Portfolio Management';

  @override
  String get includeInPortfolioTitle => 'Include in Portfolio';

  @override
  String get includeInPortfolioSubtitle => 'Reflected in the target ratio chart';

  @override
  String get excludeFromPortfolioTitle => 'Exclude from Portfolio';

  @override
  String get excludeFromPortfolioSubtitle => 'Included in total assets but excluded from ratio calculations';

  @override
  String get editAssetTitle => 'Edit Asset';

  @override
  String get addAssetTitle => 'Add Asset';

  @override
  String addAssetTypeButton(String type) {
    return 'Add $type Asset';
  }

  @override
  String get stockNameLabel => 'Stock Name';

  @override
  String get unitPriceLabel => 'Price per Share';

  @override
  String get sharesHeldLabel => 'Shares Held';

  @override
  String get sharesHint => 'e.g. 10 or 10.5';

  @override
  String get sharesUnit => 'shares';

  @override
  String get currencyUnitSuffix => 'KRW';

  @override
  String get mainCurrencySettingTitle => 'Main Currency';

  @override
  String get currencySettingScreenTitle => 'Main Currency Setting';

  @override
  String get currencySettingDescription => 'New entries will be recorded in the currency you select. Existing entries keep the currency they were originally saved in.';

  @override
  String get currencyNameKrw => 'South Korean Won';

  @override
  String get currencyNameUsd => 'US Dollar';

  @override
  String get currencyNameJpy => 'Japanese Yen';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameCny => 'Chinese Yuan';

  @override
  String get currencyNameGbp => 'British Pound';

  @override
  String get currencyNameHkd => 'Hong Kong Dollar';

  @override
  String sharesWithUnit(String shares) {
    return '$shares shares';
  }

  @override
  String amountWithWonSuffix(String amount) {
    return '₩$amount';
  }

  @override
  String get evaluatedAmountLabel => 'Estimated Value';

  @override
  String categoryNotInPortfolio(String category) {
    return 'The $category category isn\'t in your portfolio';
  }

  @override
  String get addCategoryInPortfolioSettings => 'Add this category in portfolio settings';

  @override
  String get portfolioSettingsLabel => 'Portfolio Settings';

  @override
  String innerRatioLabel(String category) {
    return 'Share within $category';
  }

  @override
  String get overallRatioLabel => 'Share of total assets';

  @override
  String get assetDetailTitle => 'Asset Details';

  @override
  String get includedInPortfolio => 'Included in Portfolio';

  @override
  String get excludedFromPortfolio => 'Excluded from Portfolio';

  @override
  String get excludedFromTargetCalc => 'Excluded from target ratio calculations';

  @override
  String innerRatioWithValue(String category, String ratio) {
    return '$ratio% share within $category';
  }

  @override
  String get assetListLabel => 'Asset List';

  @override
  String get setupPortfolioTitle => 'Set up your portfolio';

  @override
  String get setupPortfolioBody => 'Set target ratios to see your asset allocation at a glance';

  @override
  String get setupPortfolioButton => 'Set Up Portfolio';

  @override
  String get totalAssetsLabel => 'Total Assets';

  @override
  String get noAssetsYet => 'No assets yet';

  @override
  String get addFirstAssetBody => 'Add your first asset to see your portfolio at a glance';

  @override
  String get addAssetButton => 'Add Asset';

  @override
  String get portfolioCompositionLabel => 'Portfolio Composition';

  @override
  String get setTargetRatioButton => 'Set Target Ratio';

  @override
  String get actualRatioLabel => 'Actual Ratio';

  @override
  String targetRatioWithValue(String value) {
    return 'Target $value%';
  }

  @override
  String get ratioActualPrefix => 'Actual ';

  @override
  String get ratioTargetPrefix => 'Target ';

  @override
  String get includedTargetTotalLabel => 'Included Target Total';

  @override
  String get adjustmentNeeded => 'Adjustment Needed';

  @override
  String get equalDistributionButton => 'Equal Split';

  @override
  String actualRatioWithValue(String value) {
    return 'Actual $value%';
  }

  @override
  String get savePortfolioSettingsButton => 'Save Portfolio Settings';

  @override
  String get balanceTargetTo100 => 'Please make the target total 100%.';

  @override
  String get portfolioSaveSuccess => 'Portfolio target ratios saved.';
}
