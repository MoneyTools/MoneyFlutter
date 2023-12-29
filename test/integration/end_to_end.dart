import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:money/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('Landing page', (final WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('MyMoney'), findsOneWidget);
    });
  });
}
