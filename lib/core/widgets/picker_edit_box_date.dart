import 'package:money/core/helpers/date_helper.dart';
import 'package:money/core/helpers/default_values.dart';
import 'package:money/core/widgets/icon_button.dart';
import 'package:money/core/widgets/my_text_input.dart';
import 'package:money/views/home/sub_views/adaptive_view/adaptive_list/list_view.dart';

class PickerEditBoxDate extends StatefulWidget {
  const PickerEditBoxDate({
    required this.onChanged,
    super.key,
    this.initialValue,
  });

  final String? initialValue;
  final void Function(String) onChanged;

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
      children: <Widget>[
        Expanded(
          child: MyTextInput(
            controller: _textController,
            border: false,
            onChanged: (final String value) {
              setState(() {
                widget.onChanged(value);
              });
            },
          ),
        ),
        MyIconButton(
          onPressed: () async {
            final DateTime dateSelected = valueOrDefaultDate(
              attemptToGetDateFromText(widget.initialValue ?? ''),
              defaultValueIfNull: DateTime.now(),
            );
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: dateSelected,
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              _textController.text = dateToString(pickedDate);
              widget.onChanged(_textController.text);
            }
          },
          icon: Icons.edit_calendar,
        ),
      ],
    );
  }
}
