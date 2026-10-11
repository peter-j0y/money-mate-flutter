import 'package:flutter_test/flutter_test.dart';
import 'package:money_mate/data/model/entities/currency.dart';
import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/data/model/entities/statistics_preferences.dart';
import 'package:money_mate/ui/ledger/view_models/ledger_statistics_view_model.dart';

import 'statistics_test_fakes.dart';

void main() {
  final now = DateTime(2026, 10, 10);

  group('buildMonthlyTrend', () {
    test('첫 기록 달부터 이번 달까지 표시하고 중간 빈 달은 0으로 채운다', () {
      final trend = LedgerStatisticsViewModel.buildMonthlyTrend(
        records: [
          statisticsTestEntry(
            type: LedgerRecordType.expense,
            amount: 1000,
            date: DateTime(2026, 7, 3),
          ),
          statisticsTestEntry(
            type: LedgerRecordType.income,
            amount: 5000,
            date: DateTime(2026, 9, 25),
          ),
        ],
        currency: CurrencyCode.krw,
        currentMonth: DateTime(2026, 10),
      );

      expect(trend.map((item) => item.month), [
        DateTime(2026, 7),
        DateTime(2026, 8),
        DateTime(2026, 9),
        DateTime(2026, 10),
      ]);
      expect(trend[0].expense, 1000);
      expect(trend[1].income, 0);
      expect(trend[1].expense, 0);
      expect(trend[2].income, 5000);
    });

    test('12개월을 넘는 기록은 포함하지 않고 최대 12개월만 만든다', () {
      final trend = LedgerStatisticsViewModel.buildMonthlyTrend(
        records: [
          statisticsTestEntry(
            type: LedgerRecordType.expense,
            amount: 1000,
            date: DateTime(2025, 1, 1),
          ),
          statisticsTestEntry(
            type: LedgerRecordType.expense,
            amount: 2000,
            date: DateTime(2025, 11, 1),
          ),
        ],
        currency: CurrencyCode.krw,
        currentMonth: DateTime(2026, 10),
      );

      expect(trend.length, 12);
      expect(trend.first.month, DateTime(2025, 11));
      expect(trend.first.expense, 2000);
    });

    test('다른 통화 기록은 합산하지 않는다', () {
      final trend = LedgerStatisticsViewModel.buildMonthlyTrend(
        records: [
          statisticsTestEntry(
            type: LedgerRecordType.expense,
            amount: 1000,
            date: DateTime(2026, 10, 1),
          ),
          statisticsTestEntry(
            type: LedgerRecordType.expense,
            amount: 999,
            date: DateTime(2026, 10, 2),
            currency: 'USD',
          ),
        ],
        currency: CurrencyCode.krw,
        currentMonth: DateTime(2026, 10),
      );

      expect(trend.single.expense, 1000);
    });

    test('선택 통화 기록이 없으면 빈 목록을 반환한다', () {
      final trend = LedgerStatisticsViewModel.buildMonthlyTrend(
        records: [
          statisticsTestEntry(
            type: LedgerRecordType.expense,
            amount: 999,
            date: DateTime(2026, 10, 2),
            currency: 'USD',
          ),
        ],
        currency: CurrencyCode.krw,
        currentMonth: DateTime(2026, 10),
      );

      expect(trend, isEmpty);
    });
  });

  group('buildCategoryTrend', () {
    test('월별·카테고리별로 합산하고 미정의 코드는 기타로, 기간 밖·다른 유형·다른 통화는 제외한다', () {
      final trend = LedgerStatisticsViewModel.buildCategoryTrend(
        records: [
          statisticsTestEntry(
            type: LedgerRecordType.expense,
            amount: 100,
            date: DateTime(2026, 9, 3),
            category: '식비',
          ),
          statisticsTestEntry(
            type: LedgerRecordType.expense,
            amount: 50,
            date: DateTime(2026, 9, 20),
            category: '식비',
          ),
          statisticsTestEntry(
            type: LedgerRecordType.expense,
            amount: 20,
            date: DateTime(2026, 10, 1),
            category: '예전카테고리',
          ),
          statisticsTestEntry(
            type: LedgerRecordType.expense,
            amount: 30,
            date: DateTime(2026, 10, 2),
            category: '기타',
          ),
          statisticsTestEntry(
            type: LedgerRecordType.expense,
            amount: 999,
            date: DateTime(2026, 7, 2),
            category: '식비',
          ),
          statisticsTestEntry(
            type: LedgerRecordType.expense,
            amount: 999,
            date: DateTime(2026, 10, 2),
            category: '식비',
            currency: 'USD',
          ),
          statisticsTestEntry(
            type: LedgerRecordType.income,
            amount: 9999,
            date: DateTime(2026, 10, 5),
            category: '월급',
          ),
        ],
        type: LedgerRecordType.expense,
        currency: CurrencyCode.krw,
        months: [DateTime(2026, 8), DateTime(2026, 9), DateTime(2026, 10)],
        knownCategories: const {'식비', '교통', '기타'},
      );

      expect(trend.map((item) => item.month), [
        DateTime(2026, 8),
        DateTime(2026, 9),
        DateTime(2026, 10),
      ]);
      expect(trend[0].amounts, isEmpty);
      expect(trend[1].amounts, {'식비': 150});
      expect(trend[2].amounts, {'기타': 50});
    });
  });

  test('percentOf는 정수로 반올림하고 합계가 0이면 0을 반환한다', () {
    expect(LedgerStatisticsViewModel.percentOf(1, 3), 33);
    expect(LedgerStatisticsViewModel.percentOf(2, 3), 67);
    expect(LedgerStatisticsViewModel.percentOf(5, 0), 0);
  });

  group('LedgerStatisticsViewModel', () {
    LedgerStatisticsViewModel createViewModel(
      List<LedgerEntry> records, {
      FakeStatisticsPreferencesRepository? preferences,
    }) {
      return LedgerStatisticsViewModel(
        repository: FakeLedgerRecordRepository(records),
        preferencesRepository:
            preferences ?? FakeStatisticsPreferencesRepository(),
        now: () => now,
      );
    }

    test('주 통화 기록이 없으면 기록이 있는 첫 통화를 기본 선택한다', () async {
      final viewModel = createViewModel([
        statisticsTestEntry(
          type: LedgerRecordType.expense,
          amount: 100,
          date: DateTime(2026, 10, 1),
          currency: 'USD',
        ),
      ]);
      viewModel.start(initialMonth: now, primary: CurrencyCode.krw);
      await pumpEventQueue();

      expect(viewModel.availableCurrencies, [CurrencyCode.usd]);
      expect(viewModel.currency, CurrencyCode.usd);
      viewModel.dispose();
    });

    test('통화가 여러 개면 주 통화를 먼저 두고 기본 선택한다', () async {
      final viewModel = createViewModel([
        statisticsTestEntry(
          type: LedgerRecordType.expense,
          amount: 100,
          date: DateTime(2026, 10, 1),
          currency: 'USD',
        ),
        statisticsTestEntry(
          type: LedgerRecordType.expense,
          amount: 100,
          date: DateTime(2026, 10, 1),
          currency: 'JPY',
        ),
      ]);
      viewModel.start(initialMonth: now, primary: CurrencyCode.jpy);
      await pumpEventQueue();

      expect(viewModel.availableCurrencies, [
        CurrencyCode.jpy,
        CurrencyCode.usd,
      ]);
      expect(viewModel.currency, CurrencyCode.jpy);

      viewModel.selectCurrency(CurrencyCode.usd);
      expect(viewModel.currency, CurrencyCode.usd);
      viewModel.dispose();
    });

    test('저장된 설정을 불러오고, 바꾼 설정은 저장한다', () async {
      final preferences = FakeStatisticsPreferencesRepository(
        const StatisticsPreferences(
          trendChartType: StatisticsTrendChartType.bar,
          hiddenExpenseCategories: {'교통'},
        ),
      );
      final viewModel = createViewModel(const [], preferences: preferences);
      viewModel.start(initialMonth: now, primary: CurrencyCode.krw);
      await pumpEventQueue();

      expect(viewModel.trendChartType, StatisticsTrendChartType.bar);
      expect(viewModel.hiddenCategories(LedgerRecordType.expense), {'교통'});

      viewModel.setCategoryVisible(
        LedgerRecordType.expense,
        '교통',
        visible: true,
      );
      viewModel.setCategoryVisible(
        LedgerRecordType.income,
        '월급',
        visible: false,
      );
      viewModel.setTrendChartType(StatisticsTrendChartType.line);
      await pumpEventQueue();

      expect(preferences.saveCount, 3);
      expect(preferences.stored.hiddenExpenseCategories, isEmpty);
      expect(preferences.stored.hiddenIncomeCategories, {'월급'});
      expect(preferences.stored.trendChartType, StatisticsTrendChartType.line);
      viewModel.dispose();
    });

    test('카테고리 그래프는 추이와 같은 기간을 쓰고, 카테고리는 정의 순서(기타 마지막)로 나열한다', () async {
      final viewModel = createViewModel([
        statisticsTestEntry(
          type: LedgerRecordType.income,
          amount: 3000,
          date: DateTime(2026, 8, 25),
          category: '월급',
        ),
        statisticsTestEntry(
          type: LedgerRecordType.expense,
          amount: 100,
          date: DateTime(2026, 9, 1),
          category: '기타',
        ),
        statisticsTestEntry(
          type: LedgerRecordType.expense,
          amount: 700,
          date: DateTime(2026, 10, 1),
          category: '교통',
        ),
        statisticsTestEntry(
          type: LedgerRecordType.expense,
          amount: 50,
          date: DateTime(2026, 10, 2),
          category: '식비',
        ),
      ]);
      viewModel.start(initialMonth: now, primary: CurrencyCode.krw);
      await pumpEventQueue();

      final expenseTrend = viewModel.categoryTrend(LedgerRecordType.expense);
      // 지출은 9월부터지만 기간은 수입이 시작된 8월부터다.
      expect(expenseTrend.map((item) => item.month), [
        DateTime(2026, 8),
        DateTime(2026, 9),
        DateTime(2026, 10),
      ]);
      expect(expenseTrend.first.amounts, isEmpty);
      expect(viewModel.categoriesInRange(LedgerRecordType.expense), [
        '식비',
        '교통',
        '기타',
      ]);
      expect(viewModel.categoriesInRange(LedgerRecordType.income), ['월급']);
      viewModel.dispose();
    });

    test('그래프별 선택은 기본이 마지막 달이고 서로 연동되지 않는다', () async {
      final viewModel = createViewModel([
        statisticsTestEntry(
          type: LedgerRecordType.expense,
          amount: 100,
          date: DateTime(2026, 8, 1),
        ),
        statisticsTestEntry(
          type: LedgerRecordType.income,
          amount: 700,
          date: DateTime(2026, 10, 1),
          category: '월급',
        ),
      ]);
      viewModel.start(initialMonth: now, primary: CurrencyCode.krw);
      await pumpEventQueue();

      expect(viewModel.monthlyTrend.length, 3);
      expect(viewModel.selectedTrendIndex, 2);
      expect(viewModel.selectedCategoryIndex(LedgerRecordType.expense), 2);
      expect(viewModel.selectedCategoryIndex(LedgerRecordType.income), 2);

      viewModel.selectCategoryIndex(LedgerRecordType.expense, 0);
      viewModel.selectTrendIndex(1);

      expect(viewModel.selectedCategoryIndex(LedgerRecordType.expense), 0);
      expect(viewModel.selectedTrendIndex, 1);
      expect(viewModel.selectedCategoryIndex(LedgerRecordType.income), 2);
      viewModel.dispose();
    });

    test('원형 섹션은 12개월 밖의 달도 보여주고, 월 이동은 다른 그래프 선택에 영향을 주지 않는다', () async {
      final viewModel = createViewModel([
        statisticsTestEntry(
          type: LedgerRecordType.expense,
          amount: 100,
          date: DateTime(2025, 1, 3),
          category: '식비',
        ),
        statisticsTestEntry(
          type: LedgerRecordType.expense,
          amount: 300,
          date: DateTime(2025, 1, 9),
          category: '교통',
        ),
        statisticsTestEntry(
          type: LedgerRecordType.expense,
          amount: 50,
          date: DateTime(2025, 2, 9),
          category: '쇼핑',
        ),
        statisticsTestEntry(
          type: LedgerRecordType.income,
          amount: 3000,
          date: DateTime(2026, 10, 1),
          category: '월급',
        ),
      ]);
      viewModel.start(
        initialMonth: DateTime(2025, 1, 20),
        primary: CurrencyCode.krw,
      );
      await pumpEventQueue();

      expect(viewModel.selectedMonth, DateTime(2025, 1));
      final amounts = viewModel.monthCategoryAmounts(LedgerRecordType.expense);
      expect(amounts.map((entry) => entry.key), ['교통', '식비']);
      expect(amounts.map((entry) => entry.value), [300, 100]);
      // 12개월 기간에는 2025년 1월이 없으므로 누적 막대·추이에는 포함되지 않는다.
      expect(viewModel.categoriesInRange(LedgerRecordType.expense), isEmpty);

      viewModel.changeMonth(1);
      await pumpEventQueue();

      expect(viewModel.selectedMonth, DateTime(2025, 2));
      expect(
        viewModel.monthCategoryAmounts(LedgerRecordType.expense).single.key,
        '쇼핑',
      );
      expect(viewModel.selectedTrendIndex, 0);
      viewModel.dispose();
    });

    test('집계는 캐시되어 달 선택·체크 변경 때는 다시 계산하지 않고, 통화가 바뀌면 다시 계산한다', () async {
      final viewModel = createViewModel([
        statisticsTestEntry(
          type: LedgerRecordType.expense,
          amount: 100,
          date: DateTime(2026, 9, 1),
        ),
        statisticsTestEntry(
          type: LedgerRecordType.expense,
          amount: 5,
          date: DateTime(2026, 10, 1),
          currency: 'USD',
        ),
      ]);
      viewModel.start(initialMonth: now, primary: CurrencyCode.krw);
      await pumpEventQueue();

      final trend = viewModel.monthlyTrend;
      final expenseTrend = viewModel.categoryTrend(LedgerRecordType.expense);
      expect(identical(viewModel.monthlyTrend, trend), isTrue);

      viewModel.selectTrendIndex(0);
      viewModel.selectCategoryIndex(LedgerRecordType.expense, 0);
      viewModel.setCategoryVisible(
        LedgerRecordType.expense,
        '식비',
        visible: false,
      );
      expect(identical(viewModel.monthlyTrend, trend), isTrue);
      expect(
        identical(
          viewModel.categoryTrend(LedgerRecordType.expense),
          expenseTrend,
        ),
        isTrue,
      );

      viewModel.selectCurrency(CurrencyCode.usd);
      expect(identical(viewModel.monthlyTrend, trend), isFalse);
      expect(viewModel.monthlyTrend.single.expense, 5);
      viewModel.dispose();
    });
  });
}
