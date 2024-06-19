import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/helpers/value_parser.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/views/view_accounts/picker_account.dart';
import 'package:money/widgets/columns/columns_input.dart';
import 'package:money/widgets/gaps.dart';
import 'package:money/widgets/import_transactions_list.dart';

/// use for free style text to transaction import
class ImportTransactionsPanel extends StatefulWidget {
  final Account account;
  final String inputText;
  final Function(Account accountSelected) onAccountChanged;
  final Function(ValuesParser parser) onTransactionsFound;

  const ImportTransactionsPanel({
    super.key,
    required this.account,
    required this.inputText,
    required this.onAccountChanged,
    required this.onTransactionsFound,
  });

  @override
  ImportTransactionsPanelState createState() => ImportTransactionsPanelState();
}

class ImportTransactionsPanelState extends State<ImportTransactionsPanel> {
  late Account account;
  late String textToParse;
  final _focusNode = FocusNode();

  List<ValuesQuality> values = [];

  @override
  void initState() {
    super.initState();
    account = widget.account;
    textToParse = widget.inputText;
    convertAndNotify(context, textToParse);
  }

  @override
  Widget build(BuildContext context) {
    for (final vq in values) {
      vq.checkIfExistAlready();
    }

    return SizedBox(
      width: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderAndAccountPicker(),

          gapLarge(),

          Expanded(
            flex: 1,
            child: ColumnInput(
              inputText: textToParse,
              onChange: (String newTextInput) {
                setState(() {
                  convertAndNotify(context, newTextInput);
                  textToParse = newTextInput;
                });
              },
            ),
          ),

          gapLarge(),

          // Results
          Expanded(
            flex: 2,
            child: ImportTransactionsList(
              values: values,
            ),
          ),

          const Divider(),

          // sumarry
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTallyOfItemsToImportOrSkip(),
                Text(ValuesQuality.getDateRange(values).toStringDays()),
                Text('Total: ${doubleToCurrency(sumOfValues())}', textAlign: TextAlign.right),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildTallyOfItemsToImportOrSkip() {
    int totalItems = values.length;
    int itemsToImport = values.where((item) => !item.exist).length;
    String text = getIntAsText(values.length);
    if (totalItems != itemsToImport) {
      text = '${getIntAsText(itemsToImport)}/${getIntAsText(totalItems)}';
    }
    return Text('$text entries');
  }

  Widget _buildHeaderAndAccountPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Import transaction to account', style: getTextTheme(context).bodyMedium),
        gapLarge(),
        Expanded(
          child: pickerAccount(
            selected: account,
            onSelected: (final Account? accountSelected) {
              setState(
                () {
                  account = accountSelected!;
                  widget.onAccountChanged(account);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  double sumOfValues() {
    double sum = 0;
    for (final ValuesQuality value in values) {
      sum += value.amount.asAmount();
    }
    return sum;
  }

  void convertAndNotify(BuildContext context, String inputText) {
    ValuesParser parser = ValuesParser();
    parser.convertInputTextToTransactionList(
      context,
      inputText,
    );
    values = parser.lines;
    widget.onTransactionsFound(parser);
  }

  void requestFocus() {
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void removeFocus() {
    _focusNode.unfocus();
  }
}
