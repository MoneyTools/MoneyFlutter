import 'package:money/core/widgets/widgets.dart';
import 'package:money/views/home/sub_views/app_scaffold.dart';

///
class FullScreenDialog extends StatefulWidget {
  const FullScreenDialog({
    required this.title,
    required this.content,
    super.key,
    this.actionButtons = const [],
  });

  final List<Widget> actionButtons;
  final Widget content;
  final String title;

  @override
  FullScreenDialogState createState() => FullScreenDialogState();
}

class FullScreenDialogState extends State<FullScreenDialog> {
  @override
  Widget build(BuildContext context) {
    return myScaffold(
      context,
      AppBar(
        title: Text(widget.title),
      ),
      Column(
        children: [
          Expanded(
            child: widget.content,
          ),
          if (widget.actionButtons.isNotEmpty)
            OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 8,
              overflowAlignment: OverflowBarAlignment.end,
              overflowDirection: VerticalDirection.down,
              overflowSpacing: 0,
              children: widget.actionButtons,
            ),
        ],
      ),
    );
  }
}

class AutoSizeDialog extends StatelessWidget {
  const AutoSizeDialog({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    ShapeBorder? dialogShape;
    EdgeInsets? insetPadding;

    if (context.isWidthSmall) {
      insetPadding = EdgeInsets.zero;
    } else {
      dialogShape = RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        side: BorderSide(
          width: 2.0, // Adjust border width as needed
          color: Theme.of(context).dividerColor, // Set your desired border color here
        ),
      );
      insetPadding = const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0);
    }

    return Dialog(
      shape: dialogShape,
      insetPadding: insetPadding,
      // Set elevation to 0 to remove default shadow
      elevation: 0.0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}
