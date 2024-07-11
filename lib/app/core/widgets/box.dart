import 'package:flutter/material.dart';
import 'package:money/app/controller/theme_controler.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/data/models/constants.dart';

class Box extends StatelessWidget {
  Box({
    super.key,
    this.title = '', // optional
    this.header, // optional
    this.color,
    this.width,
    this.height,
    this.margin,
    this.padding = 8,
    required this.child,
  }) {
    assert(title.isNotEmpty && header == null || title.isEmpty && header != null || title.isEmpty && header == null);
  }

  final String title;
  final Widget? header;
  final double? margin;
  final double padding;
  final Color? color;
  final double? width;
  final double? height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry? adjustedMargin = margin == null ? null : EdgeInsets.all(margin!);
    // adjust the margin to account for the title bleeding out of the box
    if (title.isNotEmpty || header != null) {
      const increaseTopMarginBy = EdgeInsets.only(top: SizeForPadding.large);
      if (adjustedMargin == null) {
        adjustedMargin = increaseTopMarginBy;
      } else {
        adjustedMargin.add(increaseTopMarginBy);
      }
    }

    return Stack(
      alignment: AlignmentDirectional.topStart,
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
        if (title.isNotEmpty || header != null) _buildHeader(context),
      ],
    );
  }

  Widget _buildHeader(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SizeForPadding.normal,
      ),
      child: IntrinsicWidth(
        child: Card(
          elevation: 1,
          shadowColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SizeForPadding.medium,
            ),
            child: title.isEmpty
                ? header
                : Text(
                    title,
                    style: getTextTheme(context).titleSmall,
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ),
    );
  }
}

Widget buildHeaderTitleAndCounter(
  final BuildContext context,
  final String title,
  final String badgeText,
) {
  Widget boxHeader = Badge(
    isLabelVisible: badgeText.isNotEmpty,
    backgroundColor: ThemeController.to.primaryColor,
    offset: const Offset(20.0, 0),
    label: getBadgeText(badgeText),
    child: Text(title),
  );
  return boxHeader;
}

Widget getBadgeText(final String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: SizeForPadding.small),
    child: Text(text, style: const TextStyle(fontSize: SizeForText.small)),
  );
}
