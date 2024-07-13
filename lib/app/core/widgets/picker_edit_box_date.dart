import 'package:flutter/material.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/widgets/my_text_input.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_view.dart';

class PickerEditBoxDate extends StatefulWidget {
  const PickerEditBoxDate({
    required this.onChanged,
    super.key,
    this.initialValue,
  });

  final String? initialValue;
  final Function(String) onChanged;

  @override
  PickerEditBoxDateState createState() => PickerEditBoxDateState();
}

class PickerEditBoxDateState extends State<PickerEditBoxDate> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialValue ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: MyTextInput(
            controller: _textController,
            onChanged: (final String value) {
              setState(() {
                widget.onChanged(value);
              });
            },
          ),
        ),
        IconButton(
          onPressed: () async {
            DateTime dateSelected = dateValueOrDefault(
              attemptToGetDateFromText(widget.initialValue ?? ''),
              defaultValueIfNull: DateTime.now(),
            );
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: dateSelected,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              _textController.text = dateToString(pickedDate);
              widget.onChanged(_textController.text);
            }
          },
          icon: const Icon(Icons.arrow_drop_down),
        ),
      ],
    );
  }
}
