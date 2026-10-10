import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/data/model/entities/statistics_preferences.dart';
import 'package:money_mate/l10n/app_localizations.dart';
import 'package:money_mate/ui/core/design_system/app_theme.dart';
import 'package:money_mate/ui/ledger/view_models/ledger_statistics_view_model.dart';
import 'package:money_mate/ui/ledger/widgets/ledger_statistics_screen.dart';

import 'statistics_test_fakes.dart';

final _now = DateTime(2026, 10, 10);

List<LedgerEntry> _sampleRecords() => [
  for (var offset = 0; offset < 14; offset++) ...[
    statisticsTestEntry(
      type: LedgerRecordType.income,
      amount: 3000000 + offset * 10000,
      date: DateTime(2026, 10 - offset, 5),
      category: '월급',
    ),
    statisticsTestEntry(
      type: LedgerRecordType.expense,
      amount: 450000 + offset * 3000,
      date: DateTime(2026, 10 - offset, 7),
      category: '식비',
    ),
    statisticsTestEntry(
      type: LedgerRecordType.expense,
      amount: 150000,
      date: DateTime(2026, 10 - offset, 9),
      category: '교통',
    ),
  ],
  statisticsTestEntry(
    type: LedgerRecordType.expense,
    amount: 1999,
    date: DateTime(2026, 10, 3),
    category: '쇼핑',
    currency: 'USD',
  ),
];

Future<FakeStatisticsPreferencesRepository> _pumpScreen(
  WidgetTester tester, {
  Locale locale = const Locale('ko', 'KR'),
  ThemeMode themeMode = ThemeMode.light,
  List<LedgerEntry>? records,
}) async {
  Intl.defaultLocale = locale.toString();
  final preferences = FakeStatisticsPreferencesRepository();
  final viewModel = LedgerStatisticsViewModel(
    repository: FakeLedgerRecordRepository(records ?? _sampleRecords()),
    preferencesRepository: preferences,
    now: () => _now,
  );

  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      home: LedgerStatisticsScreen(
        initialMonth: DateTime(2026, 9, 1),
        viewModel: viewModel,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return preferences;
}

const _pieExpense = 'statistics-pie-expense';
const _trendExpense = 'statistics-trend-expense';
const _incomeExpense = 'statistics-income-expense';

/// 원형 카드와 누적 막대 카드는 제목이 같아서 카드 key로 찾는다.
Finder _inCard(String key, Finder finder) {
  return find.descendant(of: find.byKey(ValueKey(key)), matching: finder);
}

Future<void> _scrollToCard(WidgetTester tester, String key) async {
  await tester.scrollUntilVisible(find.byKey(ValueKey(key)), 200);
  await tester.pumpAndSettle();
}

Future<void> _scrollToText(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(find.text(text), 200);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('월간 통계 섹션이 맨 위에 있고, 가계부 탭에서 보던 달로 시작한다', (tester) async {
    await _pumpScreen(tester);

    expect(find.text('통계'), findsOneWidget);
    expect(find.text('KRW'), findsOneWidget);
    expect(find.text('USD'), findsOneWidget);
    expect(find.text('월간 통계'), findsOneWidget);
    expect(find.text('2026년 9월'), findsOneWidget);
    expect(_inCard(_pieExpense, find.text('카테고리별 지출')), findsOneWidget);
    // 9월 지출: 식비 453,000원 · 교통 150,000원
    expect(_inCard(_pieExpense, find.text('453,000원')), findsOneWidget);
    expect(_inCard(_pieExpense, find.text('75%')), findsOneWidget);
    expect(_inCard(_pieExpense, find.text('25%')), findsOneWidget);
    expect(_inCard(_pieExpense, find.byType(Checkbox)), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();
    expect(find.text('2026년 10월'), findsOneWidget);
  });

  testWidgets('최근 12개월 추이 섹션은 짧아진 카드 제목을 쓴다', (tester) async {
    await _pumpScreen(tester);

    await _scrollToText(tester, '최근 12개월 추이');
    await _scrollToCard(tester, _incomeExpense);
    expect(_inCard(_incomeExpense, find.text('수입·지출')), findsOneWidget);
    await _scrollToCard(tester, _trendExpense);
    expect(_inCard(_trendExpense, find.text('카테고리별 지출')), findsOneWidget);
    expect(find.text('월별 카테고리 지출 추이'), findsNothing);
  });

  testWidgets('원형 카드의 체크 해제는 저장되지만 추이 카드는 항상 전체 카테고리를 보여준다', (tester) async {
    final preferences = await _pumpScreen(tester);

    await tester.tap(_inCard(_pieExpense, find.text('교통')));
    await tester.pumpAndSettle();

    expect(preferences.stored.hiddenExpenseCategories, {'교통'});
    expect(_inCard(_pieExpense, find.text('-')), findsOneWidget);
    expect(_inCard(_pieExpense, find.text('100%')), findsOneWidget);

    await _scrollToCard(tester, _trendExpense);
    expect(
      _inCard(_trendExpense, find.text('2026년 10월 · 합계 600,000원')),
      findsOneWidget,
    );
    expect(_inCard(_trendExpense, find.byType(Checkbox)), findsNothing);
    // 상세 목록과 범례 양쪽에 교통이 보인다.
    expect(_inCard(_trendExpense, find.text('교통')), findsNWidgets(2));
  });

  testWidgets('누적 막대를 탭하면 그 카드의 선택 달만 바뀐다 (영어·다크 모드, 막대 추이)', (tester) async {
    final preferences = await _pumpScreen(
      tester,
      locale: const Locale('en', 'US'),
      themeMode: ThemeMode.dark,
    );

    await _scrollToCard(tester, _incomeExpense);
    await tester.tap(_inCard(_incomeExpense, find.byTooltip('Bar')));
    await tester.pumpAndSettle();
    expect(preferences.stored.trendChartType, StatisticsTrendChartType.bar);

    await _scrollToCard(tester, _trendExpense);
    final chart = _inCard(_trendExpense, find.byType(GestureDetector)).first;
    await tester.ensureVisible(chart);
    await tester.pumpAndSettle();
    final rect = tester.getRect(chart);
    await tester.tapAt(Offset(rect.left + 60, rect.center.dy));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      _inCard(_trendExpense, find.textContaining('11/2025')),
      findsOneWidget,
    );
  });

  testWidgets('기록이 없으면 빈 상태 문구를 표시한다', (tester) async {
    await _pumpScreen(tester, records: const []);

    expect(find.text('이 달의 지출 기록이 없습니다.'), findsOneWidget);
    expect(find.text('KRW'), findsNothing);
    await _scrollToText(tester, '최근 12개월간 기록이 없습니다.');
    await _scrollToText(tester, '최근 12개월간 지출 기록이 없습니다.');
  });
}
