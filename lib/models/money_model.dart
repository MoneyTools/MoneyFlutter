import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/money_objects/currencies/currency.dart';

/// Formatted text using the supplied currency code and optional the currency/country flag
class MoneyModel {
  /// Amount to display
  double _amount;

  /// USD | CAD | GBP
  String iso4217;

  bool showCurrency;
  bool autoColor;

  /// Constructor
  MoneyModel({
    required double amount,
    this.iso4217 = Constants.defaultCurrency,
    this.showCurrency = false,
    this.autoColor = true,
  }) : _amount = amount;

  /// Add operator
  MoneyModel operator +(final dynamic value) {
    if (value is MoneyModel) {
      _amount += value.toDouble();
    } else {
      _amount += value as double;
    }
    return this;
  }

  /// Subtracting operator
  MoneyModel operator -(final dynamic value) {
    if (value is MoneyModel) {
      _amount -= value.toDouble();
    } else {
      _amount -= value as double;
    }
    return this;
  }

  /// Sets the _amount property of the MoneyModel instance based on the provided input.
  /// If the input is a String, it attempts to parse it as a double using the attemptToGetDoubleFromText function.
  /// If the input is not a String, it calls the toDouble() method on the input to convert it to a double.
  void setAmount(final dynamic newValueToSet) {
    _amount = newValueToSet is String // Check if the input is a String
        ? attemptToGetDoubleFromText(newValueToSet) ?? 0.0 // If it's a String, attempt to parse it as a double
        : newValueToSet.toDouble(); // If it's not a String, call toDouble() to convert it to a double
  }

  /// the raw value as double
  double toDouble() => _amount;

  /// amount formated with currency and separators
  @override
  String toString() {
    return Currency.getAmountAsStringUsingCurrency(_amount, iso4217code: iso4217);
  }
}
