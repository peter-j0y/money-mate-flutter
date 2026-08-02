import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko')
  ];

  /// No description provided for @navLedger.
  ///
  /// In ko, this message translates to:
  /// **'가계부'**
  String get navLedger;

  /// No description provided for @navAsset.
  ///
  /// In ko, this message translates to:
  /// **'자산'**
  String get navAsset;

  /// No description provided for @navMore.
  ///
  /// In ko, this message translates to:
  /// **'더보기'**
  String get navMore;

  /// No description provided for @commonCancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get commonDelete;

  /// No description provided for @commonDone.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get commonDone;

  /// No description provided for @commonUpdate.
  ///
  /// In ko, this message translates to:
  /// **'수정하기'**
  String get commonUpdate;

  /// No description provided for @weekdayMon.
  ///
  /// In ko, this message translates to:
  /// **'월'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In ko, this message translates to:
  /// **'화'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In ko, this message translates to:
  /// **'수'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In ko, this message translates to:
  /// **'목'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In ko, this message translates to:
  /// **'금'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In ko, this message translates to:
  /// **'토'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In ko, this message translates to:
  /// **'일'**
  String get weekdaySun;

  /// No description provided for @dateWithWeekday.
  ///
  /// In ko, this message translates to:
  /// **'{year}년 {month}월 {day}일 ({weekday})'**
  String dateWithWeekday(int year, int month, int day, String weekday);

  /// No description provided for @monthDayWithWeekday.
  ///
  /// In ko, this message translates to:
  /// **'{month}월 {day}일 ({weekday})'**
  String monthDayWithWeekday(int month, int day, String weekday);

  /// No description provided for @yearMonth.
  ///
  /// In ko, this message translates to:
  /// **'{year}년 {month}월'**
  String yearMonth(int year, int month);

  /// No description provided for @paymentMethodCash.
  ///
  /// In ko, this message translates to:
  /// **'현금'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodCreditCard.
  ///
  /// In ko, this message translates to:
  /// **'신용카드'**
  String get paymentMethodCreditCard;

  /// No description provided for @paymentMethodDebitCard.
  ///
  /// In ko, this message translates to:
  /// **'체크카드'**
  String get paymentMethodDebitCard;

  /// No description provided for @paymentMethodBankTransfer.
  ///
  /// In ko, this message translates to:
  /// **'계좌이체'**
  String get paymentMethodBankTransfer;

  /// No description provided for @paymentMethodPoints.
  ///
  /// In ko, this message translates to:
  /// **'포인트'**
  String get paymentMethodPoints;

  /// No description provided for @paymentMethodOther.
  ///
  /// In ko, this message translates to:
  /// **'기타'**
  String get paymentMethodOther;

  /// No description provided for @categoryIncomeSalary.
  ///
  /// In ko, this message translates to:
  /// **'월급'**
  String get categoryIncomeSalary;

  /// No description provided for @categoryIncomeSideJob.
  ///
  /// In ko, this message translates to:
  /// **'부업'**
  String get categoryIncomeSideJob;

  /// No description provided for @categoryIncomeBonus.
  ///
  /// In ko, this message translates to:
  /// **'보너스'**
  String get categoryIncomeBonus;

  /// No description provided for @categoryIncomeAllowance.
  ///
  /// In ko, this message translates to:
  /// **'용돈'**
  String get categoryIncomeAllowance;

  /// No description provided for @categoryIncomeInterestDividend.
  ///
  /// In ko, this message translates to:
  /// **'이자/배당'**
  String get categoryIncomeInterestDividend;

  /// No description provided for @categoryOther.
  ///
  /// In ko, this message translates to:
  /// **'기타'**
  String get categoryOther;

  /// No description provided for @categoryExpenseFood.
  ///
  /// In ko, this message translates to:
  /// **'식비'**
  String get categoryExpenseFood;

  /// No description provided for @categoryExpenseTransport.
  ///
  /// In ko, this message translates to:
  /// **'교통'**
  String get categoryExpenseTransport;

  /// No description provided for @categoryExpenseShopping.
  ///
  /// In ko, this message translates to:
  /// **'쇼핑'**
  String get categoryExpenseShopping;

  /// No description provided for @categoryExpenseCultureHobby.
  ///
  /// In ko, this message translates to:
  /// **'문화/취미'**
  String get categoryExpenseCultureHobby;

  /// No description provided for @categoryExpenseHousingUtilities.
  ///
  /// In ko, this message translates to:
  /// **'주거/통신'**
  String get categoryExpenseHousingUtilities;

  /// No description provided for @categoryExpenseMedicalHealth.
  ///
  /// In ko, this message translates to:
  /// **'의료/건강'**
  String get categoryExpenseMedicalHealth;

  /// No description provided for @categoryExpenseEducation.
  ///
  /// In ko, this message translates to:
  /// **'교육'**
  String get categoryExpenseEducation;

  /// No description provided for @errorLedgerLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'가계부 내역을 불러오는 중 오류가 발생했습니다.'**
  String get errorLedgerLoadFailed;

  /// No description provided for @errorDeleteFailedRetry.
  ///
  /// In ko, this message translates to:
  /// **'삭제 중 오류가 발생했습니다. 다시 시도해 주세요.'**
  String get errorDeleteFailedRetry;

  /// No description provided for @errorFavoriteListLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기 목록을 불러오는 중 오류가 발생했습니다.'**
  String get errorFavoriteListLoadFailed;

  /// No description provided for @errorAmountMustBePositive.
  ///
  /// In ko, this message translates to:
  /// **'금액은 0원보다 커야 합니다.'**
  String get errorAmountMustBePositive;

  /// No description provided for @errorSaveFailedRetry.
  ///
  /// In ko, this message translates to:
  /// **'저장 중 오류가 발생했습니다. 다시 시도해 주세요.'**
  String get errorSaveFailedRetry;

  /// No description provided for @errorLoadLedgerRecordsFailed.
  ///
  /// In ko, this message translates to:
  /// **'가계부 기록을 불러오지 못했습니다. 다시 시도해 주세요.'**
  String get errorLoadLedgerRecordsFailed;

  /// No description provided for @errorFavoriteLimitExceeded.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기는 최대 {count}개까지 저장할 수 있어요.'**
  String errorFavoriteLimitExceeded(int count);

  /// No description provided for @errorAddFavoriteFailed.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기 추가 중 오류가 발생했습니다. 다시 시도해 주세요.'**
  String get errorAddFavoriteFailed;

  /// No description provided for @errorAssetSaveFailed.
  ///
  /// In ko, this message translates to:
  /// **'자산 저장 중 오류가 발생했습니다. 다시 시도해 주세요.'**
  String get errorAssetSaveFailed;

  /// No description provided for @errorAssetNotFound.
  ///
  /// In ko, this message translates to:
  /// **'수정할 자산을 찾지 못했어요.'**
  String get errorAssetNotFound;

  /// No description provided for @errorAssetUpdateFailed.
  ///
  /// In ko, this message translates to:
  /// **'자산 수정 중 오류가 발생했습니다. 다시 시도해 주세요.'**
  String get errorAssetUpdateFailed;

  /// No description provided for @errorAssetNameRequired.
  ///
  /// In ko, this message translates to:
  /// **'자산명을 입력해 주세요.'**
  String get errorAssetNameRequired;

  /// No description provided for @errorSharesMustBePositive.
  ///
  /// In ko, this message translates to:
  /// **'주수는 0보다 커야 합니다.'**
  String get errorSharesMustBePositive;

  /// No description provided for @errorDateRequired.
  ///
  /// In ko, this message translates to:
  /// **'날짜를 선택해 주세요.'**
  String get errorDateRequired;

  /// No description provided for @errorTypeRequired.
  ///
  /// In ko, this message translates to:
  /// **'유형을 선택해 주세요.'**
  String get errorTypeRequired;

  /// No description provided for @errorCategoryRequired.
  ///
  /// In ko, this message translates to:
  /// **'카테고리를 선택해 주세요.'**
  String get errorCategoryRequired;

  /// No description provided for @errorPaymentMethodRequired.
  ///
  /// In ko, this message translates to:
  /// **'지출 수단을 선택해 주세요.'**
  String get errorPaymentMethodRequired;

  /// No description provided for @errorSaveFailed.
  ///
  /// In ko, this message translates to:
  /// **'저장에 실패했습니다.'**
  String get errorSaveFailed;

  /// No description provided for @errorMissingEditId.
  ///
  /// In ko, this message translates to:
  /// **'수정할 항목 ID가 없습니다.'**
  String get errorMissingEditId;

  /// No description provided for @errorEditItemNotFound.
  ///
  /// In ko, this message translates to:
  /// **'수정할 항목을 찾지 못했어요.'**
  String get errorEditItemNotFound;

  /// No description provided for @errorUpdateFailed.
  ///
  /// In ko, this message translates to:
  /// **'수정 중 오류가 발생했습니다.'**
  String get errorUpdateFailed;

  /// No description provided for @errorMissingDeleteId.
  ///
  /// In ko, this message translates to:
  /// **'삭제할 항목 ID가 없습니다.'**
  String get errorMissingDeleteId;

  /// No description provided for @errorDeleteItemNotFound.
  ///
  /// In ko, this message translates to:
  /// **'삭제할 항목을 찾지 못했어요.'**
  String get errorDeleteItemNotFound;

  /// No description provided for @errorDeleteFailed.
  ///
  /// In ko, this message translates to:
  /// **'삭제 중 오류가 발생했습니다.'**
  String get errorDeleteFailed;

  /// No description provided for @deleteRecordConfirm.
  ///
  /// In ko, this message translates to:
  /// **'삭제하면 기록을 다시 복구할 수 없어요. 정말로 삭제할까요?'**
  String get deleteRecordConfirm;

  /// No description provided for @deleteAssetConfirm.
  ///
  /// In ko, this message translates to:
  /// **'삭제하면 자산을 다시 복구할 수 없어요. 정말로 삭제할까요?'**
  String get deleteAssetConfirm;

  /// No description provided for @errorAssetDeleteNotFound.
  ///
  /// In ko, this message translates to:
  /// **'삭제할 자산을 찾지 못했어요.'**
  String get errorAssetDeleteNotFound;

  /// No description provided for @recordDetailTitle.
  ///
  /// In ko, this message translates to:
  /// **'기록 상세'**
  String get recordDetailTitle;

  /// No description provided for @fieldDate.
  ///
  /// In ko, this message translates to:
  /// **'날짜'**
  String get fieldDate;

  /// No description provided for @fieldAmount.
  ///
  /// In ko, this message translates to:
  /// **'금액'**
  String get fieldAmount;

  /// No description provided for @fieldType.
  ///
  /// In ko, this message translates to:
  /// **'유형'**
  String get fieldType;

  /// No description provided for @fieldCategory.
  ///
  /// In ko, this message translates to:
  /// **'카테고리'**
  String get fieldCategory;

  /// No description provided for @fieldMemo.
  ///
  /// In ko, this message translates to:
  /// **'메모'**
  String get fieldMemo;

  /// No description provided for @memoEmptyPlaceholderEdit.
  ///
  /// In ko, this message translates to:
  /// **'기존 메모가 없어요. 내용을 추가해 보세요.'**
  String get memoEmptyPlaceholderEdit;

  /// No description provided for @addRecordTitle.
  ///
  /// In ko, this message translates to:
  /// **'기록 추가'**
  String get addRecordTitle;

  /// No description provided for @actionAdd.
  ///
  /// In ko, this message translates to:
  /// **'추가하기'**
  String get actionAdd;

  /// No description provided for @viewCalendar.
  ///
  /// In ko, this message translates to:
  /// **'달력'**
  String get viewCalendar;

  /// No description provided for @viewList.
  ///
  /// In ko, this message translates to:
  /// **'목록'**
  String get viewList;

  /// No description provided for @typeIncome.
  ///
  /// In ko, this message translates to:
  /// **'수입'**
  String get typeIncome;

  /// No description provided for @typeExpense.
  ///
  /// In ko, this message translates to:
  /// **'지출'**
  String get typeExpense;

  /// No description provided for @summaryTotal.
  ///
  /// In ko, this message translates to:
  /// **'합계'**
  String get summaryTotal;

  /// No description provided for @addShort.
  ///
  /// In ko, this message translates to:
  /// **'+ 추가'**
  String get addShort;

  /// No description provided for @memoInputPlaceholder.
  ///
  /// In ko, this message translates to:
  /// **'내용을 입력해주세요 (예: 퇴근길 버스비)'**
  String get memoInputPlaceholder;

  /// No description provided for @emptyMonthlyIncome.
  ///
  /// In ko, this message translates to:
  /// **'이번 달 수입 내역이 없어요'**
  String get emptyMonthlyIncome;

  /// No description provided for @totalIncomeLabel.
  ///
  /// In ko, this message translates to:
  /// **'총 수입 합계'**
  String get totalIncomeLabel;

  /// No description provided for @emptyMonthlyExpense.
  ///
  /// In ko, this message translates to:
  /// **'이번 달 지출 내역이 없어요'**
  String get emptyMonthlyExpense;

  /// No description provided for @totalExpenseLabel.
  ///
  /// In ko, this message translates to:
  /// **'총 지출 합계'**
  String get totalExpenseLabel;

  /// No description provided for @totalWithAmount.
  ///
  /// In ko, this message translates to:
  /// **'합계 {amount}'**
  String totalWithAmount(String amount);

  /// No description provided for @emptyDateRecords.
  ///
  /// In ko, this message translates to:
  /// **'해당 날짜에 등록된 내역이 없어요'**
  String get emptyDateRecords;

  /// No description provided for @favoriteAddFailed.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기 추가에 실패했습니다.'**
  String get favoriteAddFailed;

  /// No description provided for @selectFavoriteRecordTitle.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기에 추가할 내역 선택'**
  String get selectFavoriteRecordTitle;

  /// No description provided for @noSavedLedgerRecords.
  ///
  /// In ko, this message translates to:
  /// **'저장된 가계부 기록이 없어요'**
  String get noSavedLedgerRecords;

  /// No description provided for @favoriteTitle.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기'**
  String get favoriteTitle;

  /// No description provided for @noFavoriteRecords.
  ///
  /// In ko, this message translates to:
  /// **'즐겨찾기한 내역이 없어요'**
  String get noFavoriteRecords;

  /// No description provided for @deleteFavoritesConfirm.
  ///
  /// In ko, this message translates to:
  /// **'선택한 {count}개 항목을 즐겨찾기에서 삭제할까요?'**
  String deleteFavoritesConfirm(int count);

  /// No description provided for @expensePaymentMethodLabel.
  ///
  /// In ko, this message translates to:
  /// **'지출 수단'**
  String get expensePaymentMethodLabel;

  /// No description provided for @supportEmailBody.
  ///
  /// In ko, this message translates to:
  /// **'✍️ 오류 제보 및 문의 내용:\n\n\n\n----------------------------------\n💡 아래 정보는 오류 해결을 위한 기술 데이터로 오류 해결을 위해서만 사용됩니다.\n• 앱 버전: {appVersion}\n• OS 버전: {osVersion}\n• 기기명: {deviceModel}\n----------------------------------'**
  String supportEmailBody(String appVersion, String osVersion, String deviceModel);

  /// No description provided for @cannotOpenPageRetry.
  ///
  /// In ko, this message translates to:
  /// **'페이지를 열 수 없어요. 잠시 후 다시 시도해주세요.'**
  String get cannotOpenPageRetry;

  /// No description provided for @inquirySubject.
  ///
  /// In ko, this message translates to:
  /// **'[머니메이트] 문의하기'**
  String get inquirySubject;

  /// No description provided for @cannotOpenMailApp.
  ///
  /// In ko, this message translates to:
  /// **'메일 앱을 열 수 없어요. {email} 으로 문의해주세요.'**
  String cannotOpenMailApp(String email);

  /// No description provided for @sectionGeneral.
  ///
  /// In ko, this message translates to:
  /// **'일반'**
  String get sectionGeneral;

  /// No description provided for @notices.
  ///
  /// In ko, this message translates to:
  /// **'공지사항'**
  String get notices;

  /// No description provided for @sectionSettings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get sectionSettings;

  /// No description provided for @sectionSupport.
  ///
  /// In ko, this message translates to:
  /// **'고객지원'**
  String get sectionSupport;

  /// No description provided for @contactUs.
  ///
  /// In ko, this message translates to:
  /// **'문의하기'**
  String get contactUs;

  /// No description provided for @sectionTermsPolicy.
  ///
  /// In ko, this message translates to:
  /// **'약관 및 정책'**
  String get sectionTermsPolicy;

  /// No description provided for @privacyPolicy.
  ///
  /// In ko, this message translates to:
  /// **'개인정보처리방침'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In ko, this message translates to:
  /// **'이용약관'**
  String get termsOfService;

  /// No description provided for @openSourceLicenses.
  ///
  /// In ko, this message translates to:
  /// **'오픈소스 라이선스'**
  String get openSourceLicenses;

  /// No description provided for @appInfo.
  ///
  /// In ko, this message translates to:
  /// **'앱 정보'**
  String get appInfo;

  /// No description provided for @moreTabTitle.
  ///
  /// In ko, this message translates to:
  /// **'더보기'**
  String get moreTabTitle;

  /// No description provided for @reminderTitle.
  ///
  /// In ko, this message translates to:
  /// **'기록 리마인드'**
  String get reminderTitle;

  /// No description provided for @reminderSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'설정한 시간에 오늘 기록을 잊지 않도록 알려드려요'**
  String get reminderSubtitle;

  /// No description provided for @reminderWeekdayLabel.
  ///
  /// In ko, this message translates to:
  /// **'알림 요일'**
  String get reminderWeekdayLabel;

  /// No description provided for @reminderTimeLabel.
  ///
  /// In ko, this message translates to:
  /// **'알림 시간'**
  String get reminderTimeLabel;

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In ko, this message translates to:
  /// **'오늘 가계부 작성하셨나요?'**
  String get reminderNotificationTitle;

  /// No description provided for @reminderBody1.
  ///
  /// In ko, this message translates to:
  /// **'1분만 투자해서 가계부 쓰고, 소비 습관을 만들어보아요.'**
  String get reminderBody1;

  /// No description provided for @reminderBody2.
  ///
  /// In ko, this message translates to:
  /// **'잊기 전에 가계부에 적고 낭비된 돈이 없는지 찾아보세요.'**
  String get reminderBody2;

  /// No description provided for @reminderBody3.
  ///
  /// In ko, this message translates to:
  /// **'오늘 하루 지출, 잊기 전에 빠르게 정리하러 가기!'**
  String get reminderBody3;

  /// No description provided for @reminderBody4.
  ///
  /// In ko, this message translates to:
  /// **'지금 기록해두지 않으면 내일 또 같은 지출을 반복할지도 몰라요!'**
  String get reminderBody4;

  /// No description provided for @notificationDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'기록하는 습관 만들기'**
  String get notificationDialogTitle;

  /// No description provided for @notificationDialogBody.
  ///
  /// In ko, this message translates to:
  /// **'설정한 시간에 기록을 잊지 않도록 알려드려요.\n알림은 언제든지 설정에서 끌 수 있어요.'**
  String get notificationDialogBody;

  /// No description provided for @notificationDialogLater.
  ///
  /// In ko, this message translates to:
  /// **'다음에'**
  String get notificationDialogLater;

  /// No description provided for @notificationDialogAllow.
  ///
  /// In ko, this message translates to:
  /// **'알림 받기'**
  String get notificationDialogAllow;

  /// No description provided for @notificationOffTitle.
  ///
  /// In ko, this message translates to:
  /// **'알림 권한이 꺼져 있어요'**
  String get notificationOffTitle;

  /// No description provided for @notificationOffBody.
  ///
  /// In ko, this message translates to:
  /// **'설정에서 알림 권한을 켜야 리마인드를 받을 수 있어요.'**
  String get notificationOffBody;

  /// No description provided for @goToSettings.
  ///
  /// In ko, this message translates to:
  /// **'설정으로 이동'**
  String get goToSettings;

  /// No description provided for @assetTypeStock.
  ///
  /// In ko, this message translates to:
  /// **'주식'**
  String get assetTypeStock;

  /// No description provided for @assetTypeCash.
  ///
  /// In ko, this message translates to:
  /// **'현금'**
  String get assetTypeCash;

  /// No description provided for @assetTypeRealEstate.
  ///
  /// In ko, this message translates to:
  /// **'부동산'**
  String get assetTypeRealEstate;

  /// No description provided for @assetTypeCrypto.
  ///
  /// In ko, this message translates to:
  /// **'가상화폐'**
  String get assetTypeCrypto;

  /// No description provided for @assetTypeSavings.
  ///
  /// In ko, this message translates to:
  /// **'예적금'**
  String get assetTypeSavings;

  /// No description provided for @assetTypeCommodity.
  ///
  /// In ko, this message translates to:
  /// **'원자재'**
  String get assetTypeCommodity;

  /// No description provided for @assetTypeOther.
  ///
  /// In ko, this message translates to:
  /// **'기타'**
  String get assetTypeOther;

  /// No description provided for @hintStockName.
  ///
  /// In ko, this message translates to:
  /// **'삼성전자, S&P500 ETF 등'**
  String get hintStockName;

  /// No description provided for @hintCashName.
  ///
  /// In ko, this message translates to:
  /// **'현금, 달러, 비상금 등'**
  String get hintCashName;

  /// No description provided for @hintRealEstateName.
  ///
  /// In ko, this message translates to:
  /// **'보증금, 상가 등'**
  String get hintRealEstateName;

  /// No description provided for @hintCryptoName.
  ///
  /// In ko, this message translates to:
  /// **'비트코인, 이더리움 등'**
  String get hintCryptoName;

  /// No description provided for @hintSavingsName.
  ///
  /// In ko, this message translates to:
  /// **'주택 청약, 청년미래적금 등'**
  String get hintSavingsName;

  /// No description provided for @hintCommodityName.
  ///
  /// In ko, this message translates to:
  /// **'금, 은, 원유 등'**
  String get hintCommodityName;

  /// No description provided for @hintOtherName.
  ///
  /// In ko, this message translates to:
  /// **'각종 포인트 등'**
  String get hintOtherName;

  /// No description provided for @whatAssetType.
  ///
  /// In ko, this message translates to:
  /// **'어떤 종류의 자산인가요?'**
  String get whatAssetType;

  /// No description provided for @selectAssetType.
  ///
  /// In ko, this message translates to:
  /// **'자산 유형 선택'**
  String get selectAssetType;

  /// No description provided for @enterAssetInfo.
  ///
  /// In ko, this message translates to:
  /// **'자산 정보를 입력해주세요'**
  String get enterAssetInfo;

  /// No description provided for @assetNameLabel.
  ///
  /// In ko, this message translates to:
  /// **'자산명'**
  String get assetNameLabel;

  /// No description provided for @currentAmountLabel.
  ///
  /// In ko, this message translates to:
  /// **'현재 금액'**
  String get currentAmountLabel;

  /// No description provided for @portfolioManagementLabel.
  ///
  /// In ko, this message translates to:
  /// **'포트폴리오 관리'**
  String get portfolioManagementLabel;

  /// No description provided for @includeInPortfolioTitle.
  ///
  /// In ko, this message translates to:
  /// **'포트폴리오에 포함'**
  String get includeInPortfolioTitle;

  /// No description provided for @includeInPortfolioSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'목표 비율 차트에 반영돼요'**
  String get includeInPortfolioSubtitle;

  /// No description provided for @excludeFromPortfolioTitle.
  ///
  /// In ko, this message translates to:
  /// **'포트폴리오에서 제외'**
  String get excludeFromPortfolioTitle;

  /// No description provided for @excludeFromPortfolioSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'자산 총액에는 포함되지만 비율 계산에서 빠져요'**
  String get excludeFromPortfolioSubtitle;

  /// No description provided for @editAssetTitle.
  ///
  /// In ko, this message translates to:
  /// **'자산 수정'**
  String get editAssetTitle;

  /// No description provided for @addAssetTitle.
  ///
  /// In ko, this message translates to:
  /// **'자산 추가'**
  String get addAssetTitle;

  /// No description provided for @addAssetTypeButton.
  ///
  /// In ko, this message translates to:
  /// **'{type} 자산 추가'**
  String addAssetTypeButton(String type);

  /// No description provided for @stockNameLabel.
  ///
  /// In ko, this message translates to:
  /// **'종목명'**
  String get stockNameLabel;

  /// No description provided for @unitPriceLabel.
  ///
  /// In ko, this message translates to:
  /// **'1주당 가격'**
  String get unitPriceLabel;

  /// No description provided for @sharesHeldLabel.
  ///
  /// In ko, this message translates to:
  /// **'보유 주수'**
  String get sharesHeldLabel;

  /// No description provided for @sharesHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 10 또는 10.5'**
  String get sharesHint;

  /// No description provided for @sharesUnit.
  ///
  /// In ko, this message translates to:
  /// **'주'**
  String get sharesUnit;

  /// No description provided for @currencyUnitSuffix.
  ///
  /// In ko, this message translates to:
  /// **'원'**
  String get currencyUnitSuffix;

  /// No description provided for @mainCurrencySettingTitle.
  ///
  /// In ko, this message translates to:
  /// **'주 통화'**
  String get mainCurrencySettingTitle;

  /// No description provided for @currencySettingScreenTitle.
  ///
  /// In ko, this message translates to:
  /// **'주 통화 설정'**
  String get currencySettingScreenTitle;

  /// No description provided for @currencySettingDescription.
  ///
  /// In ko, this message translates to:
  /// **'새로 입력하는 항목부터 선택한 통화로 기록됩니다. 이미 저장된 기록은 원래 통화 그대로 유지됩니다.'**
  String get currencySettingDescription;

  /// No description provided for @currencyNameKrw.
  ///
  /// In ko, this message translates to:
  /// **'대한민국 원'**
  String get currencyNameKrw;

  /// No description provided for @currencyNameUsd.
  ///
  /// In ko, this message translates to:
  /// **'미국 달러'**
  String get currencyNameUsd;

  /// No description provided for @currencyNameJpy.
  ///
  /// In ko, this message translates to:
  /// **'일본 엔'**
  String get currencyNameJpy;

  /// No description provided for @currencyNameEur.
  ///
  /// In ko, this message translates to:
  /// **'유로'**
  String get currencyNameEur;

  /// No description provided for @currencyNameCny.
  ///
  /// In ko, this message translates to:
  /// **'중국 위안'**
  String get currencyNameCny;

  /// No description provided for @currencyNameGbp.
  ///
  /// In ko, this message translates to:
  /// **'영국 파운드'**
  String get currencyNameGbp;

  /// No description provided for @currencyNameHkd.
  ///
  /// In ko, this message translates to:
  /// **'홍콩 달러'**
  String get currencyNameHkd;

  /// No description provided for @sharesWithUnit.
  ///
  /// In ko, this message translates to:
  /// **'{shares}주'**
  String sharesWithUnit(String shares);

  /// No description provided for @amountWithWonSuffix.
  ///
  /// In ko, this message translates to:
  /// **'{amount}원'**
  String amountWithWonSuffix(String amount);

  /// No description provided for @evaluatedAmountLabel.
  ///
  /// In ko, this message translates to:
  /// **'평가금액'**
  String get evaluatedAmountLabel;

  /// No description provided for @categoryNotInPortfolio.
  ///
  /// In ko, this message translates to:
  /// **'{category} 카테고리가 포트폴리오에 없습니다'**
  String categoryNotInPortfolio(String category);

  /// No description provided for @addCategoryInPortfolioSettings.
  ///
  /// In ko, this message translates to:
  /// **'포트폴리오 설정에서 카테고리를 추가해주세요'**
  String get addCategoryInPortfolioSettings;

  /// No description provided for @portfolioSettingsLabel.
  ///
  /// In ko, this message translates to:
  /// **'포트폴리오 설정'**
  String get portfolioSettingsLabel;

  /// No description provided for @innerRatioLabel.
  ///
  /// In ko, this message translates to:
  /// **'{category} 내 비중'**
  String innerRatioLabel(String category);

  /// No description provided for @overallRatioLabel.
  ///
  /// In ko, this message translates to:
  /// **'전체 자산 내 비중'**
  String get overallRatioLabel;

  /// No description provided for @assetDetailTitle.
  ///
  /// In ko, this message translates to:
  /// **'자산 상세'**
  String get assetDetailTitle;

  /// No description provided for @includedInPortfolio.
  ///
  /// In ko, this message translates to:
  /// **'포트폴리오 포함'**
  String get includedInPortfolio;

  /// No description provided for @excludedFromPortfolio.
  ///
  /// In ko, this message translates to:
  /// **'포트폴리오 제외'**
  String get excludedFromPortfolio;

  /// No description provided for @excludedFromTargetCalc.
  ///
  /// In ko, this message translates to:
  /// **'목표 비율 계산에서 제외돼요'**
  String get excludedFromTargetCalc;

  /// No description provided for @innerRatioWithValue.
  ///
  /// In ko, this message translates to:
  /// **'{category} 내 비중 {ratio}%'**
  String innerRatioWithValue(String category, String ratio);

  /// No description provided for @assetListLabel.
  ///
  /// In ko, this message translates to:
  /// **'자산 목록'**
  String get assetListLabel;

  /// No description provided for @setupPortfolioTitle.
  ///
  /// In ko, this message translates to:
  /// **'포트폴리오를 설정해보세요'**
  String get setupPortfolioTitle;

  /// No description provided for @setupPortfolioBody.
  ///
  /// In ko, this message translates to:
  /// **'목표 비율을 설정하면 자산 배분 현황을\n한눈에 확인할 수 있어요'**
  String get setupPortfolioBody;

  /// No description provided for @setupPortfolioButton.
  ///
  /// In ko, this message translates to:
  /// **'포트폴리오 설정하기'**
  String get setupPortfolioButton;

  /// No description provided for @totalAssetsLabel.
  ///
  /// In ko, this message translates to:
  /// **'총 자산'**
  String get totalAssetsLabel;

  /// No description provided for @noAssetsYet.
  ///
  /// In ko, this message translates to:
  /// **'아직 등록된 자산이 없어요'**
  String get noAssetsYet;

  /// No description provided for @addFirstAssetBody.
  ///
  /// In ko, this message translates to:
  /// **'첫 자산을 추가하고\n포트폴리오를 한눈에 확인해 보세요'**
  String get addFirstAssetBody;

  /// No description provided for @addAssetButton.
  ///
  /// In ko, this message translates to:
  /// **'자산 추가하기'**
  String get addAssetButton;

  /// No description provided for @portfolioCompositionLabel.
  ///
  /// In ko, this message translates to:
  /// **'포트폴리오 구성'**
  String get portfolioCompositionLabel;

  /// No description provided for @setTargetRatioButton.
  ///
  /// In ko, this message translates to:
  /// **'목표 비율 설정'**
  String get setTargetRatioButton;

  /// No description provided for @actualRatioLabel.
  ///
  /// In ko, this message translates to:
  /// **'실제 비율'**
  String get actualRatioLabel;

  /// No description provided for @targetRatioWithValue.
  ///
  /// In ko, this message translates to:
  /// **'목표 {value}%'**
  String targetRatioWithValue(String value);

  /// No description provided for @ratioActualPrefix.
  ///
  /// In ko, this message translates to:
  /// **'실제 '**
  String get ratioActualPrefix;

  /// No description provided for @ratioTargetPrefix.
  ///
  /// In ko, this message translates to:
  /// **'목표 '**
  String get ratioTargetPrefix;

  /// No description provided for @includedTargetTotalLabel.
  ///
  /// In ko, this message translates to:
  /// **'포함 유형 목표 합계'**
  String get includedTargetTotalLabel;

  /// No description provided for @adjustmentNeeded.
  ///
  /// In ko, this message translates to:
  /// **'조정 필요'**
  String get adjustmentNeeded;

  /// No description provided for @equalDistributionButton.
  ///
  /// In ko, this message translates to:
  /// **'균등 배분'**
  String get equalDistributionButton;

  /// No description provided for @actualRatioWithValue.
  ///
  /// In ko, this message translates to:
  /// **'실제 {value}%'**
  String actualRatioWithValue(String value);

  /// No description provided for @savePortfolioSettingsButton.
  ///
  /// In ko, this message translates to:
  /// **'포트폴리오 설정 저장'**
  String get savePortfolioSettingsButton;

  /// No description provided for @balanceTargetTo100.
  ///
  /// In ko, this message translates to:
  /// **'목표 합계를 100%로 맞춰주세요.'**
  String get balanceTargetTo100;

  /// No description provided for @portfolioSaveSuccess.
  ///
  /// In ko, this message translates to:
  /// **'포트폴리오 목표 비율을 저장했습니다.'**
  String get portfolioSaveSuccess;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ko': return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
