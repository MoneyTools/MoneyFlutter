import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/helpers/value_parser.dart';
import 'package:money/app/core/widgets/columns/columns_input.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/core/widgets/import_transactions_list.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
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
    'yyyy-MM-dd',
    'yyyy/MM/dd',
    'yyyy-dd-MM',
    'yyyy/dd/MM',
    'MM-dd-yyyy',
    'MM/dd/yyyy',
    'MM-dd-yy',
    'MM/dd/yy',
    'dd-MM-yyyy',
    'dd/MM/yyyy',
    'dd-MM-yy',
    'dd/MM/yy',
  ];
  late String userChoiceOfDateFormat = _possibleDateFormats.first;
  int _userChoiceDebitVsCredit = 0;
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
    ValuesParser.evaluateExistence(_values);

    return SizedBox(
      width: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderAndAccountPicker(),

          gapMedium(),

          Expanded(
            flex: 1,
            child: ColumnInput(
              inputText: _textToParse,
              dateFormat: userChoiceOfDateFormat,
              currency: _account.getAccountCurrencyAsText(),
              reverseAmountValue: _userChoiceDebitVsCredit == 1,
              onChange: (String newTextInput) {
                setState(() {
                  convertAndNotify(context, newTextInput);
                  _textToParse = newTextInput;
                });
              },
            ),
          ),
          if (_values.isNotEmpty)
            Row(
              children: [
                _buildChoiceOfDateFormat(),
                const Spacer(),
                _buildDebitVsCredit(),
                const Spacer(),
                _buildChoiceOfAmountFormat(),
              ],
            ),

          gapLarge(),

          // Results
          Expanded(
            flex: 2,
            child: ImportTransactionsList(
              values: _values,
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
          style: getTextTheme(context).bodyMedium,
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
    bool textToParseContainsSlash = _textToParse.contains('/');
    bool textToParseContainsDash = _textToParse.contains('-');

    Iterable<String> choiceOfDateFormat = _possibleDateFormats.where(
      (item) => (item.contains('/') && textToParseContainsSlash) || (item.contains('-') && textToParseContainsDash),
    );

    if (choiceOfDateFormat.isEmpty) {
      choiceOfDateFormat = _possibleDateFormats;
    }

    // make sure that the choice is valid
    if (!choiceOfDateFormat.contains(userChoiceOfDateFormat)) {
      userChoiceOfDateFormat = choiceOfDateFormat.first;
    }

    return DropdownButton<String>(
      value: userChoiceOfDateFormat,
      items: choiceOfDateFormat
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item),
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

  Widget _buildDebitVsCredit() {
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

  Widget _buildChoiceOfAmountFormat() {
    return _account.getAccountCurrencyAsWidget();
  }

  void convertAndNotify(BuildContext context, String inputText) {
    ValuesParser parser = ValuesParser(
      dateFormat: userChoiceOfDateFormat,
      currency: _account.getAccountCurrencyAsText(),
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
