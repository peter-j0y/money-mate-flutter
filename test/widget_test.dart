// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:money_mate/main.dart';

void main() {
  testWidgets('Bottom navigation switches tab content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MoneyMateApp());

    expect(find.text('2024년 3월'), findsOneWidget);
    expect(find.text('달력'), findsOneWidget);

    await tester.tap(find.text('자산'));
    await tester.pump();

    expect(find.text('내 자산'), findsOneWidget);

    await tester.tap(find.text('더보기'));
    await tester.pump();

    expect(find.text('설정 및 계정 관리'), findsOneWidget);
  });
}
