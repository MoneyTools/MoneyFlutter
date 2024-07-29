import 'package:flutter/material.dart';
import 'package:money/app/controller/theme_controler.dart';
import 'package:money/app/core/helpers/color_helper.dart';
import 'package:money/app/core/widgets/icon_button.dart';
import 'package:money/app/data/models/constants.dart';

class Box extends StatelessWidget {
  Box({
    super.key,
    this.title = '', // optional
    this.header, // optional
    this.footer, // optional
    this.color,
    this.width,
    this.height,
    this.margin,
    this.padding = 8,
    this.copyToClipboard,
    required this.child,
  }) {
    assert(title.isNotEmpty && header == null || title.isEmpty && header != null || title.isEmpty && header == null);
  }

  final Widget child;
  final Color? color;
  final Function? copyToClipboard;
  final Widget? footer;
  final Widget? header;
  final double? height;
  final double? margin;
  final double padding;
  final String title;
  final double? width;

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
        if (title.isNotEmpty || header != null) _buildBoxHeader(context),
        if (copyToClipboard != null)
          Positioned(
            top: -10,
            right: 0,
            child: _buildCopyToClipboardButton(),
          ),
        if (footer != null)
          Positioned(
            bottom: -5,
            right: 10,
            child: footer!,
          ),
      ],
    );
  }

  static Widget buildFooter(final String text) {
    return Card(
      elevation: 1,
      shadowColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SizeForPadding.normal,
        ),
        child: SelectableText(text),
      ),
    );
  }

  Widget _buildBoxHeader(final BuildContext context) {
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
                : SelectableText(
                    title,
                    style: getTextTheme(context).titleSmall,
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCopyToClipboardButton() {
    return Card(
      elevation: 1,
      shadowColor: Colors.transparent,
      child: MyIconButton(
        icon: Icons.copy_all_outlined,
        onPressed: () {
          copyToClipboard?.call();
        },
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

class BoxWithScrollingCotent extends StatelessWidget {
  const BoxWithScrollingCotent({super.key, required this.children, this.height});

  final List<Widget> children;
  final double? height;

  @override
  Widget build(final BuildContext context) {
    return Box(
      color: getColorTheme(context).surface,
      width: 300,
      height: height,
      // height: 300,
      margin: 10,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
