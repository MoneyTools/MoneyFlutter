import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/core/controller/preferences_controller.dart';
import 'package:money/core/helpers/color_helper.dart';
import 'package:money/core/widgets/box.dart';
import 'package:money/core/widgets/my_text_input.dart';
import 'package:money/core/widgets/text_title.dart';
import 'package:money/data/models/money_objects/currencies/currency.dart';

import 'package:money/data/storage/data/data.dart';
import 'package:money/views/home/sub_views/app_scaffold.dart';

/// The `SettingsPage` class is a `GetView` that extends `GetxController`. It represents the settings page of the application.
/// This page allows the user to manage various settings, such as rental management, stock service API key, and currencies.
class SettingsPage extends GetView<GetxController> {
  /// Constructs a `SettingsPage` widget with the provided [key].
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return myScaffold(
      context,
      AppBar(
        title: const TextTitle('Settings'),
        centerTitle: true,
      ),
      Center(
        child: SingleChildScrollView(
          child: Box(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Rental'),
                  subtitle: const Text(
                    'Manage the expenses and rental income of properties.',
                  ),
                  value: PreferenceController.to.includeRentalManagement,
                  onChanged: (bool value) {
                    PreferenceController.to.includeRentalManagement = !PreferenceController.to.includeRentalManagement;
                  },
                ),
                Divider(height: 50),
                MyTextInput(
                  hintText: 'Stock service API key from https://twelvedata.com',
                  controller: TextEditingController()..text = PreferenceController.to.apiKeyForStocks,
                ),
                Divider(height: 50),
                MyTextInput(
                  hintText: 'Currencies',
                ),
                Divider(height: 50),
                _buildCurrenciesPanel(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrenciesPanel(final BuildContext context) {
    final List<Widget> widgets = <Widget>[];

    for (final Currency currency in Data().currencies.iterableList()) {
      widgets.add(
        Container(
          decoration: BoxDecoration(
            color: getColorTheme(context).surfaceContainerHighest,
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
                  Text(currency.fieldName.value),
                  Currency.buildCurrencyWidget(currency.fieldSymbol.value),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(currency.fieldRatio.value.toString()),
                  Text(currency.fieldCultureCode.value),
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
}
