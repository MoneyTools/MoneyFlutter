import 'package:flutter/material.dart';
import 'package:money/app/core/widgets/icon_button.dart';
import 'package:money/app/data/models/constants.dart';

class SuggestionApproval extends StatefulWidget {
  const SuggestionApproval({
    super.key,
    required this.onApproved,
    required this.onRejected,
    required this.child,
  });

  final Widget child;
  final Function onApproved;
  final Function onRejected;

  @override
  SuggestionApprovalState createState() => SuggestionApprovalState();
}

class SuggestionApprovalState extends State<SuggestionApproval> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _iconOpacityAnimation;
  bool _isApproved = false;
  bool _isRejected = false;

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
    if (!shouldShowButton) {
      return _isRejected ? const SizedBox() : widget.child;
    }
    return FadeTransition(
      opacity: _iconOpacityAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Opacity(opacity: 0.5, child: widget.child),
          ),
          Padding(
            padding: const EdgeInsets.only(left: SizeForPadding.normal),
            child: MyIconButton(
              icon: Icons.thumb_up,
              tooltip: 'Approve category',
              hoverColor: Colors.green,
              onPressed: _approved,
            ),
          ),
          MyIconButton(
            icon: Icons.thumb_down,
            tooltip: 'It is not the right category',
            hoverColor: Colors.red,
            onPressed: _reject,
          ),
        ],
      ),
    );
  }

  bool get shouldShowButton => _isApproved == false && _isRejected == false;

  void _approved() {
    _animationController.forward().then((_) {
      setState(() {
        _isApproved = true;
        _isRejected = false;
        widget.onApproved();
      });
    });
  }

  void _reject() {
    _animationController.forward().then((_) {
      setState(() {
        _isRejected = true;
        _isApproved = false;
        widget.onRejected();
      });
    });
  }
}
