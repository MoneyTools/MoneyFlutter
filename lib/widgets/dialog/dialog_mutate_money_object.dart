import 'package:flutter/material.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/widgets/dialog/dialog_button.dart';
import 'package:money/widgets/dialog/dialog_full_screen.dart';

showDialogAndActionsForMoneyObject(
  final BuildContext context,
  final MoneyObject moneyObject,
) {
  showDialogAndActionsForMoneyObjects(context, [moneyObject]);
}

showDialogAndActionsForMoneyObjects(
  final BuildContext context,
  final List<MoneyObject> moneyObjects,
) {
  final rollup = moneyObjects[0].rollup(moneyObjects);
  MyJson beforeEditing = rollup.getPersistableJSon();

  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogMutateMoneyObject(
          moneyObject: rollup,
          onApplyChange: (MoneyObject objectChanged) {
            MyJson afterEditing = rollup.getPersistableJSon();
            MyJson diff = myJsonDiff(before: beforeEditing, after: afterEditing);

            if (diff.keys.isNotEmpty) {
              for (final m in moneyObjects) {
                m.stashValueBeforeEditing();
                diff.forEach((key, value) {
                  m.mutateField(key, value['after'], false);
                });
              }
            }
            Data().updateAll();
          },
        );
      });
}

/// Dialog content
class DialogMutateMoneyObject extends StatefulWidget {
  final MoneyObject moneyObject;
  final Function(MoneyObject) onApplyChange;

  const DialogMutateMoneyObject({
    super.key,
    required this.moneyObject,
    required this.onApplyChange,
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
                    dataWasModified = isDataModified(_moneyObject);
                  });
                }),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: getActionButtons(
              context: context,
              moneyObject: _moneyObject,
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
    required MoneyObject moneyObject,
    required bool editMode,
    required bool dataWasModified,
  }) {
    return [
      DialogActionButton(
          text: dataWasModified ? 'Apply' : 'Done',
          onPressed: () {
            // Changes were made
            if (dataWasModified) {
              widget.onApplyChange(moneyObject);
            }
            Navigator.of(context).pop(true);
          })
    ];
  }

  bool isDataModified(MoneyObject moneyObject) {
    MyJson afterEditing = moneyObject.getPersistableJSon();
    MyJson diff = myJsonDiff(before: moneyObject.valueBeforeEdit ?? {}, after: afterEditing);
    return diff.keys.isNotEmpty;
  }
}
