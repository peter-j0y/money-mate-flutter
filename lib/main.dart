import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:money_mate/data/local/app_database.dart';
import 'package:money_mate/data/model/entities/currency.dart';
import 'package:money_mate/data/repositories/app_settings_repository.dart';
import 'package:money_mate/data/repositories/app_settings_repository_impl.dart';
import 'package:money_mate/data/repositories/reminder_repository.dart';
import 'package:money_mate/data/repositories/reminder_repository_impl.dart';
import 'package:money_mate/firebase_options.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/currency/current_currency.dart';
import 'package:money_mate/ui/ledger/widgets/add_ledger_record_screen.dart';
import 'package:money_mate/ui/asset/screen/assets_tab_screen.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_tab_screen.dart';
import 'package:money_mate/ui/core/bottom_navigation_bar.dart';
import 'package:money_mate/ui/core/keyboard_done_bar.dart';
import 'package:money_mate/ui/core/notification_permission_dialog.dart';
import 'package:money_mate/ui/more/screen/more_tab_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// 앱 지원 언어(ko/en) 외의 기기 언어는 영어로 노출한다.
Locale _resolveAppLocale(Locale? deviceLocale) {
  return deviceLocale?.languageCode == 'ko'
      ? const Locale('ko', 'KR')
      : const Locale('en', 'US');
}

/// 저장된 주 통화가 없는 경우(최초 실행)의 기본값을 정한다.
/// 기존 기록이 있는 사용자는 전부 KRW로 쌓인 데이터이므로 지역과 무관하게 KRW를 유지하고,
/// 기록이 전혀 없는 신규 설치에서만 기기 지역을 바탕으로 통화를 추론한다.
Future<CurrencyCode> _resolveInitialMainCurrency(
  AppSettingsRepository settingsRepository,
) async {
  final stored = await settingsRepository.getMainCurrency();
  if (stored != null) {
    return stored;
  }

  final hasExistingData = await AppDatabase().hasAnyLedgerOrAssetRecords();
  final inferred =
      hasExistingData
          ? CurrencyCode.krw
          : defaultCurrencyForCountryCode(
            PlatformDispatcher.instance.locale.countryCode,
          );

  await settingsRepository.setMainCurrency(inferred);
  return inferred;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    !kDebugMode,
  );
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  final packageInfo = await PackageInfo.fromPlatform();
  Intl.defaultLocale =
      _resolveAppLocale(PlatformDispatcher.instance.locale).toString();
  CurrentCurrency.code = await _resolveInitialMainCurrency(
    AppSettingsRepositoryImpl(),
  );
  final app = MoneyMateApp(appVersion: packageInfo.version);

  runApp(app);
}

class MoneyMateApp extends StatelessWidget {
  const MoneyMateApp({super.key, required this.appVersion});

  final String appVersion;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Where is My Money',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        final resolved = _resolveAppLocale(deviceLocale);
        Intl.defaultLocale = resolved.toString();
        return resolved;
      },
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(maxScaleFactor: 1.3),
          ),
          child: KeyboardDoneBar(child: child!),
        );
      },
      home: HomeScreen(appVersion: appVersion),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.appVersion});

  final String appVersion;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  DateTime _selectedLedgerDate = DateTime.now();
  late final List<int> _tabRefreshVersion;
  final AppSettingsRepository _appSettingsRepository =
      AppSettingsRepositoryImpl();
  final ReminderRepository _reminderRepository = ReminderRepositoryImpl();

  List<BottomNavTabItem> _tabs(AppLocalizations l10n) => [
    BottomNavTabItem(
      label: l10n.navLedger,
      icon: Icons.calendar_today_outlined,
    ),
    BottomNavTabItem(
      label: l10n.navAsset,
      icon: Icons.account_balance_wallet_outlined,
    ),
    BottomNavTabItem(label: l10n.navMore, icon: Icons.more_horiz_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabRefreshVersion = List<int>.filled(3, 0);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _maybeRequestNotificationPermission(),
    );
  }

  Future<void> _maybeRequestNotificationPermission() async {
    final alreadyRequested =
        await _appSettingsRepository.hasRequestedNotificationPermission();
    if (alreadyRequested || !mounted) return;

    final agreed = await NotificationPermissionDialog.show(context);
    var granted = false;
    if (agreed) {
      final status = await Permission.notification.request();
      granted = status.isGranted;
    }
    await _reminderRepository.setEnabled(granted);
    await _appSettingsRepository.setNotificationPermissionRequested();
  }

  void _onBottomTabTap(int index) {
    setState(() {
      if (_currentIndex == index) {
        _tabRefreshVersion[index] += 1;
        return;
      }
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = [
      LedgerTabScreen(
        key: ValueKey('ledger-tab-${_tabRefreshVersion[0]}'),
        selectedDate: _selectedLedgerDate,
        onSelectedDateChanged: (date) => _selectedLedgerDate = date,
      ),
      AssetsTabScreen(key: ValueKey('assets-tab-${_tabRefreshVersion[1]}')),
      MoreTabScreen(
        key: ValueKey('more-tab-${_tabRefreshVersion[2]}'),
        appVersion: widget.appVersion,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: MoneyMateBottomNavigationBar(
        tabs: _tabs(l10n),
        currentIndex: _currentIndex,
        onTap: _onBottomTabTap,
      ),
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder:
                          (context) => AddLedgerRecordScreen(
                            initialDate: _selectedLedgerDate,
                          ),
                    ),
                  );
                },
                backgroundColor: context.appColors.primary,
                elevation: 0,
                focusElevation: 0,
                hoverElevation: 0,
                highlightElevation: 0,
                disabledElevation: 0,
                shape: const CircleBorder(),
                child: Icon(
                  Icons.add,
                  color: context.appColors.inverseText,
                  size: 28,
                ),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
