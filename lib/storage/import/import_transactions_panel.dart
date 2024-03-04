import 'package:flutter/material.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/value_parser.dart';
import 'package:money/views/view_accounts/account_selection.dart';
import 'package:money/widgets/gaps.dart';

///
class ImportTransactionsPanel extends StatefulWidget {
  final Account account;
  final String inputText;
  final Function(Account accountSelected) onAccountChanged;
  final Function(ValueParser parser) onTransactionsFound;

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
  final _controller = TextEditingController();
  ValueParser parser = ValueParser();

  @override
  void initState() {
    super.initState();
    account = widget.account;
    _controller.text = widget.inputText;
  }

  @override
  Widget build(BuildContext context) {
    convertAndNotify(context);

    return Center(
      child: Column(
        children: [
          buildAccountSelection(account, (final Account? accountSelected) {
            setState(() {
              account = accountSelected!;
              widget.onAccountChanged(account);
            });
          }),
          gapLarge(),
          TextField(
            maxLines: null, // Set maxLines to null for multiline TextField
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Date; Description; Amount',
              border: OutlineInputBorder(),
            ),
            onChanged: (text) {
              setState(() {
                convertAndNotify(context);
              });
            },
          ),
          gapLarge(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Date'), Text('Description'), Text('Amount')],
          ),
          gapMedium(),
          const Divider(),
          gapMedium(),
          parser.widgetToPresentToUser,
          gapMedium(),
          const Divider(),
        ],
      ),
    );
  }

  void convertAndNotify(BuildContext context) {
    parser.convertInputTextToTransactionList(
      context,
      _controller.text,
    );
    widget.onTransactionsFound(parser);
  }
}
