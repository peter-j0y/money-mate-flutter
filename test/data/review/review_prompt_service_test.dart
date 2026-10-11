import 'package:flutter_test/flutter_test.dart';
import 'package:money_mate/data/analytics/analytics_events.dart';
import 'package:money_mate/data/analytics/analytics_service.dart';
import 'package:money_mate/data/repositories/ledger_record_repository.dart';
import 'package:money_mate/data/repositories/review_prompt_repository.dart';
import 'package:money_mate/data/review/review_prompt_policy.dart';
import 'package:money_mate/data/review/review_prompt_service.dart';
import 'package:money_mate/data/review/store_review_client.dart';

class _FakeLedgerRecordRepository implements LedgerRecordRepository {
  int count = 0;
  DateTime? oldestCreatedAt;
  bool throwOnCount = false;

  @override
  Future<int> countRecords() async {
    if (throwOnCount) throw StateError('db');
    return count;
  }

  @override
  Future<DateTime?> fetchOldestCreatedAt() async => oldestCreatedAt;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeReviewPromptRepository implements ReviewPromptRepository {
  DateTime? anchorAt;
  DateTime? lastRequestedAt;

  @override
  Future<DateTime?> getAnchorAt() async => anchorAt;

  @override
  Future<void> setAnchorAt(DateTime value) async => anchorAt = value;

  @override
  Future<DateTime?> getLastRequestedAt() async => lastRequestedAt;

  @override
  Future<void> setLastRequestedAt(DateTime value) async =>
      lastRequestedAt = value;
}

class _FakeStoreReviewClient implements StoreReviewClient {
  bool available = true;
  bool throwOnRequest = false;
  bool throwOnOpen = false;
  int requestCount = 0;
  int openCount = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> requestReview() async {
    if (throwOnRequest) throw StateError('os');
    requestCount++;
  }

  @override
  Future<void> openStoreListing() async {
    if (throwOnOpen) throw StateError('os');
    openCount++;
  }
}

class _RecordingAnalyticsService implements AnalyticsService {
  final List<AnalyticsEvent> events = [];

  @override
  Future<void> logEvent(AnalyticsEvent event) async => events.add(event);

  @override
  Future<void> logScreenView(AnalyticsScreen screen) async {}

  @override
  Future<void> logButtonClick(
    AnalyticsButton button, {
    Map<String, Object>? parameters,
  }) async {}
}

void main() {
  final now = DateTime(2026, 10, 11, 12);

  group('shouldRequestReview', () {
    bool evaluate({
      int recordCount = 7,
      Duration sinceAnchor = const Duration(hours: 72),
      Duration? sinceLastRequest,
    }) {
      return shouldRequestReview(
        recordCount: recordCount,
        anchorAt: now.subtract(sinceAnchor),
        lastRequestedAt:
            sinceLastRequest == null ? null : now.subtract(sinceLastRequest),
        now: now,
      );
    }

    test('기록 7건부터 요청한다', () {
      expect(evaluate(recordCount: 6), isFalse);
      expect(evaluate(recordCount: 7), isTrue);
    });

    test('기준 시각으로부터 72시간이 지나야 요청한다', () {
      expect(evaluate(sinceAnchor: const Duration(hours: 71)), isFalse);
      expect(evaluate(sinceAnchor: const Duration(hours: 72)), isTrue);
    });

    test('마지막 요청 후 120일이 지나야 다시 요청한다', () {
      expect(evaluate(sinceLastRequest: const Duration(days: 119)), isFalse);
      expect(evaluate(sinceLastRequest: const Duration(days: 120)), isTrue);
    });

    test('기준 시각이 없으면 요청하지 않는다', () {
      expect(
        shouldRequestReview(
          recordCount: 100,
          anchorAt: null,
          lastRequestedAt: null,
          now: now,
        ),
        isFalse,
      );
    });
  });

  group('DefaultReviewPromptService', () {
    late _FakeLedgerRecordRepository ledger;
    late _FakeReviewPromptRepository prompts;
    late _FakeStoreReviewClient client;
    late _RecordingAnalyticsService analytics;
    late DefaultReviewPromptService service;

    setUp(() {
      ledger = _FakeLedgerRecordRepository();
      prompts = _FakeReviewPromptRepository();
      client = _FakeStoreReviewClient();
      analytics = _RecordingAnalyticsService();
      AnalyticsService.instance = analytics;
      service = DefaultReviewPromptService(
        ledgerRecordRepository: ledger,
        reviewPromptRepository: prompts,
        storeReviewClient: client,
        now: () => now,
      );
    });

    tearDown(() {
      AnalyticsService.instance = const NoopAnalyticsService();
    });

    group('initializeAnchor', () {
      test('신규 설치(기록 없음)는 현재 시각을 기준 시각으로 저장한다', () async {
        await service.initializeAnchor();
        expect(prompts.anchorAt, now);
      });

      test('기존 사용자는 가장 오래된 기록의 createdAt을 기준 시각으로 저장한다', () async {
        final oldest = DateTime(2026, 8, 1);
        ledger.oldestCreatedAt = oldest;
        await service.initializeAnchor();
        expect(prompts.anchorAt, oldest);
      });

      test('이미 기준 시각이 있으면 바꾸지 않는다', () async {
        final existing = DateTime(2026, 9, 1);
        prompts.anchorAt = existing;
        ledger.oldestCreatedAt = DateTime(2026, 1, 1);
        await service.initializeAnchor();
        expect(prompts.anchorAt, existing);
      });
    });

    group('maybeRequestReview', () {
      setUp(() {
        ledger.count = reviewPromptMinRecordCount;
        prompts.anchorAt = now.subtract(reviewPromptMinUsage);
      });

      test('조건을 충족하면 요청하고 시각 저장·이벤트 기록을 한다', () async {
        await service.maybeRequestReview();
        expect(client.requestCount, 1);
        expect(prompts.lastRequestedAt, now);
        expect(analytics.events, [AnalyticsEvent.reviewPromptRequested]);
      });

      test('조건 미충족이면 요청하지 않는다', () async {
        ledger.count = reviewPromptMinRecordCount - 1;
        await service.maybeRequestReview();
        expect(client.requestCount, 0);
        expect(prompts.lastRequestedAt, isNull);
      });

      test('OS가 리뷰 API를 지원하지 않으면 요청하지 않는다', () async {
        client.available = false;
        await service.maybeRequestReview();
        expect(client.requestCount, 0);
        expect(prompts.lastRequestedAt, isNull);
      });

      test('요청이 실패하면 마지막 요청 시각을 저장하지 않는다', () async {
        client.throwOnRequest = true;
        await service.maybeRequestReview();
        expect(prompts.lastRequestedAt, isNull);
        expect(analytics.events, isEmpty);
      });

      test('DB 조회 오류는 삼키고 요청하지 않는다', () async {
        ledger.throwOnCount = true;
        await expectLater(service.maybeRequestReview(), completes);
        expect(client.requestCount, 0);
      });
    });

    group('openStoreListing', () {
      test('스토어를 열면 true를 반환하고 120일 타이머를 리셋한다', () async {
        expect(await service.openStoreListing(), isTrue);
        expect(client.openCount, 1);
        expect(prompts.lastRequestedAt, now);
      });

      test('스토어 열기에 실패하면 false를 반환하고 타이머를 건드리지 않는다', () async {
        client.throwOnOpen = true;
        expect(await service.openStoreListing(), isFalse);
        expect(prompts.lastRequestedAt, isNull);
      });
    });

    test('onLedgerRecordSaved는 지연 후 조건을 판단한다', () async {
      ledger.count = reviewPromptMinRecordCount;
      prompts.anchorAt = now.subtract(reviewPromptMinUsage);
      final delayed = DefaultReviewPromptService(
        ledgerRecordRepository: ledger,
        reviewPromptRepository: prompts,
        storeReviewClient: client,
        now: () => now,
        requestDelay: const Duration(milliseconds: 10),
      );

      delayed.onLedgerRecordSaved();
      expect(client.requestCount, 0);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(client.requestCount, 1);
    });
  });
}
