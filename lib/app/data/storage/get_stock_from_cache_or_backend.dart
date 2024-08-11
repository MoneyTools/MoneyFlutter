import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/core/widgets/snack_bar.dart';
import 'package:money/app/data/models/constants.dart';

class StockDatePrice {
  /// Constructor
  const StockDatePrice({required this.date, required this.price});

  final DateTime date;
  final double price;
}

const flagAsInvalidSymbol = 'invalid-symbol';

class StockPriceHistoryCache {
  StockPriceHistoryCache(this.symbol, this.status, [this.lastDateTime]);

  String errorMessage = '';
  List<StockDatePrice> prices = [];
  StockLookupStatus status = StockLookupStatus.notFoundInCache;
  String symbol = '';

  DateTime? lastDateTime;
}

Future<StockPriceHistoryCache> getFromCacheOrBackend(
  String symbol,
) async {
  symbol = symbol.toLowerCase();

  StockPriceHistoryCache result = await _loadFromCache(symbol);

  if (result.status != StockLookupStatus.foundInCache) {
    // Try to load from the cloud service
    result = await loadFomBackendAndSaveToCache(symbol);
  }

  return result;
}

Future<StockPriceHistoryCache> loadFomBackendAndSaveToCache(String symbol) async {
  StockPriceHistoryCache result = await _loadFromBackend(symbol);
  if (result.errorMessage.isNotEmpty) {
    SnackBarService.displayError(message: result.errorMessage, autoDismiss: false);
  }
  switch (result.status) {
    case StockLookupStatus.validSymbol:
      _saveToCache(symbol, result.prices);
      return await _loadFromCache(symbol);
    case StockLookupStatus.invalidSymbol:
      _saveToCacheInvalidSymbol(symbol);
    default:
  }
  return result;
}

enum StockLookupStatus {
  validSymbol,
  invalidSymbol,
  foundInCache,
  notFoundInCache,
  invalidApiKey,
  error,
}

Future<StockPriceHistoryCache> _loadFromCache(
  final String symbol,
) async {
  final StockPriceHistoryCache stockPriceHistoryCache =
      StockPriceHistoryCache(symbol, StockLookupStatus.foundInCache, null);

  String? csvContent;

  try {
    csvContent = PreferenceController.to.getString('stock-$symbol');
    if (csvContent.isEmpty || csvContent == flagAsInvalidSymbol) {
      // give up now
      stockPriceHistoryCache.status = StockLookupStatus.notFoundInCache;
    } else {
      String dateTimeAsString = PreferenceController.to.getString('stock-date-$symbol');
      if (dateTimeAsString.isNotEmpty) {
        stockPriceHistoryCache.lastDateTime = DateTime.parse(dateTimeAsString);
      }
    }
  } catch (_) {
    //
  }

  if (csvContent != null) {
    final List<String> csvLines = csvContent.split('\n');

    for (var row = 0; row < csvLines.length; row++) {
      if (row == 0) {
        // skip header
      } else {
        final List<String> twoColumns = csvLines[row].split(',');
        if (twoColumns.length == 2) {
          final StockDatePrice sp = StockDatePrice(
            date: DateTime.parse(twoColumns[0]),
            price: double.parse(twoColumns[1]),
          );
          stockPriceHistoryCache.prices.add(sp);
        }
      }
    }
    return stockPriceHistoryCache;
  }
  return StockPriceHistoryCache(symbol, StockLookupStatus.notFoundInCache);
}

Future<StockPriceHistoryCache> _loadFromBackend(
  String symbol,
) async {
  final StockPriceHistoryCache result = StockPriceHistoryCache(symbol, StockLookupStatus.validSymbol);

  if (PreferenceController.to.apiKeyForStocks.isEmpty) {
    // No API Key to make the backend request
    return StockPriceHistoryCache(symbol, StockLookupStatus.invalidApiKey);
  }

  DateTime numberOfDaysInThePast = DateTime.now().subtract(const Duration(days: 365 * 40));

  final String url =
      'https://api.twelvedata.com/time_series?symbol=$symbol&interval=1day&start_date=${numberOfDaysInThePast.toIso8601String()}&apikey=${PreferenceController.to.apiKeyForStocks}';

  final Uri uri = Uri.parse(url);

  if (symbol == Constants.mockStockSymbol) {
    result.prices = [];
    return result;
  }

  http.Response response = await http.get(uri);

  if (response.statusCode == 200) {
    try {
      final MyJson data = json.decode(response.body);
      if (data['code'] == 401) {
        //data['message'];
        result.status = StockLookupStatus.invalidApiKey;
        return result;
      }

      if (data['code'] == 403 || data['code'] == 404) {
        // SYMBOL NOT FOUND
        result.status = StockLookupStatus.invalidSymbol;
        return result;
      }

      if (data['code'] == 409) {
        // API error
        // You have run out of API credits for the current minute. 9 API credits were used, with the current limit being 8. Wait for the new...
        result.status = StockLookupStatus.invalidApiKey;
        return result;
      }
      final List<dynamic> values = data['values'];

      // Unfortunately for now (sometimes) the API may returns two entries with the same date
      // for this ensure that we only have one date and price, last one wins
      Map<String, StockDatePrice> mapByUniqueDate = {};

      for (final value in values) {
        final String dateAsText = value['datetime'];

        StockDatePrice sp = StockDatePrice(
          date: DateTime.parse(dateAsText),
          price: double.parse(value['close']),
        );
        mapByUniqueDate[dateAsText] = sp;
      }

      // this will ensure that we only have one value per dates
      for (final StockDatePrice sp in mapByUniqueDate.values) {
        result.prices.add(sp);
      }
    } catch (error) {
      logger.e(error.toString());
    }
  } else {
    result.errorMessage = response.body.toString();
    logger.e('Failed to fetch data: ${response.body.toString()}');
  }
  return result;
}

void _saveToCache(final String symbol, List<StockDatePrice> prices) async {
  // CSV Header
  String csvContent = '"date","price"\n';

  // CSV Content
  for (final item in prices) {
    csvContent += '${dateToString(item.date)},${item.price.toString()}\n';
  }

  await PreferenceController.to.setString('stock-$symbol', csvContent);
  await PreferenceController.to.setString('stock-date-$symbol', DateTime.now().toIso8601String());
}

void _saveToCacheInvalidSymbol(final String symbol) async {
  await PreferenceController.to.setString('stock-$symbol', flagAsInvalidSymbol);
}
