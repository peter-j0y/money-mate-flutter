/// Firebase Analytics에 기록하는 화면 이름.
///
/// 라우트 이름(`RouteSettings.name`)으로도 쓰이므로, 화면을 push할 때
/// `settings: AnalyticsScreen.xxx.routeSettings`를 함께 넘기면
/// `AnalyticsRouteObserver`가 화면 진입을 자동으로 기록한다.
enum AnalyticsScreen {
  ledgerTab('ledger_tab'),
  assetsTab('assets_tab'),
  moreTab('more_tab'),
  addLedgerRecord('add_ledger_record'),
  ledgerRecordDetail('ledger_record_detail'),
  favoriteLedgerRecords('favorite_ledger_records'),
  addFavoriteLedgerRecord('add_favorite_ledger_record'),
  ledgerStatistics('ledger_statistics'),
  addAsset('add_asset'),
  editAsset('edit_asset'),
  assetDetail('asset_detail'),
  portfolioTargetSetting('portfolio_target_setting'),
  currencySetting('currency_setting');

  const AnalyticsScreen(this.screenName);

  final String screenName;
}

/// 주요 버튼 클릭 이벤트.
///
/// 이벤트 이름은 Firebase 제약(영문/숫자/밑줄, 40자 이하, `firebase_`·`google_`·`ga_`
/// 접두어 금지)을 지켜야 하며, 위반 시 오류 없이 이벤트가 버려지므로 이곳에서만 정의한다.
enum AnalyticsButton {
  ledgerAddFab('click_ledger_add_fab'),
  ledgerRecordSave('click_ledger_record_save'),
  ledgerRecordView('click_ledger_record_view'),
  favoriteRecordAdd('click_favorite_record_add'),
  ledgerStatistics('click_ledger_statistics'),
  ledgerListView('click_ledger_list_view'),
  assetAdd('click_asset_add'),
  assetSave('click_asset_save'),
  portfolioTargetSave('click_portfolio_target_save'),
  mainCurrencyChange('click_main_currency_change');

  const AnalyticsButton(this.eventName);

  final String eventName;
}
