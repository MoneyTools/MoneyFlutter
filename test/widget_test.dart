// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money/views/view_cashflow.dart';

class DummyHostingApp extends StatefulWidget {
  const DummyHostingApp({super.key});

  @override
  DummyHostingAppState createState() => DummyHostingAppState();
}

class DummyHostingAppState extends State<DummyHostingApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SizedBox(
        height: 500,
        width: 500,
        child: Column(
          children: const [
            ViewCashFlow(),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Cash Flow widget', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DummyHostingApp());

    // Verify that our counter starts at 0.
    expect(find.text('Cash Flow'), findsOneWidget);
  });
}
