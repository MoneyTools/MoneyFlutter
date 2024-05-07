import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';

class Box extends StatelessWidget {
  final String title;
  final double? margin;
  final double padding;
  final Color? color;
  final double? width;
  final double? height;
  final Widget child;

  const Box({
    super.key,
    this.title = '',
    this.color,
    this.width,
    this.height,
    this.margin,
    this.padding = 8,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry? adjustedMargin = margin == null ? null : EdgeInsets.all(margin!);
    // adjust the margin to account for the title bleeding out of the box
    if (title.isNotEmpty) {
      const increaseTopMarginBy = EdgeInsets.only(top: 13);
      if (adjustedMargin == null) {
        adjustedMargin = increaseTopMarginBy;
      } else {
        adjustedMargin.add(increaseTopMarginBy);
      }
    }

    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        Container(
          width: width,
          height: height,
          margin: adjustedMargin,
          padding: EdgeInsets.all(padding),
          constraints: BoxConstraints(
            minWidth: width ?? 500,
            maxWidth: width ?? 500,
          ),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8.0), // Bor
            border: Border.all(
              width: 1,
              color: Colors.grey.withOpacity(0.5),
            ),
          ),
          child: child,
        ),
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Card(
              elevation: 1,
              shadowColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  title,
                  style: getTextTheme(context).titleSmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
