import 'package:flutter/material.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/widgets/dialog.dart';

void showCurrencies(final BuildContext context) {
  final Widget content = buildCurrenciesPanel(context);

  myShowDialog(
    context: context,
    title: 'Currencies',
    child: content,
    isEditable: false,
  );
}

Widget buildCurrenciesPanel(final BuildContext context) {
  final List<Widget> widgets = <Widget>[];

  for (final Currency currency in Data().currencies.getList()) {
    widgets.add(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
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
