import 'package:flutter/material.dart';

showPopupSelection({
  required final BuildContext context,
  required final List<String> options,
  required final Function(String text) onSelected,
}) {
  showDialog(
    context: context,
    builder: (final BuildContext context) {
      return AlertDialog(
        content: SizedBox(
          width: 400,
          height: 500,
          child: PickerPanel(
              options: options,
              onSelected: (final String selectedValue) {
                onSelected(selectedValue);
              }),
        ),
      );
    },
  );
}

class PickerPanel extends StatefulWidget {
  final List<String> options;
  final Function(String selectedValue) onSelected;

  const PickerPanel({
    super.key,
    required this.options,
    required this.onSelected,
  });

  @override
  State<PickerPanel> createState() => _PickerPanelState();
}

class _PickerPanelState extends State<PickerPanel> {
  String _filterText = '';
  List<String> list = [];

  @override
  void initState() {
    super.initState();
    applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.zero,
            isDense: true,
            prefixIcon: Icon(Icons.search),
            labelText: 'Filter',
            border: OutlineInputBorder(),
          ),
          onChanged: (final String value) {
            setState(() {
              _filterText = value;
              applyFilter();
            });
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              String label = list[index];
              return TextButton(
                onPressed: () {
                  widget.onSelected(label);
                  Navigator.of(context).pop();
                },
                child: Text(label),
              );
            },
          ),
        ),
      ],
    );
  }

  void applyFilter() {
    list = widget.options.where((option) => option.toLowerCase().contains(_filterText.toLowerCase())).toList();
  }
}
