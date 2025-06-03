import 'dart:math';

import 'package:money/core/helpers/color_helper.dart';
import 'package:money/core/widgets/dialog/dialog.dart';
import 'package:money/core/widgets/gaps.dart';
import 'package:money/core/widgets/my_text_input.dart';
import 'package:money/core/widgets/picker_letter.dart';
import 'package:money/core/widgets/token_text.dart';
import 'package:money/data/models/constants.dart';

void showPopupSelection({
  required BuildContext context,
  required String title,
  required List<String> items,
  required String selectedItem,
  required void Function(String text) onSelected,
  bool showLetterPicker = true,
  TokenTextStyle tokenTextStyle = const TokenTextStyle(
    separatorPaddingLeft: SizeForPadding.nano,
    separatorPaddingRight: SizeForPadding.nano,
  ),
  bool rightAligned = false,
  double? width = 200,
}) {
  adaptiveScreenSizeDialog(
    context: context,
    title: title,
    child: PickerPanel(
      width: width,
      showLetterPicker: showLetterPicker,
      tokenTextStyle: tokenTextStyle,
      rightAligned: rightAligned,
      options: items,
      selectedItem: selectedItem,
      onSelected: onSelected,
    ),
    actionButtons: <Widget>[],
  );
}

class PickerPanel extends StatefulWidget {
  const PickerPanel({
    required this.options,
    required this.selectedItem,
    required this.onSelected,
    super.key,
    this.width = 200,
    this.itemHeight = 40,
    this.showLetterPicker = true,
    this.tokenTextStyle = const TokenTextStyle(),
    this.rightAligned = false,
  });

  final double itemHeight;
  final void Function(String selectedValue) onSelected;
  final List<String> options;
  final bool rightAligned;
  final String selectedItem;
  final bool showLetterPicker;
  final TokenTextStyle tokenTextStyle;
  final double? width;

  @override
  PickerPanelState createState() => PickerPanelState();
}

class PickerPanelState extends State<PickerPanel> {
  List<String> filteredList = <String>[];
  int indexToScrollTo = -1;
  List<String> uniqueLetters = <String>[];

  final ScrollController _scrollController = ScrollController();

  String _filterByTextAnywhere = '';
  String _filterStartWith = '';

  @override
  void initState() {
    super.initState();
    _initializeFilters();
    _populateUniqueLetters();
    _scheduleScrollToSelectedItem();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildFilterTextField(),
          gapLarge(),
          Expanded(child: _buildPickerContent(context)),
        ],
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      filteredList = widget.options.where((String option) {
        final bool matchesStart = _filterStartWith.isEmpty || option.toUpperCase().startsWith(_filterStartWith);
        final bool matchesAnywhere =
            _filterByTextAnywhere.isEmpty ||
            option.toLowerCase().contains(
              _filterByTextAnywhere.toLowerCase(),
            );
        return matchesStart && matchesAnywhere;
      }).toList();
    });
  }

  Widget _buildFilterTextField() {
    return MyTextInput(
      key: MyKeys.keyHeaderFilterTextInput,
      hintText: 'Filter',
      onChanged: (String value) {
        setState(() {
          _filterByTextAnywhere = value;
          _applyFilters();
        });
      },
    );
  }

  Widget _buildFilteredList(BuildContext context) {
    return ListView.builder(
      itemCount: filteredList.length,
      controller: _scrollController,
      itemExtent: widget.itemHeight,
      itemBuilder: (BuildContext context, int index) {
        final String label = filteredList[index];
        final bool isSelected = label == widget.selectedItem;
        return _buildPickerItem(context, label, isSelected, index);
      },
    );
  }

  Widget _buildLetterPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeForPadding.medium),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: PickerLetters(
            options: uniqueLetters,
            selected: _filterStartWith,
            onSelected: (String selected) {
              setState(() {
                _filterStartWith = selected;
                _applyFilters();
                _scrollController.jumpTo(0);
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPickerContent(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: _buildFilteredList(context)),
        if (widget.showLetterPicker) _buildLetterPicker(),
      ],
    );
  }

  Widget _buildPickerItem(
    BuildContext context,
    String label,
    bool isSelected,
    int index,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        widget.onSelected(label);
      },
      child: Container(
        height: widget.itemHeight,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: isSelected ? getColorTheme(context).primaryContainer : Colors.transparent,
          border: index == filteredList.length - 1
              ? null
              : Border(
                  bottom: BorderSide(
                    color: getColorTheme(
                      context,
                    ).onSurfaceVariant.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
        ),
        child: SingleChildScrollView(
          reverse: widget.rightAligned,
          scrollDirection: Axis.horizontal,
          child: TokenText(label, style: widget.tokenTextStyle),
        ),
      ),
    );
  }

  void _initializeFilters() {
    setState(() {
      filteredList = widget.options;
    });
  }

  void _populateUniqueLetters() {
    for (final String option in widget.options) {
      if (option.isNotEmpty) {
        final String singleLetter = option[0].toUpperCase();
        if (!uniqueLetters.contains(singleLetter)) {
          uniqueLetters.add(singleLetter);
        }
      }
    }
  }

  void _scheduleScrollToSelectedItem() {
    if (widget.selectedItem.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        indexToScrollTo = widget.options.indexOf(widget.selectedItem);
        if (indexToScrollTo != -1) {
          indexToScrollTo = max(0, indexToScrollTo - 2);
          _scrollController.jumpTo(indexToScrollTo * widget.itemHeight);
        }
      });
    }
  }
}
