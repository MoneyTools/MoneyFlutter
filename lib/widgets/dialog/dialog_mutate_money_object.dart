import 'package:flutter/material.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/widgets/dialog/dialog.dart';
import 'package:money/widgets/dialog/dialog_button.dart';

myShowDialogAndActionsForMoneyObject({
  required final BuildContext context,
  required final String title,
  required final MoneyObject moneyObject,
}) {
  myShowDialogAndActionsForMoneyObjects(context: context, title: title, moneyObjects: [moneyObject]);
}

myShowDialogAndActionsForMoneyObjects({
  required final BuildContext context,
  required final String title,
  required final List<MoneyObject> moneyObjects,
}) {
  // Before we edit lets stash the current values of each objects
  for (final m in moneyObjects) {
    m.stashValueBeforeEditing();
  }

  final rollup = moneyObjects[0].rollup(moneyObjects);
  MyJson beforeEditing = rollup.getPersistableJSon();

  return adaptiveScreenSizeDialog(
    context: context,
    title: moneyObjects.length == 1 ? title : '${getIntAsText(moneyObjects.length)} $title',
    showCloseButton: false,
    child: DialogMutateMoneyObject(
      moneyObject: rollup,
      onApplyChange: (MoneyObject objectChanged) {
        MyJson afterEditing = rollup.getPersistableJSon();
        MyJson diff = myJsonDiff(before: beforeEditing, after: afterEditing);

        if (diff.keys.isNotEmpty) {
          for (final m in moneyObjects) {
            diff.forEach((key, value) {
              m.mutateField(key, value['after'], false);
            });
          }
        }
        Data().updateAll();
      },
    ),
  );
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
    return Column(
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
        dialogActionButtons(
          getActionButtons(
            context: context,
            moneyObject: _moneyObject,
            editMode: true,
            dataWasModified: dataWasModified,
          ),
        ),
      ],
    );
  }

  List<Widget> getActionButtons({
    required BuildContext context,
    required MoneyObject moneyObject,
    required bool editMode,
    required bool dataWasModified,
  }) {
    return [
      // Cancel
      DialogActionButton(
          text: 'Cancel',
          onPressed: () {
            Navigator.of(context).pop(false);
          }),

      // Apply
      if (dataWasModified)
        DialogActionButton(
            text: 'Apply',
            onPressed: () {
              // Changes were made
              if (dataWasModified) {
                widget.onApplyChange(moneyObject);
              }
              Navigator.of(context).pop(true);
            }),
    ];
  }

  bool isDataModified(MoneyObject moneyObject) {
    MyJson afterEditing = moneyObject.getPersistableJSon();
    MyJson diff = myJsonDiff(before: moneyObject.valueBeforeEdit ?? {}, after: afterEditing);
    return diff.keys.isNotEmpty;
  }
}
