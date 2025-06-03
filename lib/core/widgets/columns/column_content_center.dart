import 'package:money/core/helpers/color_helper.dart';

// Exports
export 'package:money/core/widgets/widgets.dart';

class HeaderContentCenter extends StatelessWidget {
  const HeaderContentCenter({
    required this.text,
    required this.trailingWidget,
    super.key,
  });

  final String text;
  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    final Widget textWidget = Text(
      text,
      softWrap: false,
      textAlign: TextAlign.center,
      overflow: TextOverflow.clip,
      style: getTextTheme(
        context,
      ).labelSmall!.copyWith(color: getColorTheme(context).secondary),
    );

    if (trailingWidget == null) {
      return textWidget;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(child: textWidget),
        trailingWidget!,
      ],
    );
  }
}
