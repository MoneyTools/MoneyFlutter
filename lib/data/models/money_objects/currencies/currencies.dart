// Imports
import 'package:money/core/helpers/json_helper.dart';
import 'package:money/data/models/money_objects/currencies/currency.dart';
import 'package:money/data/models/money_objects/money_objects.dart';

// Exports
export 'package:money/data/models/money_objects/currencies/currency.dart';

class Currencies extends MoneyObjects<Currency> {
  Currencies() {
    collectionName = 'Currencies';
  }

  @override
  Currency instanceFromJson(final MyJson json) {
    return Currency.fromJson(json);
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }

  /// Converts a currency symbol to the corresponding country's alpha-2 code.
  ///
  /// If no matching currency is found, returns 'US' as the default value.
  String fromSymbolToCountryAlpha2(final String symbol) {
    final Currency? currency = getCurrencyFromSymbol(symbol);
    if (currency == null) {
      return 'US';
    }
    return currency.fieldCultureCode.getValueForSerialization(currency) as String;
  }

  Currency? getCurrencyFromSymbol(final String symbolToMatch) {
    return iterableList().firstWhereOrNull((Currency currency) => currency.fieldSymbol.value == symbolToMatch);
  }

  double getRatioFromSymbol(final String symbol) {
    final Currency? currency = getCurrencyFromSymbol(symbol);
    if (currency == null) {
      return 1;
    }
    return currency.fieldRatio.value;
  }
}
