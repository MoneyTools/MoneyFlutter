import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/helpers/value_parser.dart';
import 'package:money/app/core/widgets/columns/input_values.dart';
import 'package:money/app/core/widgets/gaps.dart';

class InputByColumns extends StatefulWidget {
  const InputByColumns({
    super.key,
    required this.inputText,
    required this.dateFormat,
    required this.currency,
    required this.onChange,
    required this.reverseAmountValue,
  });
  final String inputText;
  final Function(String) onChange;
  final String dateFormat;
  final String currency;
  final bool reverseAmountValue;

  @override
  State<InputByColumns> createState() => _InputByColumnsState();
}

class _InputByColumnsState extends State<InputByColumns> {
  bool _singleColumn = true;

  final Debouncer _debouncer = Debouncer();
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

  @override
  Widget build(BuildContext context) {
    // fromTextInputTextControl(widget.inputText);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ( 1 column | 3 columns )
        _buildColumnSelection(),

        gapMedium(),

        // Input text controls
        Expanded(
          child: _buildInputAsSingleOr3Columns(),
        ),
      ],
    );
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

    ValuesParser parser = ValuesParser(
      dateFormat: widget.dateFormat,
      currency: widget.currency,
      reverseAmountValue: widget.reverseAmountValue,
    );
    parser.convertInputTextToTransactionList(
      context,
      widget.inputText,
    );

    _controllerColumn1.text = parser.getListOfDatesString().join('\n');
    _controllerColumn2.text = parser.getListOfDescriptionString().join('\n');
    _controllerColumn3.text = parser.getListOfAmountString().join('\n');
  }

  void fromOneToThreeColumn() {
    ValuesParser parser = ValuesParser(
      dateFormat: widget.dateFormat,
      currency: widget.currency,
      reverseAmountValue: widget.reverseAmountValue,
    );
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
    return ValuesParser.assembleIntoSingleTextBuffer(
      _controllerColumn1.text,
      _controllerColumn2.text,
      _controllerColumn3.text,
    );
  }

  String fromThreeToOneColumn() {
    _controllerSingleColumn.text = getSingleBufferWithLatest3ColumnsText();
    return _controllerSingleColumn.text;
  }

  void _syncText() {
    _debouncer.run(() {
      if (_pauseTextSync) {
        return;
      }
      // suspend sync in to avoid re-entrance
      _pauseTextSync = true;

      fromThreeToOneColumn();
      _pauseTextSync = false;
      notifyChanged();
    });
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

  Widget _buildColumnSelection() {
    return SegmentedButton<int>(
      style: const ButtonStyle(
        visualDensity: VisualDensity(horizontal: -4, vertical: -4),
      ),
      segments: const <ButtonSegment<int>>[
        ButtonSegment<int>(
          value: 0,
          label: Text('1 column'),
        ),
        ButtonSegment<int>(
          value: 1,
          label: Text('3 columns'),
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
      // 1 column
      return Center(child: InputValues(title: 'Date; Description; Amount', controller: _controllerSingleColumn));
    }

    // 3 columns
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: InputValues(title: 'Date', controller: _controllerColumn1),
        ),
        Expanded(
          flex: 2,
          child: InputValues(title: 'Description', controller: _controllerColumn2),
        ),
        Expanded(
          flex: 1,
          child: InputValues(title: 'Amount', controller: _controllerColumn3),
        ),
      ],
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
