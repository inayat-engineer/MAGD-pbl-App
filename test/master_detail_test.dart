import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magd_pbl/main.dart';

void main() {
  testWidgets('wide notices show an empty detail pane', (tester) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Select a notice to view details'), findsOneWidget);
    expect(find.text('Semester Fee Challan Submission'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
