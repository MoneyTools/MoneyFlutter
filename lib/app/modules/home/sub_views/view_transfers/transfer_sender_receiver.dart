import 'package:flutter/material.dart';
import 'package:money/app/data/models/money_objects/transfers/transfer.dart';
import 'package:money/app/modules/home/sub_views/money_object_card.dart';

class TransferSenderReceiver extends StatelessWidget {
  const TransferSenderReceiver({
    super.key,
    required this.transfer,
  });

  final Transfer transfer;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 30,
          spacing: 30,
          children: [
            IntrinsicWidth(
              child: TransactionCard(
                title: 'Sender',
                transaction: transfer.senderTransaction,
              ),
            ),
            IntrinsicWidth(
              child: TransactionCard(
                title: 'Receiver',
                transaction: transfer.receiverTransaction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
