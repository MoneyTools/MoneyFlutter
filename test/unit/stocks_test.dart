import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/storage/get_stock_from_cache_or_backend.dart';

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
@GenerateMocks([http.Client])
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
  });

  tearDown(() {
    Get.reset();
  });

  test('getFromCacheOrBackend returns expected value from cache', () async {
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
}
