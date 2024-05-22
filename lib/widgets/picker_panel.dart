import 'dart:math';

import 'package:flutter/material.dart';
import 'package:money/helpers/color_helper.dart';
import 'package:money/widgets/gaps.dart';
import 'package:money/widgets/picker_letter.dart';

showPopupSelection({
  required final BuildContext context,
  required final title,
  required final List<String> items,
  required final String selectedItem,
  required final Function(String text) onSelected,
}) {
  showDialog(
    context: context,
    builder: (final BuildContext context) {
      return AlertDialog(
        title: Text(title),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          side: BorderSide(
            color: getColorTheme(context).primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        content: Container(
          constraints: const BoxConstraints(
            minHeight: 500,
            maxHeight: 700,
          ),
          width: 400,
          child: PickerPanel(
              options: items,
              selectedItem: selectedItem,
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
  final String selectedItem;
  final Function(String selectedValue) onSelected;
  final double itemHeight;

  const PickerPanel({
    super.key,
    required this.options,
    required this.selectedItem,
    required this.onSelected,
    this.itemHeight = 40,
  });

  @override
  State<PickerPanel> createState() => _PickerPanelState();
}

class _PickerPanelState extends State<PickerPanel> {
  String _filterByTextAnywhere = '';
  String _filterStartWidth = '';
  List<String> list = [];
  List<String> uniqueLetters = [];
  final ScrollController _scrollController = ScrollController();
  int indexToScrollTo = -1;

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

    // Schedule a callback to scroll to the element after the next frame is rendered
    if (widget.selectedItem.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Find the index of the item that matches the value "Item 3"
        indexToScrollTo = widget.options.indexOf(widget.selectedItem);
        if (indexToScrollTo != -1) {
          indexToScrollTo -= 2; // back up two elements to make it a nicer position
          indexToScrollTo = max(0, indexToScrollTo); // make sure we are not outside the bounds
          _scrollController.jumpTo((indexToScrollTo * widget.itemHeight));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.zero,
            isDense: true,
            prefixIcon: Icon(Icons.search),
            labelText: 'Filter',
            border: OutlineInputBorder(),
          ),
          onChanged: (final String value) {
            setState(() {
              _filterByTextAnywhere = value;
              applyFilter();
            });
          },
        ),
        gapLarge(),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  child: PickerLetters(
                    options: uniqueLetters,
                    selected: _filterStartWidth,
                    onSelected: (String selected) {
                      setState(() {
                        _filterStartWidth = selected;
                        applyFilter();
                      });
                    },
                  ),
                ),
              ),
              gapMedium(),
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  controller: _scrollController,
                  itemExtent: widget.itemHeight,
                  itemBuilder: (context, index) {
                    String label = list[index];
                    bool isSelected = label == widget.selectedItem;
                    return GestureDetector(
                      onTap: () {
                        widget.onSelected(label);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: widget.itemHeight,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: isSelected ? getColorTheme(context).primaryContainer : Colors.transparent,
                          // show a bottom line if not the last item
                          border: index == list.length - 1
                              ? null
                              : Border(
                                  bottom: BorderSide(
                                      color: getColorTheme(context).onSurfaceVariant.withOpacity(0.2), width: 1),
                                ),
                        ),
                        child: Text(label, style: const TextStyle(fontSize: 12)),
                        // contentPadding: EdgeInsets.zero,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void applyFilter() {
    list = widget.options.where((final String option) {
      if (_filterStartWidth.isNotEmpty && !option.toUpperCase().startsWith(_filterStartWidth)) {
        return false;
      }

      if (_filterByTextAnywhere.isNotEmpty && !option.toLowerCase().contains(_filterByTextAnywhere.toLowerCase())) {
        return false;
      }

      return true;
    }).toList();
  }
}
