import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:money_mate/data/analytics/analytics_events.dart';
import 'package:money_mate/data/analytics/analytics_service.dart';
import 'package:money_mate/data/repositories/ledger_record_repository.dart';
import 'package:money_mate/data/repositories/ledger_record_repository_impl.dart';
import 'package:money_mate/data/repositories/review_prompt_repository.dart';
import 'package:money_mate/data/repositories/review_prompt_repository_impl.dart';
import 'package:money_mate/data/review/review_prompt_policy.dart';
import 'package:money_mate/data/review/store_review_client.dart';

/// 스토어 리뷰 요청 진입점.
///
/// [AnalyticsService]와 같이 기본값은 아무것도 하지 않는 [NoopReviewPromptService]이고,
/// 앱 시작 시 `main`에서 [DefaultReviewPromptService]로 교체한다. 덕분에 위젯 테스트에서
/// 기록을 저장해도 SharedPreferences·OS API를 건드리지 않는다.
abstract class ReviewPromptService {
  static ReviewPromptService instance = const NoopReviewPromptService();

  /// 사용 기간 기준 시각이 없으면 한 번만 정한다 (R3).
  Future<void> initializeAnchor();

  /// 가계부 기록 신규 저장 성공 직후 호출한다. 화면 복귀 후 잠시 뒤 조건을 판단한다 (R1).
  void onLedgerRecordSaved();

  /// 더보기 > 리뷰 남기기. 스토어 페이지를 열었으면 true (R6).
  Future<bool> openStoreListing();
}

class NoopReviewPromptService implements ReviewPromptService {
  const NoopReviewPromptService();

  @override
  Future<void> initializeAnchor() async {}

  @override
  void onLedgerRecordSaved() {}

  @override
  Future<bool> openStoreListing() async => false;
}

class DefaultReviewPromptService implements ReviewPromptService {
  DefaultReviewPromptService({
    LedgerRecordRepository? ledgerRecordRepository,
    ReviewPromptRepository? reviewPromptRepository,
    StoreReviewClient? storeReviewClient,
    DateTime Function()? now,
    Duration requestDelay = const Duration(seconds: 1),
  }) : _ledgerRecordRepository =
           ledgerRecordRepository ?? LedgerRecordRepositoryImpl(),
       _reviewPromptRepository =
           reviewPromptRepository ?? ReviewPromptRepositoryImpl(),
       _storeReviewClient = storeReviewClient ?? InAppReviewStoreClient(),
       _now = now ?? DateTime.now,
       _requestDelay = requestDelay;

  final LedgerRecordRepository _ledgerRecordRepository;
  final ReviewPromptRepository _reviewPromptRepository;
  final StoreReviewClient _storeReviewClient;
  final DateTime Function() _now;
  final Duration _requestDelay;

  @override
  Future<void> initializeAnchor() async {
    try {
      if (await _reviewPromptRepository.getAnchorAt() != null) return;
      final oldestCreatedAt =
          await _ledgerRecordRepository.fetchOldestCreatedAt();
      await _reviewPromptRepository.setAnchorAt(oldestCreatedAt ?? _now());
    } catch (_) {
      // 기준 시각이 없으면 자동 요청이 일어나지 않을 뿐, 앱 시작을 막지 않는다.
    }
  }

  @override
  void onLedgerRecordSaved() {
    unawaited(Future.delayed(_requestDelay, maybeRequestReview));
  }

  /// 조건을 판단해 충족하면 OS 리뷰 시트를 요청한다. 오류는 사용자에게 드러내지 않는다 (R7).
  @visibleForTesting
  Future<void> maybeRequestReview() async {
    try {
      final now = _now();
      final shouldRequest = shouldRequestReview(
        recordCount: await _ledgerRecordRepository.countRecords(),
        anchorAt: await _reviewPromptRepository.getAnchorAt(),
        lastRequestedAt: await _reviewPromptRepository.getLastRequestedAt(),
        now: now,
      );
      if (!shouldRequest) return;
      if (!await _storeReviewClient.isAvailable()) return;

      await _storeReviewClient.requestReview();
      await _reviewPromptRepository.setLastRequestedAt(now);
      await AnalyticsService.instance.logEvent(
        AnalyticsEvent.reviewPromptRequested,
      );
    } catch (_) {}
  }

  @override
  Future<bool> openStoreListing() async {
    try {
      await _storeReviewClient.openStoreListing();
    } catch (_) {
      return false;
    }
    try {
      // 직접 리뷰하러 간 사용자에게 곧바로 자동 요청을 띄우지 않도록 타이머를 리셋한다.
      await _reviewPromptRepository.setLastRequestedAt(_now());
    } catch (_) {}
    return true;
  }
}
