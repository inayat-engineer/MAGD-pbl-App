// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:magd_pbl/main.dart';

void main() {
  testWidgets('MUET Notify app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('MUET Notify'), findsWidgets);
    expect(find.text('Notices'), findsOneWidget);
    expect(find.text('Summary'), findsOneWidget);
  });
}
