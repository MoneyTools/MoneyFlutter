import 'package:flutter/material.dart';

/// a basic text that is centered in the parent container
class CenterMessage extends StatelessWidget {
  final String message;

  /// constructor
  const CenterMessage({super.key, required this.message});

  @override
  Widget build(final BuildContext context) {
    return Center(
      child: Text(message),
    );
  }

  factory CenterMessage.noTransaction() {
    return const CenterMessage(message: 'No transactions.');
  }
}
