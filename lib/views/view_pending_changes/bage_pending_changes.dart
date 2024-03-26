import 'package:flutter/material.dart';
import 'package:money/models/settings.dart';
import 'package:money/views/view_pending_changes/view_pending_changes.dart';

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
      child: IntrinsicWidth(
        child: SizedBox(
          height: 20,
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.withAlpha(0x22)),
              // You can add more styling properties here as needed
            ),
            onPressed: () {
              PendingChanges.show(context);
            },
            child: getChangeLabel(context),
          ),
        ),
      ),
    );
  }

  Widget getChangeLabel(final BuildContext context) {
    List<Widget> widgets = [];
    TextStyle textStyle = Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 9, fontWeight: FontWeight.w900);
    if (Settings().trackMutations.added > 0) {
      widgets.add(
        buildCounter('+', Settings().trackMutations.added, textStyle.copyWith(color: Colors.green)),
      );
    }

    if (Settings().trackMutations.changed > 0) {
      widgets.add(buildCounter('=', Settings().trackMutations.changed, textStyle.copyWith(color: Colors.orange)));
    }

    if (Settings().trackMutations.deleted > 0) {
      widgets.add(buildCounter('-', Settings().trackMutations.deleted, textStyle.copyWith(color: Colors.red)));
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
        prefix + value.toString(),
        style: textStyle,
      ),
    );
  }

  String getTooltipText() {
    return 'Added: ${Settings().trackMutations.added}\nModified: ${Settings().trackMutations.changed}\nDeleted: ${Settings().trackMutations.deleted}';
  }
}
