// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:money_mate/main.dart';

void main() {
  testWidgets('Bottom navigation switches tab content', (WidgetTester tester) async {
    await tester.pumpWidget(const MoneyMateApp());

    expect(find.text('계좌와 카드 자산을 한 번에 확인해요'), findsOneWidget);

    await tester.tap(find.text('가계부'));
    await tester.pump();

    expect(find.text('카테고리별 지출 통계'), findsOneWidget);
  });
}
