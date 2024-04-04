import 'dart:async';

import 'package:money/helpers/date_helper.dart';
import 'package:money/helpers/file_systems.dart';
import 'package:money/helpers/json_helper.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/settings.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StockPrice {
  final DateTime date;
  final double price;

  /// Constructor
  const StockPrice({required this.date, required this.price});
}

const flagAsInvalidSymbol = 'invalid-symbol';

Future<StockLookupStatus> getFromCacheOrBackend(String symbol, List<StockPrice> prices) async {
  symbol = symbol.toLowerCase();

  prices.clear();
  StockLookupStatus resultState = await loadFromCache(symbol, prices);

  if (resultState == StockLookupStatus.foundInCache) {
    return StockLookupStatus.foundInCache;
  } else {
    StockLookupStatus status = await loadFromBackend(symbol, prices);
    switch (status) {
      case StockLookupStatus.validSymbol:
        saveToCache(symbol, prices);
        return StockLookupStatus.validSymbol;
      case StockLookupStatus.invalidSymbol:
        saveToCacheInvalidSymbol(symbol);
        return StockLookupStatus.invalidSymbol;
      default:
        return status;
    }
  }
}

enum StockLookupStatus {
  validSymbol,
  invalidSymbol,
  foundInCache,
  notFoundInCache,
  invalidApiKey,
}

Future<StockLookupStatus> loadFromCache(final String symbol, List<StockPrice> prices) async {
  final String mainFilenameStockSymbol = await fullPathToCacheStockFile(symbol);

  String? csvContent;
  try {
    csvContent = await MyFileSystems.readFile(mainFilenameStockSymbol);
    if (csvContent == flagAsInvalidSymbol) {
      // give up now
      return StockLookupStatus.invalidSymbol;
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
          final StockPrice sp = StockPrice(date: DateTime.parse(twoColumns[0]), price: double.parse(twoColumns[1]));
          prices.add(sp);
        }
      }
    }
    return StockLookupStatus.foundInCache;
  }
  return StockLookupStatus.notFoundInCache;
}

Future<StockLookupStatus> loadFromBackend(String symbol, List<StockPrice> prices) async {
  prices.clear();

  if (Settings().apiKeyForStocks.isEmpty) {
    // No API Key to make the backend request
    return StockLookupStatus.invalidApiKey;
  }

  DateTime tenYearsInThePast = DateTime.now().subtract(const Duration(days: 365 * 10));

  final Uri uri = Uri.parse(
      'https://api.twelvedata.com/time_series?symbol=$symbol&interval=1day&start_date=${tenYearsInThePast.toIso8601String()}&apikey=${Settings().apiKeyForStocks}');

  final http.Response response = await http.get(uri);

  if (response.statusCode == 200) {
    try {
      final MyJson data = json.decode(response.body);
      if (data['code'] == 401) {
        //data['message'];
        return StockLookupStatus.invalidApiKey;
      }

      if (data['code'] == 404) {
        // SYMBOL NOT FOUND
        return StockLookupStatus.invalidSymbol;
      }
      final List<dynamic> values = data['values'];

      // Unfortunately for now explanation the API may return two entries with the same date
      // for this ensure that we only have one date and price, last one wins
      Map<String, StockPrice> mapByUniqueDate = {};

      for (final value in values) {
        final String dateAsText = value['datetime'];

        StockPrice sp = StockPrice(
          date: DateTime.parse(dateAsText),
          price: double.parse(value['close']),
        );
        mapByUniqueDate[dateAsText] = sp;
      }

      // this will ensure that we only have one value per dates
      for (final StockPrice sp in mapByUniqueDate.values) {
        prices.add(sp);
      }
    } catch (error) {
      debugLog(error.toString());
    }
  } else {
    debugLog('Failed to fetch data: ${response.toString()}');
  }
  return StockLookupStatus.validSymbol;
}

void saveToCache(final String symbol, List<StockPrice> prices) async {
  final String mainFilenameStockSymbol = await fullPathToCacheStockFile(symbol);

  // CSV Header
  String csvContent = '"date","price"\n';

  // CSV Content
  for (final item in prices) {
    csvContent += '${dateToString(item.date)},${item.price.toString()}\n';
  }

  // Write CSV
  MyFileSystems.writeToFile(mainFilenameStockSymbol, csvContent);
}

void saveToCacheInvalidSymbol(final String symbol) async {
  final String mainFilenameStockSymbol = await fullPathToCacheStockFile(symbol);
  MyFileSystems.writeToFile(mainFilenameStockSymbol, flagAsInvalidSymbol);
}

Future<String> fullPathToCacheStockFile(final String symbol) async {
  final String cacheFolderForStockFiles = await pathToStockFiles();
  return MyFileSystems.append(cacheFolderForStockFiles, 'stock_$symbol.csv');
}

Future<String> pathToStockFiles() async {
  String destinationFolder = await Settings().fileManager.generateNextFolderToSaveTo();
  if (destinationFolder.isEmpty) {
    throw Exception('No container folder give for saving');
  }

  final String cacheFolderForStockFiles = MyFileSystems.append(destinationFolder, 'stocks');
  await MyFileSystems.ensureFolderExist(cacheFolderForStockFiles);

  return cacheFolderForStockFiles;
}
