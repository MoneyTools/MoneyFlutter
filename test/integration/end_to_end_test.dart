import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Landing page', (final WidgetTester tester) async {
      // Enable GetX test mode
      Get.testMode = true;

      // Use an empty SharedPreferences to get the same results each time
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(MyApp());

      // Delay for 3 seconds before starting the test
      await tester.pumpAndSettle();

      // await tester.pumpAndSettle();

      try {
        // Verify if "Welcome to MyMoney" text is present
        expect(find.text('Welcome to MyMoney'), findsOneWidget);
      } catch (e) {
        // Capture a screenshot if the test fails
        // await takeScreenshot(tester, 'failure_screenshot');
        await writeElementsWithTextToFile(tester);
        rethrow; // Re-throw the caught exception to ensure the test fails
      }

      // Enable GetX test mode
      Get.testMode = false;
    });
  });
}

Future<void> takeScreenshot(WidgetTester tester, String screenshotName) async {
  // WidgetsFlutterBinding.ensureInitialized();
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final List<int> bytes = await binding.takeScreenshot(screenshotName);

  final directory = await getApplicationDocumentsDirectory();
  final File file = File('${directory.path}/$screenshotName.png');
  await file.writeAsBytes(bytes);

  debugLog('Screenshot saved to ${file.path}');
}

Future<void> writeElementsWithTextToFile(WidgetTester tester) async {
  final List<Map<String, dynamic>> widgetInfoList = [];

  // Function to recursively traverse the widget tree
  void traverseElement(Element? element) {
    if (element == null) return; // Handle null element case

    // Check if the element contains readable text
    if (element.widget is Text || element.widget is ElevatedButton) {
      final Text? textWidget = element.widget as Text?;

      String text = '';

      // Text()
      if (element.widget is Text) {
        text = (textWidget as Text).data ?? '';
      }

      // Button()
      if (element.widget is ElevatedButton) {
        text = (element.widget as ElevatedButton).child?.toString() ?? '';
      }

      if (text.isNotEmpty) {
        final widgetType = element.widget.runtimeType.toString();
        final widgetKey = element.widget.key?.toString() ?? element.hashCode.toString();
        final widgetProperties = {
          'type': widgetType,
          'key': widgetKey,
          'text': text,
          // Add more properties you want to log here
        };
        widgetInfoList.add(widgetProperties);
      }
    }

    // Traverse children
    element.visitChildren(traverseElement);
  }

  // Start traversal from the root widget (typically MaterialApp or your custom root widget)
  final rootElement = tester.binding.rootElement;
  traverseElement(rootElement);

  debugLog('**********************************************************');
  debugLog(widgetInfoList.join('\n'));
  debugLog('**********************************************************');
}
