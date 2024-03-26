import 'package:flutter/material.dart';
import 'package:money/widgets/picker_letter.dart';

showPopupSelection({
  required final BuildContext context,
  required final title,
  required final List<String> options,
  required final Function(String text) onSelected,
}) {
  showDialog(
    context: context,
    builder: (final BuildContext context) {
      return AlertDialog(
        title: Text(title),
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
  String _filterContains = '';
  String _filterStartWidth = '';
  List<String> list = [];
  List<String> uniqueLetters = [];

  @override
  void initState() {
    super.initState();
    applyFilter();

    for (final option in widget.options) {
      String singleLetter = ' ';

      if (option.isNotEmpty) {
        singleLetter = option[0].toUpperCase();
        if (!uniqueLetters.contains(singleLetter)) {
          uniqueLetters.add(singleLetter);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    _filterContains = value;
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
                      child: Text(
                        label,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PickerLetters(
                    options: uniqueLetters,
                    selected: _filterStartWidth,
                    onSelected: (String selected) {
                      setState(() {
                        _filterStartWidth = selected;
                        applyFilterStartsWidth();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void applyFilter() {
    _filterStartWidth = '';
    list = widget.options.where((option) => option.toLowerCase().contains(_filterContains.toLowerCase())).toList();
  }

  void applyFilterStartsWidth() {
    if (_filterStartWidth.isNotEmpty) {
      _filterContains = '';
      list = widget.options.where((option) => option.toUpperCase().startsWith(_filterStartWidth)).toList();
    }
  }
}
