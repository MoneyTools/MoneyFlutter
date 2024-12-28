import 'package:flutter/material.dart';
import 'package:money/core/widgets/dialog/dialog.dart';
import 'package:money/core/widgets/dialog/dialog_button.dart';
import 'package:money/core/widgets/gaps.dart';
import 'package:money/data/models/money_objects/investments/investment_types.dart';
import 'package:money/data/models/money_objects/investments/investments.dart';
import 'package:money/data/models/money_objects/securities/security.dart';
import 'package:money/data/models/money_objects/transactions/transaction.dart';
import 'package:money/data/storage/data/data.dart';
import 'package:money/data/storage/import/import_investment_panel.dart';

void showImportInvestment(
  final BuildContext context,
) {
  final inputData = InvestmentImportFields(
    account: Data().accounts.getMostRecentlySelectedAccount(),
    date: DateTime.now(),
    investmentType: InvestmentType.buy,
    symbol: '',
    units: 1,
    amountPerUnit: 0,
    transactionAmount: 0,
    description: '',
  );

  adaptiveScreenSizeDialog(
    context: context,
    captionForClose: 'Cancel',
    actionButtons: getActionButtons(inputData, context),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        gapLarge(),
        Expanded(
          child: ImportInvestmentPanel(inputFields: inputData),
        ),
      ],
    ),
  );
}

List<Widget> getActionButtons(
  InvestmentImportFields inputData,
  BuildContext context,
) {
  List<Widget> actionButtons = [
    // Button - Import
    DialogActionButton(
      text: 'Add Investment',
      onPressed: () {
        // Import

        // add the Transaction to the Transaction list
        final newTransaction = Transaction.fromDateDescriptionAmount(
          inputData.account,
          inputData.date,
          inputData.description,
          inputData.transactionAmount.toDouble(),
        );
        Data().transactions.appendNewMoneyObject(newTransaction, fireNotification: false);

        // add the Investment transaction to the Investment list
        final Security security = Data().securities.getOrCreate(inputData.symbol);
        final newInvestment = Investment(
          id: newTransaction.uniqueId,
          security: security.fieldId.value,
          units: inputData.units,
          unitPrice: inputData.amountPerUnit,
          investmentType: inputData.investmentType.index,
          tradeType: InvestmentTradeType.none.index,
        );
        Data().investments.appendMoneyObject(newInvestment);

        // update the app
        Data().updateAll();
        Navigator.of(context).pop(false);
      },
    ),
  ];
  return actionButtons;
}
