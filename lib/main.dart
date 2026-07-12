import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:money_mate/data/model/entities/app_theme_mode.dart';
import 'package:money_mate/data/repositories/app_settings_repository.dart';
import 'package:money_mate/data/repositories/app_settings_repository_impl.dart';
import 'package:money_mate/ui/ledger/widgets/add_ledger_record_screen.dart';
import 'package:money_mate/ui/asset/screen/assets_tab_screen.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_tab_screen.dart';
import 'package:money_mate/ui/core/bottom_navigation_bar.dart';
import 'package:money_mate/ui/more/screen/more_tab_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final packageInfo = await PackageInfo.fromPlatform();
  runApp(MoneyMateApp(appVersion: packageInfo.version));
}

class MoneyMateApp extends StatefulWidget {
  const MoneyMateApp({super.key, required this.appVersion});

  final String appVersion;

  @override
  State<MoneyMateApp> createState() => _MoneyMateAppState();
}

class _MoneyMateAppState extends State<MoneyMateApp> {
  final AppSettingsRepository _appSettingsRepository =
      AppSettingsRepositoryImpl();

  AppThemeMode _appThemeMode = AppThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final themeMode = await _appSettingsRepository.getThemeMode();
    if (!mounted) return;
    setState(() => _appThemeMode = themeMode);
  }

  Future<void> _setAppThemeMode(AppThemeMode themeMode) async {
    setState(() => _appThemeMode = themeMode);
    await _appSettingsRepository.setThemeMode(themeMode);
  }

  ThemeMode get _themeMode {
    switch (_appThemeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Money Mate',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      locale: const Locale('ko', 'KR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      home: HomeScreen(
        appThemeMode: _appThemeMode,
        onThemeModeChanged: _setAppThemeMode,
        appVersion: widget.appVersion,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.appThemeMode,
    required this.onThemeModeChanged,
    required this.appVersion,
  });

  final AppThemeMode appThemeMode;
  final ValueChanged<AppThemeMode> onThemeModeChanged;
  final String appVersion;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  DateTime _selectedLedgerDate = DateTime.now();
  late final List<int> _tabRefreshVersion;

  final List<BottomNavTabItem> _tabs = const [
    BottomNavTabItem(label: '가계부', icon: Icons.calendar_today_outlined),
    BottomNavTabItem(label: '자산', icon: Icons.account_balance_wallet_outlined),
    BottomNavTabItem(label: '더보기', icon: Icons.more_horiz_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabRefreshVersion = List<int>.filled(_tabs.length, 0);
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
    final pages = [
      LedgerTabScreen(
        key: ValueKey('ledger-tab-${_tabRefreshVersion[0]}'),
        selectedDate: _selectedLedgerDate,
        onSelectedDateChanged: (date) => _selectedLedgerDate = date,
      ),
      AssetsTabScreen(key: ValueKey('assets-tab-${_tabRefreshVersion[1]}')),
      MoreTabScreen(
        key: ValueKey('more-tab-${_tabRefreshVersion[2]}'),
        themeMode: widget.appThemeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
        appVersion: widget.appVersion,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: MoneyMateBottomNavigationBar(
        tabs: _tabs,
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
                child: Icon(Icons.add, color: context.appColors.inverseText, size: 28),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
