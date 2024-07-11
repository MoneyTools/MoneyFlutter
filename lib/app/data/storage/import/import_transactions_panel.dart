import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/value_parser.dart';
import 'package:money/app/core/widgets/columns/columns_input.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/core/widgets/import_transactions_list_preview.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/currencies/currency.dart';
import 'package:money/app/modules/home/sub_views/view_accounts/picker_account.dart';

/// use for free style text to transaction import
class ImportTransactionsPanel extends StatefulWidget {
  const ImportTransactionsPanel({
    required this.account,
    required this.inputText,
    required this.onAccountChanged,
    required this.onTransactionsFound,
    super.key,
  });
  final Account account;
  final String inputText;
  final Function(Account accountSelected) onAccountChanged;
  final Function(ValuesParser parser) onTransactionsFound;

  @override
  ImportTransactionsPanelState createState() => ImportTransactionsPanelState();
}

class ImportTransactionsPanelState extends State<ImportTransactionsPanel> {
  late Account _account;
  late String _textToParse;
  final List<String> _possibleDateFormats = [
    // Dash
    'yyyy-MM-dd',
    'yy-MM-dd',
    'yyyy-dd-MM',
    'yy-dd-MM',
    'MM-dd-yyyy',
    'MM-dd-yy',
    'dd-MM-yyyy',
    'dd-MM-yy',
    // Slash
    'yyyy/MM/dd',
    'yy/MM/dd',
    'yyyy/dd/MM',
    'yy/dd/MM',
    'MM/dd/yyyy',
    'MM/dd/yy',
    'dd/MM/yyyy',
    'dd/MM/yy',
  ];
  late String userChoiceOfDateFormat = _possibleDateFormats.first;
  int _userChoiceDebitVsCredit = 0;
  int _userChoiceNativeVsUSD = 0;
  final _focusNode = FocusNode();

  List<ValuesQuality> _values = [];

  @override
  void initState() {
    super.initState();
    _account = widget.account;
    _textToParse = widget.inputText;
    convertAndNotify(context, _textToParse);
  }

  @override
  Widget build(BuildContext context) {
    ValuesParser.evaluateExistence(
      accountId: _account.uniqueId,
      values: _values,
    );

    return SizedBox(
      width: 800,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderAndAccountPicker(),

          gapMedium(),

          Expanded(
            flex: 1,
            child: InputByColumns(
              inputText: _textToParse,
              dateFormat: userChoiceOfDateFormat,
              currency: _userChoiceNativeVsUSD == 0 ? _account.getAccountCurrencyAsText() : Constants.defaultCurrency,
              reverseAmountValue: _userChoiceDebitVsCredit == 1,
              onChange: (String newTextInput) {
                setState(() {
                  convertAndNotify(context, newTextInput);
                  _textToParse = newTextInput;
                });
              },
            ),
          ),

          ///
          /// Date Format | Credit/Debit | Currency
          ///
          if (_values.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: SizeForPadding.large),
              child: Row(
                children: [
                  _buildChoiceOfDateFormat(),
                  const Spacer(),
                  _buildChoiceOfDebitVsCredit(),
                  gapLarge(),
                  _buildChoiceOfAmountFormat(),
                ],
              ),
            ),

          const Divider(),
          gapMedium(),

          // Results
          Expanded(
            flex: 2,
            child: Center(
              child: ImportTransactionsListPreview(
                accountId: _account.uniqueId,
                values: _values,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAndAccountPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Import transaction to account',
          style: getTextTheme(context).bodyLarge,
        ),
        gapLarge(),
        Expanded(
          child: pickerAccount(
            selected: _account,
            onSelected: (final Account? accountSelected) {
              setState(
                () {
                  _account = accountSelected!;
                  widget.onAccountChanged(_account);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceOfDateFormat() {
    if (_values.isEmpty) {
      return const SizedBox();
    }

    final List<String> listOfDateAsStrings = _values.map((entry) => entry.date.asString()).toList();

    List<String> choiceOfDateFormat = getPossibleDateFormatsForAllValues(listOfDateAsStrings);

    if (choiceOfDateFormat.isEmpty) {
      return Text('Bad Date Format', style: TextStyle(color: getColorFromState(ColorState.error)));
    }

    // make sure that the last choice is a valid one
    if (!choiceOfDateFormat.contains(userChoiceOfDateFormat)) {
      userChoiceOfDateFormat = choiceOfDateFormat.first;
    }

    return DropdownButton<String>(
      dropdownColor: getColorTheme(context).secondaryContainer,
      value: userChoiceOfDateFormat,
      items: choiceOfDateFormat
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item, style: TextStyle(color: getColorTheme(context).onSecondaryContainer)),
            ),
          )
          .toList(),
      onChanged: (final String? value) {
        setState(() {
          userChoiceOfDateFormat = value!;
          convertAndNotify(context, _textToParse);
        });
      },
    );
  }

  Widget _buildChoiceOfDebitVsCredit() {
    return SegmentedButton<int>(
      style: const ButtonStyle(
        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
      ),
      segments: const <ButtonSegment<int>>[
        ButtonSegment<int>(
          value: 0,
          label: Text('Credit'),
        ),
        ButtonSegment<int>(
          value: 1,
          label: Text('Debit'),
        ),
      ],
      selected: <int>{_userChoiceDebitVsCredit},
      onSelectionChanged: (final Set<int> newSelection) {
        setState(() {
          _userChoiceDebitVsCredit = newSelection.first;
          convertAndNotify(context, _textToParse);
        });
      },
    );
  }

  /// Offer assistance for the currency format
  Widget _buildChoiceOfAmountFormat() {
    if (_account.getAccountCurrencyAsText() == Constants.defaultCurrency) {
      // No need to offer switching currency input format
      return Currency.buildCurrencyWidget(Constants.defaultCurrency);
    }

    return SegmentedButton<int>(
      style: const ButtonStyle(
        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
      ),
      segments: <ButtonSegment<int>>[
        ButtonSegment<int>(
          value: 0,
          label: _account.getAccountCurrencyAsWidget(),
        ),
        ButtonSegment<int>(
          value: 1,
          label: Currency.buildCurrencyWidget(Constants.defaultCurrency),
        ),
      ],
      selected: <int>{_userChoiceNativeVsUSD},
      onSelectionChanged: (final Set<int> newSelection) {
        setState(() {
          _userChoiceNativeVsUSD = newSelection.first;
          convertAndNotify(context, _textToParse);
        });
      },
    );
  }

  void convertAndNotify(BuildContext context, String inputText) {
    ValuesParser parser = ValuesParser(
      dateFormat: userChoiceOfDateFormat,
      currency: _userChoiceNativeVsUSD == 0 ? _account.getAccountCurrencyAsText() : Constants.defaultCurrency,
      reverseAmountValue: _userChoiceDebitVsCredit == 1,
    );
    parser.convertInputTextToTransactionList(
      context,
      inputText,
    );
    _values = parser.lines;
    widget.onTransactionsFound(parser);
  }

  void requestFocus() {
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void removeFocus() {
    _focusNode.unfocus();
  }
}
