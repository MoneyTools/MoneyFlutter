import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/settings.dart';
import 'package:money/widgets/filter_input.dart';
import 'package:money/widgets/three_part_label.dart';

class ViewHeader extends StatelessWidget {
  final String title;
  final num count;
  final String description;
  final Widget? child;
  final void Function(String)? onFilterChanged;

  const ViewHeader({
    super.key,
    required this.title,
    required this.count,
    required this.description,
    this.onFilterChanged,
    this.child,
  });

  @override
  Widget build(final BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 8,
        bottom: 8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: LayoutBuilder(
        builder: (final BuildContext context, final BoxConstraints constraints) {
          if (Settings().isSmallDevice) {
            return _buildSmall(context);
          } else {
            return _buildLarge(context);
          }
        },
      ),
    );
  }

  Widget _buildLarge(final BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Column(
          children: <Widget>[
            Row(children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ThreePartLabel(text1: title, text2: getIntAsText(count.toInt())),
                  Text(description,
                      style: getTextTheme(context)
                          .bodySmall!
                          .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
              const Spacer(),
              if (onFilterChanged != null)
                SizedBox(
                  width: 200,
                  child: FilterInput(
                      hintText: 'Filter',
                      onChanged: (final String text) {
                        onFilterChanged!(text);
                      }),
                ),
            ]),
            if (child != null) child!,
          ],
        ));
  }

  Widget _buildSmall(final BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Column(
          children: <Widget>[ThreePartLabel(text1: title, text2: getIntAsText(count.toInt()))],
        ));
  }
}
