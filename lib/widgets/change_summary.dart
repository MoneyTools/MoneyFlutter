import 'package:flutter/material.dart';
import 'package:money/models/settings.dart';

///
class ChangeSummaryBadge extends StatelessWidget {
  final int itemsAdded;
  final int itemsDeleted;

  /// Constructor
  const ChangeSummaryBadge({
    super.key,
    required this.itemsAdded,
    required this.itemsDeleted,
  });

  @override
  Widget build(final BuildContext context) {
    if (itemsAdded == 0 && itemsDeleted == 0) {
      // not change to report
      return const SizedBox();
    }

    return Tooltip(
      message: getTooltipText(),
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inverseSurface, borderRadius: BorderRadius.circular(50)),
          child: getChangeLabel(context),
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

    if (Settings().trackMutations.deleted > 0) {
      widgets.add(buildCounter('-', Settings().trackMutations.deleted, textStyle.copyWith(color: Colors.red)));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
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
    return 'Items:\nAdded: ${Settings().trackMutations.added}\nDeleted: ${Settings().trackMutations.deleted}';
  }
}
