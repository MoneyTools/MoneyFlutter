import 'package:flutter/material.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/widgets/dialog/dialog_button.dart';
import 'package:money/widgets/dialog/dialog_full_screen.dart';

showDialogAndActionsForMoneyObject(
  final BuildContext context,
  final MoneyObject moneyObject,
) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogMutateMoneyObject(moneyObject: moneyObject);
      });
}

/// Dialog content
class DialogMutateMoneyObject extends StatefulWidget {
  final MoneyObject moneyObject;

  const DialogMutateMoneyObject({
    super.key,
    required this.moneyObject,
  });

  @override
  State<DialogMutateMoneyObject> createState() => _DialogMutateMoneyObjectState();
}

class _DialogMutateMoneyObjectState extends State<DialogMutateMoneyObject> {
  bool dataWasModified = false;
  late MoneyObject _moneyObject;

  @override
  void initState() {
    super.initState();
    _moneyObject = widget.moneyObject;
  }

  @override
  Widget build(final BuildContext context) {
    return AutoSizeDialog(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _moneyObject.buildWidgets(onEdit: () {
                  setState(() {
                    dataWasModified = isDataModified();
                  });
                }),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: getActionButtons(
              context: context,
              transaction: _moneyObject,
              editMode: true,
              dataWasModified: dataWasModified,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> getActionButtons({
    required BuildContext context,
    required MoneyObject transaction,
    required bool editMode,
    required bool dataWasModified,
  }) {
    return [
      DialogActionButton(
          text: dataWasModified ? 'Apply' : 'Done',
          onPressed: () {
            // Changes were made
            if (dataWasModified) {
              Data().notifyTransactionChange(mutation: MutationType.changed, moneyObject: transaction);
            }
            Navigator.of(context).pop(true);
          })
    ];
  }

  bool isDataModified() {
    MyJson afterEditing = _moneyObject.getPersistableJSon();
    MyJson diff = myJsonDiff(before: _moneyObject.valueBeforeEdit ?? {}, after: afterEditing);
    return diff.keys.isNotEmpty;
  }
}
