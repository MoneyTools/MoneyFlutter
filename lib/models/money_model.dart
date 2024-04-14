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

  @override
  String toString() {
    return Currency.getAmountAsStringUsingCurrency(amount, iso4217code: iso4217);
  }
}
