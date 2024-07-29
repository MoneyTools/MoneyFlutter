// Imports
import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/data/models/money_objects/currencies/currency.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';

// Exports
export 'package:money/app/data/models/money_objects/currencies/currency.dart';

class Currencies extends MoneyObjects<Currency> {
  Currencies() {
    collectionName = 'Currencies';
  }

  @override
  Currency instanceFromSqlite(final MyJson row) {
    return Currency.fromJson(row);
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }

  String fromSymbolToCountryAlpha2(final String symbol) {
    Currency? currency = getCurrencyFromSymbol(symbol);
    if (currency == null) {
      return 'US';
    }
    return currency.fieldCultureCode.value;
  }

  Currency? getCurrencyFromSymbol(final String symbolToMatch) {
    return iterableList().firstWhereOrNull((currency) => currency.fieldSymbol.value == symbolToMatch);
  }

  double getRatioFromSymbol(final String symbol) {
    Currency? currency = getCurrencyFromSymbol(symbol);
    if (currency == null) {
      return 1;
    }
    return currency.fieldRatio.value;
  }
}
