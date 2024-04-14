import 'package:flutter/material.dart';
import 'package:money/models/money_model.dart';
import 'package:money/models/money_objects/currencies/currency.dart';

/// Formatted text using the supplied currency code and optional the currency/country flag
class MoneyWidget extends StatelessWidget {
  /// Amount to display
  final MoneyModel amountModel;

  /// Constructor
  const MoneyWidget({
    super.key,
    required this.amountModel,
  });

  @override
  Widget build(final BuildContext context) {
    if (amountModel.showCurrency) {
      return Row(
        children: [
          _amountAsText(context),
          const SizedBox(width: 10),
          Currency.buildCurrencyWidget(amountModel.iso4217),
        ],
      );
    } else {
      return _amountAsText(context);
    }
  }

  Widget _amountAsText(final BuildContext context) {
    return Text(
      Currency.getAmountAsStringUsingCurrency(amountModel.amount, iso4217code: amountModel.iso4217),
      textAlign: TextAlign.right,
      style: TextStyle(fontFamily: 'RobotoMono', color: _getTextColorToUse(context)),
    );
  }

  Color? _getTextColorToUse(final BuildContext context) {
    final bool isDarkModeOne = Theme.of(context).brightness == Brightness.dark;
    if (amountModel.autoColor) {
      if (amountModel.amount == 0) {
        return Colors.grey.withOpacity(0.8);
      }
      if (amountModel.amount < 0) {
        if (isDarkModeOne) {
          return const Color.fromRGBO(255, 160, 160, 1);
        } else {
          return const Color.fromRGBO(160, 0, 0, 1);
        }
      } else {
        if (isDarkModeOne) {
          return const Color.fromRGBO(160, 255, 160, 1);
        } else {
          return const Color.fromRGBO(0, 100, 0, 1);
        }
      }
    }
    return null;
  }
}
