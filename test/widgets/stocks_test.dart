import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:money/core/controller/data_controller.dart';
import 'package:money/core/controller/preferences_controller.dart';
import 'package:money/core/widgets/center_message.dart';
import 'package:money/data/models/money_objects/securities/security.dart';
import 'package:money/data/models/money_objects/stock_splits/stock_split.dart';
import 'package:money/data/storage/data/data.dart';
import 'package:money/data/storage/get_stock_from_cache_or_backend.dart';
import 'package:money/views/home/sub_views/view_stocks/stock_chart.dart';

// Mock the SharedPreference
class MockPreferenceController extends GetxController with Mock implements PreferenceController {
  @override
  String getString(String key, [String defaultValueIfNotFound = '']) {
    switch (key) {
      case 'stock-ge':
        return 'date, price\n2001-05-05, 12.34\n2002-06-06, 56.78\n';
      default:
        return '';
    }
  }

  @override
  Future<void> setString(
    String key,
    String value, [
    bool removeIfEmpty = false,
  ]) async {
    // do nothing
  }

  @override
  String get apiKeyForStocks => 'fake_api_key';
}

// Generate a MockClient class
// @GenerateMocks([http.Client])
class MockHttpClient extends Mock implements http.Client {
  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    return Future.value(http.Response(jsonEncode({'key': 'value'}), 200));
  }
}

void main() {
  late MockPreferenceController mockPreferenceController;

  setUp(() {
    mockPreferenceController = MockPreferenceController();
    Get.put<PreferenceController>(mockPreferenceController);
    // ignore: unused_local_variable
    final DataController dataController = Get.put(DataController());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Stock Chart', (WidgetTester tester) async {
    // Test getting History from the Mock Cache
    {
      final StockPriceHistoryCache result = await getFromCacheOrBackend('ge');
      expect(result.status, StockLookupStatus.foundInCache);
    }

    // Test getting from a Mocked Fetch
    {
      final StockPriceHistoryCache result = await getFromCacheOrBackend(Constants.mockStockSymbol);
      expect(result.status, StockLookupStatus.notFoundInCache);
    }
  });

  group('StockChartWidget', () {
    testWidgets('renders CenterMessage when security is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StockChartWidget(
            symbol: 'INVALID',
            splits: [],
            dividends: [],
            holdingsActivities: [],
          ),
        ),
      );

      expect(find.byType(CenterMessage), findsOneWidget);
      expect(find.text('Security "INVALID" is not valid'), findsOneWidget);
    });

    testWidgets('renders chart when data is available', (WidgetTester tester) async {
      final MoneyObject newFakeSecurity = Data().securities.appendNewMoneyObject(
            Security.fromJson({
              'Id': -1,
              'name': 'Fake Company',
              'symbol': Constants.mockStockSymbol,
              'price': 1.23,
              'lastPrice': 0.0,
              'cuspid': 'F0001',
              'securityType': 0,
              'taxable': 0,
            }),
          );

      final List<StockSplit> stockSplits = [
        StockSplit(
          date: DateTime(2021, 1, 1),
          security: newFakeSecurity.uniqueId,
          numerator: 2,
          denominator: 1,
        ),
      ];

      Data().stockSplits.setStockSplits(0, stockSplits);

      final holdingsActivities = [
        ChartEvent(
          date: DateTime(2022, 1, 1),
          amount: 100.0,
          quantity: 10,
          description: 'Buy',
          colorBasedOnQuantity: true,
        ),
        ChartEvent(
          date: DateTime(2022, 2, 1),
          amount: -50.0,
          quantity: -5,
          description: 'Sell',
          colorBasedOnQuantity: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: StockChartWidget(
            symbol: Constants.mockStockSymbol,
            splits: stockSplits,
            dividends: const [],
            holdingsActivities: holdingsActivities,
          ),
        ),
      );

      Data().stockSplits.clearSplitForSecurity(0);
    });
  });
}
