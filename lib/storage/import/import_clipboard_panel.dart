import 'package:flutter/material.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/views/view_accounts/account_selection.dart';
import 'package:money/widgets/gaps.dart';

///
class ImportClipboardPanel extends StatefulWidget {
  final String rawInputText;
  final Account account;
  final Function(Account accountSelected) onAccountChanged;
  final Widget child;

  const ImportClipboardPanel({
    super.key,
    required this.rawInputText,
    required this.account,
    required this.onAccountChanged,
    required this.child,
  });

  @override
  ImportClipboardPanelState createState() => ImportClipboardPanelState();
}

class ImportClipboardPanelState extends State<ImportClipboardPanel> {
  String selectedValue = 'Option 1'; // Initial selected value
  late Account account;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    account = widget.account;
  }

  @override
  Widget build(BuildContext context) {
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Date'), Text('Description'), Text('Amount')],
          ),
          gapMedium(),
          const Divider(),
          gapMedium(),
          widget.child,
          gapMedium(),
          const Divider(),
        ],
      ),
    );
  }
}
