import 'package:flutter/material.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/payees/payee.dart';
import 'package:money/app/modules/home/sub_views/view_accounts/picker_account.dart';
import 'package:money/app/modules/home/sub_views/view_payees/merge_payees.dart';
import 'package:money/app/modules/home/sub_views/view_payees/picker_payee.dart';

enum TransactionFlavor {
  payee,
  transfer,
}

class PickPayeeOrTransfer extends StatefulWidget {
  const PickPayeeOrTransfer({
    required this.choice,
    required this.payee,
    required this.account,
    required this.amount,
    required this.onSelected,
    super.key,
  });
  final TransactionFlavor choice;
  final Payee? payee;
  final Account? account;
  final double amount;
  final Function(TransactionFlavor choice, Payee? payee, Account? account) onSelected;

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
        gapMedium(),
        SizedBox(width: 250, child: buildChoice()),
        gapSmall(),
        Expanded(
          child: buildIInput(),
        ),
      ],
    );
  }

  Widget buildIInput() {
    if (_choice == TransactionFlavor.payee) {
      return Row(
        children: [
          Expanded(
            child: pickerPayee(
              itemSelected: widget.payee,
              onSelected: (Payee? payee) {
                widget.onSelected(_choice, payee, widget.account);
              },
            ),
          ),
          if (widget.payee != null)
            IconButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                showMergePayee(
                  context,
                  widget.payee!,
                ); //transactions.toList());
              },
              icon: const Icon(Icons.merge_outlined),
            ),
        ],
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
        if (caption.isNotEmpty) SizedBox(width: 100, child: Text(caption)),
        gapMedium(),
        Expanded(
          child: widget,
        ),
      ],
    );
  }

  Widget buildChoice() {
    return SegmentedButton<TransactionFlavor>(
      style: const ButtonStyle(
        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
      ),
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
