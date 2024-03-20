import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/widgets/dialog.dart';

void showCurrencies(final BuildContext context) {
  myShowDialog(
    context: context,
    title: 'Currencies',
    actionButtons: [],
    child: buildCurrenciesPanel(context),
  );
}

Widget buildCurrenciesPanel(final BuildContext context) {
  final List<Widget> widgets = <Widget>[];

  for (final Currency currency in Data().currencies.iterableList()) {
    widgets.add(
      Container(
        decoration: BoxDecoration(
          color: getColorTheme(context).surfaceVariant,
          border: Border.all(color: getColorTheme(context).outline),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(4),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(currency.name.value),
                Currency.buildCurrencyWidget(currency.symbol.value),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(currency.ratio.value.toString()),
                Text(currency.cultureCode.value),
              ],
            ),
          ],
        ),
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: widgets,
  );
}
