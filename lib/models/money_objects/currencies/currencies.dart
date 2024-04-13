// Imports
import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/money_objects.dart';

// Exports
export 'package:money/models/money_objects/currencies/currency.dart';

class Currencies extends MoneyObjects<Currency> {
  Currencies() {
    collectionName = 'Currencies';
  }

  @override
  Currency instanceFromSqlite(final MyJson row) {
    return Currency.fromJson(row);
  }

  @override
  void loadDemoData() {
    clear();
    final List<MyJson> demoCurrencies = <MyJson>[
      // ignore: always_specify_types
      {'Id': -1, 'Name': 'USA', 'Symbol': 'USD', "CultureCode": "en-US", "Ratio": 1.09, "LastRatio": 1.12},
      // ignore: always_specify_types
      {'Id': -1, 'Name': 'Canada', 'Symbol': 'CAD', "CultureCode": "en-CA", "Ratio": 0.75, "LastRatio": 0.85},
      // ignore: always_specify_types
      {'Id': -1, 'Name': 'Euro', 'Symbol': 'EUR', "CultureCode": "en-ES", "Ratio": 1.15, "LastRatio": 1.11},
      // ignore: always_specify_types
      {'Id': -1, 'Name': 'UK', 'Symbol': 'GBP', "CultureCode": "en-GB", "Ratio": 1.25, "LastRatio": 1.21},
      // ignore: always_specify_types
      {'Id': -1, 'Name': 'Japan', 'Symbol': 'JPY', "CultureCode": "en-JP", "Ratio": 1 / 147.72, "LastRatio": 0},
    ];
    for (final MyJson demoCurrency in demoCurrencies) {
      appendNewMoneyObject(Currency.fromJson(demoCurrency));
    }
  }

  Currency? getCurrencyFromSymbol(final String symbolToMatch) {
    return iterableList().firstWhereOrNull((currency) => currency.symbol.value == symbolToMatch);
  }

  String fromSymbolToCountryAlpha2(final String symbol) {
    Currency? currency = getCurrencyFromSymbol(symbol);
    if (currency == null) {
      return 'US';
    }
    return currency.cultureCode.value;
  }

  double getRatioFromSymbol(final String symbol) {
    Currency? currency = getCurrencyFromSymbol(symbol);
    if (currency == null) {
      return 1;
    }
    return currency.ratio.value;
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }
}
