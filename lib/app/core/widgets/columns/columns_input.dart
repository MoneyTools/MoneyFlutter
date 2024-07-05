import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/app/controller/theme_controler.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/helpers/value_parser.dart';
import 'package:money/app/core/widgets/gaps.dart';
import 'package:money/app/core/widgets/ocr/ocr.dart';
import 'package:money/app/data/models/constants.dart';

class ColumnInput extends StatefulWidget {
  const ColumnInput({
    required this.inputText,
    required this.dateFormat,
    required this.onChange,
    super.key,
  });
  final String inputText;
  final Function(String) onChange;
  final String dateFormat;

  @override
  State<ColumnInput> createState() => _ColumnInputState();
}

class _ColumnInputState extends State<ColumnInput> {
  bool _singleColumn = true;
  final _focusNode = FocusNode();
  final _focusNode1 = FocusNode();
  final _focusNode2 = FocusNode();
  final _focusNode3 = FocusNode();
  bool _pauseTextSync = false;

  // Freestyle
  final _controllerSingleColumn = TextEditingController();

  // Date
  final _controllerColumn1 = TextEditingController();

  // Description
  final _controllerColumn2 = TextEditingController();

  // Amount
  final _controllerColumn3 = TextEditingController();

  @override
  void initState() {
    updateAllTextControllerContentFromRawText(widget.inputText);

    startListening();

    super.initState();
  }

  void startListening() {
    _controllerColumn1.addListener(_syncText);
    _controllerColumn2.addListener(_syncText);
    _controllerColumn3.addListener(_syncText);
  }

  void stopListening() {
    _controllerColumn1.removeListener(_syncText);
    _controllerColumn2.removeListener(_syncText);
    _controllerColumn3.removeListener(_syncText);
  }

  @override
  void dispose() {
    _controllerSingleColumn.dispose();
    stopListening();
    _controllerColumn1.dispose();
    _controllerColumn2.dispose();
    _controllerColumn3.dispose();
    super.dispose();
  }

  void updateAllTextControllerContentFromRawText(final String inputText) {
    _controllerSingleColumn.text = inputText;

    ValuesParser parser = ValuesParser(dateFormat: widget.dateFormat);
    parser.convertInputTextToTransactionList(
      context,
      widget.inputText,
    );

    _controllerColumn1.text = parser.getListOfDatesString().join('\n');
    _controllerColumn2.text = parser.getListOfDescriptionString().join('\n');
    _controllerColumn3.text = parser.getListOfAmountString().join('\n');
  }

  void fromOneToThreeColumn() {
    ValuesParser parser = ValuesParser(dateFormat: widget.dateFormat);
    parser.convertInputTextToTransactionList(
      context,
      _controllerSingleColumn.text,
    );

    _pauseTextSync = true;
    _controllerColumn1.text = parser.getListOfDatesString().join('\n');
    _controllerColumn2.text = parser.getListOfDescriptionString().join('\n');
    _controllerColumn3.text = parser.getListOfAmountString().join('\n');
    _pauseTextSync = false;
  }

  String getSingleBufferWithLatest3ColumnsText() {
    return ValuesParser.assembleIntoSinceTextBuffer(
      _controllerColumn1.text,
      _controllerColumn2.text,
      _controllerColumn3.text,
    );
  }

  String fromThreeToOneColumn() {
    _controllerSingleColumn.text = getSingleBufferWithLatest3ColumnsText();
    return _controllerSingleColumn.text;
  }

  int getMaxLineOfAllColumns() {
    int maxLines = 0;
    if (_focusNode1.hasFocus) {
      maxLines = max(maxLines, getLineCount(_controllerColumn1));
    }
    if (_focusNode2.hasFocus) {
      maxLines = max(maxLines, getLineCount(_controllerColumn2));
    }
    if (_focusNode3.hasFocus) {
      maxLines = max(maxLines, getLineCount(_controllerColumn3));
    }
    return maxLines;
  }

  int getLineCount(final TextEditingController controller) {
    if (controller.text.trim().isEmpty) {
      return 0;
    }
    return controller.text.trim().split('\n').length;
  }

  void _syncText() {
    if (_pauseTextSync) {
      return;
    }
    // suspend sync in to avoid re-entrance
    _pauseTextSync = true;

    // Get the number of lines of text in the first column
    int linesCount = getMaxLineOfAllColumns();

    // Update the text in the other columns to match the number of lines
    if (getLineCount(_controllerColumn1) != linesCount) {
      _controllerColumn1.text = adjustLineCount(_controllerColumn1.text, linesCount);
    }
    if (getLineCount(_controllerColumn2) != linesCount) {
      _controllerColumn2.text = adjustLineCount(_controllerColumn2.text, linesCount);
    }
    if (getLineCount(_controllerColumn3) != linesCount) {
      _controllerColumn3.text = adjustLineCount(_controllerColumn3.text, linesCount);
    }
    fromThreeToOneColumn();
    _pauseTextSync = false;
    notifyChanged();
  }

  String adjustLineCount(final String multiLineText, final lineCountNeeded) {
    var lines = multiLineText.split('\n');

    if (lines.length > lineCountNeeded) {
      // remove trailing empty lines
      if (lines.last.trim() == '') {
        lines.removeLast();
      }
    }
    return padList(lines, lineCountNeeded, '').join('\n');
  }

  @override
  Widget build(BuildContext context) {
    // fromTextInputTextControl(widget.inputText);
    return Column(
      children: [
        // ( 1 column | 3 columns )
        _buildColumnSelection(),

        gapLarge(),

        // Input text controls
        Expanded(
          child: _buildInputAsSingleOr3Columns(),
        ),
      ],
    );
  }

  Widget _buildColumnSelection() {
    return SegmentedButton<int>(
      style: const ButtonStyle(
        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
      ),
      segments: const <ButtonSegment<int>>[
        ButtonSegment<int>(
          value: 0,
          label: Text('1 column input'),
        ),
        ButtonSegment<int>(
          value: 1,
          label: Text('3 columns input'),
        ),
      ],
      selected: {_singleColumn ? 0 : 1},
      onSelectionChanged: (final Set<int> newSelection) {
        _singleColumn = newSelection.contains(0);
        if (_singleColumn) {
          fromThreeToOneColumn();
        } else {
          fromOneToThreeColumn();
        }
        notifyChanged();
        // setState(() {});
      },
    );
  }

  void notifyChanged() {
    widget.onChange(_controllerSingleColumn.text);
  }

  Widget _buildInputAsSingleOr3Columns() {
    if (_singleColumn) {
      return TextField(
        controller: _controllerSingleColumn,
        focusNode: _focusNode,
        autofocus: true,
        maxLines: null,
        // Set maxLines to null for multiline TextField
        decoration: getDecoration('Date; Description; Amount', getLineCount(_controllerSingleColumn)),
        onChanged: (final String _) {
          notifyChanged();
        },
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: columnTextInput('Date', _controllerColumn1, _focusNode1),
          ),
          Expanded(
            flex: 2,
            child: columnTextInput('Description', _controllerColumn2, _focusNode2),
          ),
          Expanded(
            flex: 1,
            child: columnTextInput('Amount', _controllerColumn3, _focusNode3),
          ),
        ],
      );
    }
  }

  Widget columnTextInput(
    final String title,
    final TextEditingController controller,
    final FocusNode focusNode,
  ) {
    final int lineCount = getLineCount(controller);

    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: SizeForPadding.large),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: false,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              fontSize: SizeForText.small,
              overflow: TextOverflow.fade,
            ),
            decoration: getDecoration(title, lineCount),
            inputFormatters: [
              TextInputFormatterRemoveEmptyLines(), // remove empty line
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: PasteOcr(textController: controller),
        ),
      ],
    );
  }

  Widget? getBadgeCounter(final int lineCount) {
    if (lineCount > 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: SizeForPadding.small),
        child: Text('$lineCount lines'),
      );
    }
    return null;
  }

  InputDecoration getDecoration(final String title, final int lineCount) {
    return InputDecoration(
      label: Badge(
        isLabelVisible: lineCount > 0,
        backgroundColor: ThemeController.to.primaryColor,
        offset: const Offset(20.0, 0),
        label: getBadgeCounter(lineCount),
        child: Text('$title '),
      ),
      border: const OutlineInputBorder(),
    );
  }
}

class TextInputFormatterRemoveEmptyLines extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String cleanedText = removeEmptyLines(newValue.text);
    if (newValue.text.endsWith('\n')) {
      cleanedText += '\n';
    }

    if (newValue.text != cleanedText) {
      return newValue.copyWith(text: cleanedText);
    }
    return newValue;
  }
}
