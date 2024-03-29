import 'package:flutter/material.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/models/money_objects/payees/payee.dart';
import 'package:money/views/view_accounts/picker_account.dart';
import 'package:money/views/view_payees/picker_payee.dart';
import 'package:money/widgets/gaps.dart';

enum TransactionFlavor {
  payee,
  transfer,
}

class PickPayeeOrTransfer extends StatefulWidget {
  final TransactionFlavor choice;
  final Payee? payee;
  final Account? account;
  final double amount;
  final Function(TransactionFlavor choice, Payee? payee, Account? account) onSelected;

  const PickPayeeOrTransfer({
    super.key,
    required this.choice,
    required this.payee,
    required this.account,
    required this.amount,
    required this.onSelected,
  });

  @override
  State<PickPayeeOrTransfer> createState() => _PickPayeeOrTransferState();
}

class _PickPayeeOrTransferState extends State<PickPayeeOrTransfer> {
  late TransactionFlavor _choice;

  @override
  void initState() {
    super.initState();
    _choice = widget.choice;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(width: 250, child: buildChoice()),
            const Spacer(),
          ],
        ),
        Expanded(
          child: buildIInput(),
        ),
      ],
    );
  }

  Widget buildIInput() {
    if (_choice == TransactionFlavor.payee) {
      return presentInput(
        'Name',
        pickerPayee(
            itemSelected: widget.payee,
            onSelected: (Payee? payee) {
              widget.onSelected(_choice, payee, widget.account);
            }),
      );
    } else {
      return presentInput(
        widget.amount > 0 ? 'From Account' : 'To Account',
        pickerAccount(
          selected: widget.account,
          onSelected: (Account? account) {
            widget.onSelected(_choice, widget.payee, account);
          },
        ),
      );
    }
  }

  Widget presentInput(final String caption, final Widget widget) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 100, child: Text(caption)),
        gapMedium(),
        Expanded(
          child: widget,
        ),
      ],
    );
  }

  Widget buildChoice() {
    return SegmentedButton<TransactionFlavor>(
      style: const ButtonStyle(visualDensity: VisualDensity(horizontal: -4, vertical: -4)),
      segments: const <ButtonSegment<TransactionFlavor>>[
        ButtonSegment<TransactionFlavor>(
          value: TransactionFlavor.payee,
          label: Text('Payee'),
        ),
        ButtonSegment<TransactionFlavor>(
          value: TransactionFlavor.transfer,
          label: Text('Transfer'),
        ),
      ],
      selected: <TransactionFlavor>{_choice},
      onSelectionChanged: (final Set<TransactionFlavor> newSelection) {
        setState(() {
          _choice = newSelection.first;
        });
      },
    );
  }
}
