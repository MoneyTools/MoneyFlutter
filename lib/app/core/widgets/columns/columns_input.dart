import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/helpers/value_parser.dart';
import 'package:money/app/core/widgets/columns/input_values.dart';
import 'package:money/app/data/models/constants.dart';

class InputByColumns extends StatefulWidget {
  const InputByColumns({
    super.key,
    required this.inputText,
    required this.dateFormat,
    required this.currency,
    required this.onChange,
    required this.reverseAmountValue,
  });

  final String currency;
  final String dateFormat;
  final String inputText;
  final Function(String) onChange;
  final bool reverseAmountValue;

  @override
  State<InputByColumns> createState() => _InputByColumnsState();
}

class _InputByColumnsState extends State<InputByColumns> {
  // Date
  final _controllerColumn1 = TextEditingController();

  // Description
  final _controllerColumn2 = TextEditingController();

  // Amount
  final _controllerColumn3 = TextEditingController();

  // Freestyle
  final _controllerSingleColumn = TextEditingController();

  final Debouncer _debouncer = Debouncer();
  bool _freeStyleInput = false; // use 3 columns by default
  bool _pauseTextSync = false;

  @override
  void dispose() {
    _controllerSingleColumn.dispose();
    _stopListening();
    _controllerColumn1.dispose();
    _controllerColumn2.dispose();
    _controllerColumn3.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _updateAllTextControllerContentFromRawText(widget.inputText);

    _startListening();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: _freeStyleInput ? 1 : 0,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(
                child: Text('3 columns'),
              ),
              Tab(
                child: Text('Free style'),
              ),
            ],
            onTap: (index) {
              _freeStyleInput = index == 1;
              if (_freeStyleInput) {
                _fromThreeToOneColumn();
              } else {
                _fromOneToThreeColumn();
              }
              _notifyChanged();
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: SizeForPadding.normal),
              child: TabBarView(
                children: [
                  // Content for 3 columns
                  _buildInputFor3Columns(),
                  // Content for 1 column
                  _buildInputFor1Column(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1 column
  Widget _buildInputFor1Column() {
    return Center(
      child: InputValues(
        title: 'Date; Description; Amount',
        controller: _controllerSingleColumn,
        allowedCharacters: '0123456789/_.\\',
      ),
    );
  }

  // 3 columns
  Widget _buildInputFor3Columns() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: InputValues(
            title: 'Date',
            controller: _controllerColumn1,
            allowedCharacters: '0123456789/_.\\',
          ),
        ),
        Expanded(
          flex: 2,
          child: InputValues(
            title: 'Description',
            controller: _controllerColumn2,
            allowedCharacters: '',
          ),
        ),
        Expanded(
          flex: 1,
          child: InputValues(
            title: 'Amount',
            controller: _controllerColumn3,
            allowedCharacters:
                '0123456789,.()-+', // amounts like 12.34 12,34 1,234.56 1.234,56 +1.234,56 -1,234.56 (1,234.56)
          ),
        ),
      ],
    );
  }

  void _fromOneToThreeColumn() {
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

  String _fromThreeToOneColumn() {
    _controllerSingleColumn.text = _getSingleBufferWithLatest3ColumnsText();
    return _controllerSingleColumn.text;
  }

  String _getSingleBufferWithLatest3ColumnsText() {
    return ValuesParser.assembleIntoSingleTextBuffer(
      _controllerColumn1.text,
      _controllerColumn2.text,
      _controllerColumn3.text,
    );
  }

  void _notifyChanged() {
    widget.onChange(_controllerSingleColumn.text);
  }

  void _startListening() {
    _controllerColumn1.addListener(_syncText);
    _controllerColumn2.addListener(_syncText);
    _controllerColumn3.addListener(_syncText);
  }

  void _stopListening() {
    _controllerColumn1.removeListener(_syncText);
    _controllerColumn2.removeListener(_syncText);
    _controllerColumn3.removeListener(_syncText);
  }

  void _syncText() {
    _debouncer.run(() {
      if (_pauseTextSync) {
        return;
      }
      // suspend sync in to avoid re-entrance
      _pauseTextSync = true;

      _fromThreeToOneColumn();
      _pauseTextSync = false;
      _notifyChanged();
    });
  }

  void _updateAllTextControllerContentFromRawText(final String inputText) {
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
