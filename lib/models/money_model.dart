import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/money_objects/currencies/currency.dart';

/// Formatted text using the supplied currency code and optional the currency/country flag
class MoneyModel {
  /// Amount to display
  double amount;

  /// USD | CAD | GBP
  String iso4217;

  bool showCurrency;
  bool autoColor;

  /// Constructor
  MoneyModel({
    required this.amount,
    this.iso4217 = Constants.defaultCurrency,
    this.showCurrency = false,
    this.autoColor = true,
  });

  void setAmountValue(final dynamic newValueToSet) {
    double newValue = 0.00;
    if (newValueToSet is String) {
      newValue = attemptToGetDoubleFromText(newValueToSet) ?? 0.00;
    } else {
      newValue = newValueToSet as double;
    }
    amount = newValue;
  }

  @override
  String toString() {
    return Currency.getAmountAsStringUsingCurrency(amount, iso4217code: iso4217);
  }
}
