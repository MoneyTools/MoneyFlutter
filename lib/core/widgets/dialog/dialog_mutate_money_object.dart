import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/core/helpers/string_helper.dart';
import 'package:money/core/widgets/dialog/dialog.dart';
import 'package:money/core/widgets/dialog/dialog_button.dart';
import 'package:money/core/widgets/message_box.dart';
import 'package:money/data/storage/data/data.dart';

void myShowDialogAndActionsForMoneyObject({
  required final String title,
  required final MoneyObject moneyObject,
  void Function()? onApplyChange,
}) {
  myShowDialogAndActionsForMoneyObjects(
    title: title,
    moneyObjects: <MoneyObject>[moneyObject],
    onApplyChange: onApplyChange,
  );
}

void myShowDialogAndActionsForMoneyObjects({
  required final String title,
  required final List<MoneyObject> moneyObjects,
  void Function()? onApplyChange,
}) {
  final BuildContext context = Get.context!;

  if (moneyObjects.isEmpty) {
    messageBox(context, 'No items to edit');
    return;
  }

  // Before we edit lets stash the current values of each objects
  for (final MoneyObject m in moneyObjects) {
    m.stashValueBeforeEditing();
  }

  final MoneyObject rollup = moneyObjects[0].rollup(moneyObjects);
  final MyJson beforeEditing = rollup.getPersistableJSon();

  return adaptiveScreenSizeDialog(
    context: context,
    title: moneyObjects.length == 1 ? title : '${getIntAsText(moneyObjects.length)} $title',
    captionForClose: null, // this will hide the close button
    child: DialogMutateMoneyObject(
      moneyObject: rollup,
      onApplyChange: (MoneyObject objectChanged) {
        final MyJson afterEditing = rollup.getPersistableJSon();
        final MyJson diff = myJsonDiff(before: beforeEditing, after: afterEditing);

        if (diff.keys.isNotEmpty) {
          for (final MoneyObject m in moneyObjects) {
            diff.forEach((String key, dynamic value) {
              m.mutateField(key, value['after'], false);
            });
          }
        }
        Data().updateAll();
        onApplyChange?.call();
      },
    ),
  );
}

/// Dialog content
class DialogMutateMoneyObject extends StatefulWidget {
  const DialogMutateMoneyObject({
    super.key,
    required this.moneyObject,
    required this.onApplyChange,
  });

  final MoneyObject moneyObject;
  final void Function(MoneyObject) onApplyChange;

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _moneyObject.buildListOfNamesValuesWidgets(
                onEdit: (bool wasModified) {
                  setState(() {
                    dataWasModified = wasModified || MoneyObject.isDataModified(_moneyObject);
                  });
                },
              ),
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
    return <Widget>[
      // Cancel
      DialogActionButton(
        text: 'Cancel',
        onPressed: () {
          Navigator.of(context).pop(false);
        },
      ),

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
          },
        ),
    ];
  }
}
