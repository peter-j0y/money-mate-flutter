import 'package:flutter_test/flutter_test.dart';
import 'package:money_mate/data/analytics/analytics_events.dart';
import 'package:money_mate/data/analytics/analytics_service.dart';
import 'package:money_mate/data/model/entities/ledger_record.dart';
import 'package:money_mate/data/repositories/ledger_record_repository.dart';
import 'package:money_mate/ui/ledger/view_models/add_ledger_record_view_model.dart';

class _FakeLedgerRecordRepository implements LedgerRecordRepository {
  int count = 0;
  bool throwOnAdd = false;

  @override
  Future<int> addRecord(LedgerEntryDraft draft) async {
    if (throwOnAdd) throw StateError('db');
    return ++count;
  }

  @override
  Future<int> countRecords() async => count;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
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
  late _FakeLedgerRecordRepository repository;
  late _RecordingAnalyticsService analytics;

  setUp(() {
    repository = _FakeLedgerRecordRepository();
    analytics = _RecordingAnalyticsService();
    AnalyticsService.instance = analytics;
  });

  tearDown(() => AnalyticsService.instance = const NoopAnalyticsService());

  Future<bool> save(AddLedgerRecordViewModel viewModel) {
    return viewModel.saveRecord(
      type: LedgerRecordType.expense,
      category: 'food',
      amount: 1000,
      currencyCode: 'KRW',
      date: DateTime(2026, 10, 11),
    );
  }

  test('첫 기록을 저장하면 first_record_saved를 기록한다', () async {
    final viewModel = AddLedgerRecordViewModel(repository: repository);

    expect(await save(viewModel), isTrue);

    expect(analytics.events, [AnalyticsEvent.firstRecordSaved]);
  });

  test('두 번째 기록부터는 기록하지 않는다', () async {
    repository.count = 1;
    final viewModel = AddLedgerRecordViewModel(repository: repository);

    expect(await save(viewModel), isTrue);

    expect(analytics.events, isEmpty);
  });

  test('저장에 실패하면 기록하지 않는다', () async {
    repository.throwOnAdd = true;
    final viewModel = AddLedgerRecordViewModel(repository: repository);

    expect(await save(viewModel), isFalse);

    expect(analytics.events, isEmpty);
  });
}
