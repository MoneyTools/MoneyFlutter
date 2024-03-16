import 'package:flutter/material.dart';
import 'package:money/helpers/misc_helpers.dart';

class AdaptiveColumns extends StatelessWidget {
  final List<Widget> children;
  final double fieldHeight = 80;

  /// Constructor
  const AdaptiveColumns({
    super.key,
    required this.children,
  });

  @override
  Widget build(final BuildContext context) {
    if (isSmallDevice(context)) {
      return singleColumn();
    } else {
      return multiColumns();
    }
  }

  /// For small device list a phone simply use a single list of fields
  Widget singleColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  // optimize for larger screen into multiple columns
  Widget multiColumns() {
    return LayoutBuilder(
      builder: (final BuildContext context, final BoxConstraints constraints) {
        // from 2 to 4 column
        // fall back to single column
        double? optimalColumnWidth;
        if (constraints.maxWidth > 1000) {
          // this will generate a 3 columns layout
          optimalColumnWidth = constraints.maxWidth / 4;
        } else {
          if (constraints.maxWidth > 700) {
            // this will generate a 2 columns layout
            optimalColumnWidth = constraints.maxWidth / 3;
          }
        }

        List<Widget> sizedWidgets = children
            .map((widget) => SizedBox(
                  width: optimalColumnWidth,
                  height: fieldHeight,
                  child: widget,
                ))
            .toList();

        return Center(
          child: LayoutBuilder(
            builder: (final BuildContext context, final BoxConstraints constraints) {
              return Wrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 32.0,
                // Horizontal spacing between the children
                runSpacing: 24.0,
                // Vertical spacing between the children
                children: sizedWidgets,
              );
            },
          ),
        );
      },
    );
  }
}
