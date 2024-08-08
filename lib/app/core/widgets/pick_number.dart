import 'package:flutter/material.dart';
import 'package:money/app/core/widgets/gaps.dart';

class NumberPicker extends StatelessWidget {
  const NumberPicker({
    super.key,
    required this.title,
    required this.selectedNumber,
    required this.onChanged,
  });

  final Function(int) onChanged;
  final int selectedNumber;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: IntrinsicWidth(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('$title:'),
            gapSmall(),
            Expanded(
              child: DropdownButton<int>(
                value: selectedNumber,
                items: List.generate(
                  12,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1}'),
                  ),
                ),
                onChanged: (int? value) {
                  onChanged(value!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
