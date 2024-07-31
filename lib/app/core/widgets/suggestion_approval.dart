import 'package:flutter/material.dart';
import 'package:money/app/core/widgets/icon_button.dart';
import 'package:money/app/core/widgets/widgets.dart';
import 'package:money/app/data/models/constants.dart';

class SuggestionApproval extends StatefulWidget {
  const SuggestionApproval({
    super.key,
    required this.onApproved,
    required this.onChooseCategory,
    required this.child,
  });

  final Widget child;

  /// Optional - Approval button will show if there's a callback function
  final Function? onApproved;

  // Optional - Dropdown button
  final Function? onChooseCategory;

  @override
  SuggestionApprovalState createState() => SuggestionApprovalState();
}

class SuggestionApprovalState extends State<SuggestionApproval> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _iconOpacityAnimation;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _iconOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _iconOpacityAnimation,
      child: buildDashboardWidget(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Opacity(opacity: 0.5, child: widget.child),
            ),

            /// Optional Accept Suggestion
            if (widget.onApproved != null)
              Padding(
                padding: const EdgeInsets.only(left: SizeForPadding.normal),
                child: MyIconButton(
                  icon: Icons.thumb_up,
                  tooltip: 'Approve category',
                  hoverColor: Colors.green,
                  onPressed: _fadeOutAndApproved,
                ),
              ),

            // Optional Dropdown button
            if (widget.onChooseCategory != null)
              MyIconButton(
                icon: Icons.arrow_drop_down,
                tooltip: 'Select a category',
                hoverColor: Colors.blue,
                onPressed: () {
                  if (context.mounted) {
                    widget.onChooseCategory?.call(context);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  void _fadeOutAndApproved() {
    _animationController.forward().then((_) {
      setState(() {
        widget.onApproved?.call();
      });
    });
  }
}
