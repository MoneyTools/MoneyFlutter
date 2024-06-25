import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/controller/general_controller.dart';
import 'package:money/app/modules/home/sub_views/view_pending_changes/view_pending_changes.dart';

///
class BadgePendingChanges extends StatelessWidget {
  final int itemsAdded;
  final int itemsChanged;
  final int itemsDeleted;

  /// Constructor
  const BadgePendingChanges({
    super.key,
    required this.itemsAdded,
    required this.itemsChanged,
    required this.itemsDeleted,
  });

  @override
  Widget build(final BuildContext context) {
    if (itemsAdded == 0 && itemsChanged == 0 && itemsDeleted == 0) {
      // not change to report
      return const SizedBox();
    }

    return Tooltip(
      message: getTooltipText(),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // Adjust border radius
          ),
          backgroundColor: Colors.white,
        ),
        onPressed: () {
          PendingChanges.show(context);
        },
        child: getChangeLabel(context),
      ),
    );
  }

  Widget getChangeLabel(final BuildContext context) {
    List<Widget> widgets = [];
    TextStyle textStyle = Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 9, fontWeight: FontWeight.w900);
    if (GeneralController().ctlData.trackMutations.added.value > 0) {
      widgets.add(
        buildCounter(
            '+', GeneralController().ctlData.trackMutations.added.value, textStyle.copyWith(color: Colors.green)),
      );
    }

    if (GeneralController().ctlData.trackMutations.changed.value > 0) {
      widgets.add(buildCounter(
          '=', GeneralController().ctlData.trackMutations.changed.value, textStyle.copyWith(color: Colors.orange)));
    }

    if (GeneralController().ctlData.trackMutations.deleted.value > 0) {
      widgets.add(buildCounter(
          '-', GeneralController().ctlData.trackMutations.deleted.value, textStyle.copyWith(color: Colors.red)));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widgets,
    );
  }

  Widget buildCounter(final String prefix, final int value, final TextStyle textStyle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Text(
        prefix + getIntAsText(value),
        style: textStyle,
      ),
    );
  }

  String getTooltipText() {
    return 'Added: ${GeneralController().ctlData.trackMutations.added}\nModified: ${GeneralController().ctlData.trackMutations.changed}\nDeleted: ${GeneralController().ctlData.trackMutations.deleted}';
  }
}
