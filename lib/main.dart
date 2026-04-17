import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:money_mate/ui/ledger/widgets/add_ledger_record_screen.dart';
import 'package:money_mate/ui/asset/screen/assets_tab_screen.dart';
import 'package:money_mate/ui/core/design_system/design_system.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_tab_screen.dart';
import 'package:money_mate/ui/core/bottom_navigation_bar.dart';

void main() {
  runApp(const MoneyMateApp());
}

class MoneyMateApp extends StatelessWidget {
  const MoneyMateApp({super.key});

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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
      KeyedSubtree(
        key: ValueKey('more-tab-${_tabRefreshVersion[2]}'),
        child: const _TabPage(title: '설정', subtitle: '설정 및 계정 관리'),
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

class _TabPage extends StatelessWidget {
  const _TabPage({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: context.appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: context.appColors.textSecondary),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.appColors.border),
              ),
              child: const Text(
                'Figma 디자인 값을 연결해 픽셀 단위로 맞출 준비가 되어 있습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.hexFF334155,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
