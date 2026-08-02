// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get navLedger => '가계부';

  @override
  String get navAsset => '자산';

  @override
  String get navMore => '더보기';

  @override
  String get commonCancel => '취소';

  @override
  String get commonDelete => '삭제';

  @override
  String get commonDone => '완료';

  @override
  String get commonUpdate => '수정하기';

  @override
  String get weekdayMon => '월';

  @override
  String get weekdayTue => '화';

  @override
  String get weekdayWed => '수';

  @override
  String get weekdayThu => '목';

  @override
  String get weekdayFri => '금';

  @override
  String get weekdaySat => '토';

  @override
  String get weekdaySun => '일';

  @override
  String dateWithWeekday(int year, int month, int day, String weekday) {
    return '$year년 $month월 $day일 ($weekday)';
  }

  @override
  String monthDayWithWeekday(int month, int day, String weekday) {
    return '$month월 $day일 ($weekday)';
  }

  @override
  String yearMonth(int year, int month) {
    return '$year년 $month월';
  }

  @override
  String get paymentMethodCash => '현금';

  @override
  String get paymentMethodCreditCard => '신용카드';

  @override
  String get paymentMethodDebitCard => '체크카드';

  @override
  String get paymentMethodBankTransfer => '계좌이체';

  @override
  String get paymentMethodPoints => '포인트';

  @override
  String get paymentMethodOther => '기타';

  @override
  String get categoryIncomeSalary => '월급';

  @override
  String get categoryIncomeSideJob => '부업';

  @override
  String get categoryIncomeBonus => '보너스';

  @override
  String get categoryIncomeAllowance => '용돈';

  @override
  String get categoryIncomeInterestDividend => '이자/배당';

  @override
  String get categoryOther => '기타';

  @override
  String get categoryExpenseFood => '식비';

  @override
  String get categoryExpenseTransport => '교통';

  @override
  String get categoryExpenseShopping => '쇼핑';

  @override
  String get categoryExpenseCultureHobby => '문화/취미';

  @override
  String get categoryExpenseHousingUtilities => '주거/통신';

  @override
  String get categoryExpenseMedicalHealth => '의료/건강';

  @override
  String get categoryExpenseEducation => '교육';

  @override
  String get errorLedgerLoadFailed => '가계부 내역을 불러오는 중 오류가 발생했습니다.';

  @override
  String get errorDeleteFailedRetry => '삭제 중 오류가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get errorFavoriteListLoadFailed => '즐겨찾기 목록을 불러오는 중 오류가 발생했습니다.';

  @override
  String get errorAmountMustBePositive => '금액은 0원보다 커야 합니다.';

  @override
  String get errorSaveFailedRetry => '저장 중 오류가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get errorLoadLedgerRecordsFailed => '가계부 기록을 불러오지 못했습니다. 다시 시도해 주세요.';

  @override
  String errorFavoriteLimitExceeded(int count) {
    return '즐겨찾기는 최대 $count개까지 저장할 수 있어요.';
  }

  @override
  String get errorAddFavoriteFailed => '즐겨찾기 추가 중 오류가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get errorAssetSaveFailed => '자산 저장 중 오류가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get errorAssetNotFound => '수정할 자산을 찾지 못했어요.';

  @override
  String get errorAssetUpdateFailed => '자산 수정 중 오류가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get errorAssetNameRequired => '자산명을 입력해 주세요.';

  @override
  String get errorSharesMustBePositive => '주수는 0보다 커야 합니다.';

  @override
  String get errorDateRequired => '날짜를 선택해 주세요.';

  @override
  String get errorTypeRequired => '유형을 선택해 주세요.';

  @override
  String get errorCategoryRequired => '카테고리를 선택해 주세요.';

  @override
  String get errorPaymentMethodRequired => '지출 수단을 선택해 주세요.';

  @override
  String get errorSaveFailed => '저장에 실패했습니다.';

  @override
  String get errorMissingEditId => '수정할 항목 ID가 없습니다.';

  @override
  String get errorEditItemNotFound => '수정할 항목을 찾지 못했어요.';

  @override
  String get errorUpdateFailed => '수정 중 오류가 발생했습니다.';

  @override
  String get errorMissingDeleteId => '삭제할 항목 ID가 없습니다.';

  @override
  String get errorDeleteItemNotFound => '삭제할 항목을 찾지 못했어요.';

  @override
  String get errorDeleteFailed => '삭제 중 오류가 발생했습니다.';

  @override
  String get deleteRecordConfirm => '삭제하면 기록을 다시 복구할 수 없어요. 정말로 삭제할까요?';

  @override
  String get deleteAssetConfirm => '삭제하면 자산을 다시 복구할 수 없어요. 정말로 삭제할까요?';

  @override
  String get errorAssetDeleteNotFound => '삭제할 자산을 찾지 못했어요.';

  @override
  String get recordDetailTitle => '기록 상세';

  @override
  String get fieldDate => '날짜';

  @override
  String get fieldAmount => '금액';

  @override
  String get fieldType => '유형';

  @override
  String get fieldCategory => '카테고리';

  @override
  String get fieldMemo => '메모';

  @override
  String get memoEmptyPlaceholderEdit => '기존 메모가 없어요. 내용을 추가해 보세요.';

  @override
  String get addRecordTitle => '기록 추가';

  @override
  String get actionAdd => '추가하기';

  @override
  String get viewCalendar => '달력';

  @override
  String get viewList => '목록';

  @override
  String get typeIncome => '수입';

  @override
  String get typeExpense => '지출';

  @override
  String get summaryTotal => '합계';

  @override
  String get addShort => '+ 추가';

  @override
  String get memoInputPlaceholder => '내용을 입력해주세요 (예: 퇴근길 버스비)';

  @override
  String get emptyMonthlyIncome => '이번 달 수입 내역이 없어요';

  @override
  String get totalIncomeLabel => '총 수입 합계';

  @override
  String get emptyMonthlyExpense => '이번 달 지출 내역이 없어요';

  @override
  String get totalExpenseLabel => '총 지출 합계';

  @override
  String totalWithAmount(String amount) {
    return '합계 $amount';
  }

  @override
  String get emptyDateRecords => '해당 날짜에 등록된 내역이 없어요';

  @override
  String get favoriteAddFailed => '즐겨찾기 추가에 실패했습니다.';

  @override
  String get selectFavoriteRecordTitle => '즐겨찾기에 추가할 내역 선택';

  @override
  String get noSavedLedgerRecords => '저장된 가계부 기록이 없어요';

  @override
  String get favoriteTitle => '즐겨찾기';

  @override
  String get noFavoriteRecords => '즐겨찾기한 내역이 없어요';

  @override
  String deleteFavoritesConfirm(int count) {
    return '선택한 $count개 항목을 즐겨찾기에서 삭제할까요?';
  }

  @override
  String get expensePaymentMethodLabel => '지출 수단';

  @override
  String supportEmailBody(String appVersion, String osVersion, String deviceModel) {
    return '✍️ 오류 제보 및 문의 내용:\n\n\n\n----------------------------------\n💡 아래 정보는 오류 해결을 위한 기술 데이터로 오류 해결을 위해서만 사용됩니다.\n• 앱 버전: $appVersion\n• OS 버전: $osVersion\n• 기기명: $deviceModel\n----------------------------------';
  }

  @override
  String get cannotOpenPageRetry => '페이지를 열 수 없어요. 잠시 후 다시 시도해주세요.';

  @override
  String get inquirySubject => '[머니메이트] 문의하기';

  @override
  String cannotOpenMailApp(String email) {
    return '메일 앱을 열 수 없어요. $email 으로 문의해주세요.';
  }

  @override
  String get sectionGeneral => '일반';

  @override
  String get notices => '공지사항';

  @override
  String get sectionNotification => '알림';

  @override
  String get sectionSupport => '고객지원';

  @override
  String get contactUs => '문의하기';

  @override
  String get sectionTermsPolicy => '약관 및 정책';

  @override
  String get privacyPolicy => '개인정보처리방침';

  @override
  String get termsOfService => '이용약관';

  @override
  String get openSourceLicenses => '오픈소스 라이선스';

  @override
  String get appInfo => '앱 정보';

  @override
  String get moreTabTitle => '더보기';

  @override
  String get reminderTitle => '기록 리마인드';

  @override
  String get reminderSubtitle => '설정한 시간에 오늘 기록을 잊지 않도록 알려드려요';

  @override
  String get reminderWeekdayLabel => '알림 요일';

  @override
  String get reminderTimeLabel => '알림 시간';

  @override
  String get reminderNotificationTitle => '오늘 가계부 작성하셨나요?';

  @override
  String get reminderBody1 => '1분만 투자해서 가계부 쓰고, 소비 습관을 만들어보아요.';

  @override
  String get reminderBody2 => '잊기 전에 가계부에 적고 낭비된 돈이 없는지 찾아보세요.';

  @override
  String get reminderBody3 => '오늘 하루 지출, 잊기 전에 빠르게 정리하러 가기!';

  @override
  String get reminderBody4 => '지금 기록해두지 않으면 내일 또 같은 지출을 반복할지도 몰라요!';

  @override
  String get notificationDialogTitle => '기록하는 습관 만들기';

  @override
  String get notificationDialogBody => '설정한 시간에 기록을 잊지 않도록 알려드려요.\n알림은 언제든지 설정에서 끌 수 있어요.';

  @override
  String get notificationDialogLater => '다음에';

  @override
  String get notificationDialogAllow => '알림 받기';

  @override
  String get notificationOffTitle => '알림 권한이 꺼져 있어요';

  @override
  String get notificationOffBody => '설정에서 알림 권한을 켜야 리마인드를 받을 수 있어요.';

  @override
  String get goToSettings => '설정으로 이동';

  @override
  String get assetTypeStock => '주식';

  @override
  String get assetTypeCash => '현금';

  @override
  String get assetTypeRealEstate => '부동산';

  @override
  String get assetTypeCrypto => '가상화폐';

  @override
  String get assetTypeSavings => '예적금';

  @override
  String get assetTypeCommodity => '원자재';

  @override
  String get assetTypeOther => '기타';

  @override
  String get hintStockName => '삼성전자, S&P500 ETF 등';

  @override
  String get hintCashName => '현금, 달러, 비상금 등';

  @override
  String get hintRealEstateName => '보증금, 상가 등';

  @override
  String get hintCryptoName => '비트코인, 이더리움 등';

  @override
  String get hintSavingsName => '주택 청약, 청년미래적금 등';

  @override
  String get hintCommodityName => '금, 은, 원유 등';

  @override
  String get hintOtherName => '각종 포인트 등';

  @override
  String get whatAssetType => '어떤 종류의 자산인가요?';

  @override
  String get selectAssetType => '자산 유형 선택';

  @override
  String get enterAssetInfo => '자산 정보를 입력해주세요';

  @override
  String get assetNameLabel => '자산명';

  @override
  String get currentAmountLabel => '현재 금액';

  @override
  String get portfolioManagementLabel => '포트폴리오 관리';

  @override
  String get includeInPortfolioTitle => '포트폴리오에 포함';

  @override
  String get includeInPortfolioSubtitle => '목표 비율 차트에 반영돼요';

  @override
  String get excludeFromPortfolioTitle => '포트폴리오에서 제외';

  @override
  String get excludeFromPortfolioSubtitle => '자산 총액에는 포함되지만 비율 계산에서 빠져요';

  @override
  String get editAssetTitle => '자산 수정';

  @override
  String get addAssetTitle => '자산 추가';

  @override
  String addAssetTypeButton(String type) {
    return '$type 자산 추가';
  }

  @override
  String get stockNameLabel => '종목명';

  @override
  String get unitPriceLabel => '1주당 가격';

  @override
  String get sharesHeldLabel => '보유 주수';

  @override
  String get sharesHint => '예: 10 또는 10.5';

  @override
  String get sharesUnit => '주';

  @override
  String get currencyUnitSuffix => '원';

  @override
  String sharesWithUnit(String shares) {
    return '$shares주';
  }

  @override
  String amountWithWonSuffix(String amount) {
    return '$amount원';
  }

  @override
  String get evaluatedAmountLabel => '평가금액';

  @override
  String categoryNotInPortfolio(String category) {
    return '$category 카테고리가 포트폴리오에 없습니다';
  }

  @override
  String get addCategoryInPortfolioSettings => '포트폴리오 설정에서 카테고리를 추가해주세요';

  @override
  String get portfolioSettingsLabel => '포트폴리오 설정';

  @override
  String innerRatioLabel(String category) {
    return '$category 내 비중';
  }

  @override
  String get overallRatioLabel => '전체 자산 내 비중';

  @override
  String get assetDetailTitle => '자산 상세';

  @override
  String get includedInPortfolio => '포트폴리오 포함';

  @override
  String get excludedFromPortfolio => '포트폴리오 제외';

  @override
  String get excludedFromTargetCalc => '목표 비율 계산에서 제외돼요';

  @override
  String innerRatioWithValue(String category, String ratio) {
    return '$category 내 비중 $ratio%';
  }

  @override
  String get assetListLabel => '자산 목록';

  @override
  String get setupPortfolioTitle => '포트폴리오를 설정해보세요';

  @override
  String get setupPortfolioBody => '목표 비율을 설정하면 자산 배분 현황을\n한눈에 확인할 수 있어요';

  @override
  String get setupPortfolioButton => '포트폴리오 설정하기';

  @override
  String get totalAssetsLabel => '총 자산';

  @override
  String get noAssetsYet => '아직 등록된 자산이 없어요';

  @override
  String get addFirstAssetBody => '첫 자산을 추가하고\n포트폴리오를 한눈에 확인해 보세요';

  @override
  String get addAssetButton => '자산 추가하기';

  @override
  String get portfolioCompositionLabel => '포트폴리오 구성';

  @override
  String get setTargetRatioButton => '목표 비율 설정';

  @override
  String get actualRatioLabel => '실제 비율';

  @override
  String targetRatioWithValue(String value) {
    return '목표 $value%';
  }

  @override
  String get ratioActualPrefix => '실제 ';

  @override
  String get ratioTargetPrefix => '목표 ';

  @override
  String get includedTargetTotalLabel => '포함 유형 목표 합계';

  @override
  String get adjustmentNeeded => '조정 필요';

  @override
  String get equalDistributionButton => '균등 배분';

  @override
  String actualRatioWithValue(String value) {
    return '실제 $value%';
  }

  @override
  String get savePortfolioSettingsButton => '포트폴리오 설정 저장';

  @override
  String get balanceTargetTo100 => '목표 합계를 100%로 맞춰주세요.';

  @override
  String get portfolioSaveSuccess => '포트폴리오 목표 비율을 저장했습니다.';
}
