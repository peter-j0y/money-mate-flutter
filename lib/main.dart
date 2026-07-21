import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:money_mate/firebase_options.dart';
import 'package:money_mate/ui/ledger/widgets/add_ledger_record_screen.dart';
import 'package:money_mate/ui/asset/screen/assets_tab_screen.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_tab_screen.dart';
import 'package:money_mate/ui/core/bottom_navigation_bar.dart';
import 'package:money_mate/ui/core/keyboard_done_bar.dart';
import 'package:money_mate/ui/more/screen/more_tab_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  final packageInfo = await PackageInfo.fromPlatform();
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
      title: 'Money Mate',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: const Locale('ko', 'KR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
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
