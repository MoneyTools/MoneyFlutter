import 'package:flutter/material.dart';
import '../helpers.dart';
import 'caption_and_counter.dart';

class DetailsPanel extends StatelessWidget {
  final String title;
  final String description;

  const DetailsPanel({super.key, this.title = "", this.description = "Empty"});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Text(title), Text(description)],
    );
  }
}
