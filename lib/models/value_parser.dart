import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/widgets/semantic_text.dart';

class ValueParser {
  List<ValuesQuality> _values = [];
  String errorMessage = '';
  List<Widget> rows = [];
  Widget widgetToPresentToUser = const SizedBox();

  bool get isEmpty {
    return _values.isEmpty;
  }

  bool get isNotEmpty {
    return _values.isNotEmpty;
  }

  void add(final ValuesQuality item) {
    _values.add(item);
  }

  // ignore: unnecessary_getters_setters
  List<ValuesQuality> get lines {
    //
    return _values;
  }

  set lines(List<ValuesQuality> value) {
    //
    _values = value;
  }

  bool containsErrors() {
    return null != _values.firstWhereOrNull((element) => element.containsErrors());
  }

  void convertInputTextToTransactionList(
    BuildContext context,
    String inputString,
  ) {
    // start by fresh
    _values.clear();

    inputString = inputString.trim();
    List<String> lines = inputString.trim().split(RegExp(r'\r?\n|\r'));

    List<Widget> rows = [];

    if (lines.isNotEmpty) {
      for (var line in lines) {
        if (line.isNotEmpty) {
          ValuesQuality triples = ValuesQuality();

          if (attemptToExtractTriples(line, triples)) {
            add(triples);

            rows.add(
              Row(children: [
                SizedBox(width: 100, child: triples.values[0].valueAsDateWidget(context)),
                // Date
                SizedBox(width: 300, child: triples.values[1].valueAsTextWidget(context)),
                // Description
                SizedBox(width: 100, child: triples.values[2].valueAsAmountWidget(context)),
                // Amount
              ]),
            );
          }
        }
      }
    }

    widgetToPresentToUser = rows.isEmpty
        ? buildWarning(context, 'Not input text')
        : Column(mainAxisAlignment: MainAxisAlignment.start, children: rows);
  }

  bool attemptToExtractTriples(
    String line,
    ValuesQuality triples,
  ) {
    line.trim();
    List<String> threeValues = line.split(RegExp(r'\t|\s|;|,|\|')).where((token) => token.trim().isNotEmpty).toList();
    if (threeValues.length >= 3) {
      String date = threeValues.first;
      triples.add(ValueQuality(date));

      String description = threeValues.sublist(1, threeValues.length - 1).join(' ');
      triples.add(ValueQuality(description));

      String amount = threeValues.last;
      triples.add(ValueQuality(amount));

      return true;
    }
    return false;
  }
}

class ValuesQuality {
  List<ValueQuality> values = [];

  bool containsErrors() {
    return null != values.firstWhereOrNull((element) => element.warningMessage.isNotEmpty);
  }

  void add(ValueQuality value) {
    values.add(value);
  }
}

class ValueQuality {
  double? valueAsDouble;
  final String valueAsString;

  String warningMessage = '';

  ValueQuality(this.valueAsString);

  DateTime asDate() {
    return attemptToGetDateFromText(valueAsString) ?? DateTime.now();
  }

  String asString() {
    return valueAsString;
  }

  double asAmount() {
    return attemptToGetDoubleFromText(valueAsString) ?? 0.00;
  }

  Widget valueAsDateWidget(final BuildContext context) {
    final parsedDate = attemptToGetDateFromText(valueAsString);
    if (parsedDate == null) {
      return buildWarning(context, valueAsString);
    }

    String dateText = DateFormat('yyyy-MM-dd').format(parsedDate);
    return SelectableText(dateText);
  }

  Widget valueAsTextWidget(final BuildContext context) {
    return SelectableText(valueAsString);
  }

  Widget valueAsAmountWidget(final BuildContext context) {
    double? amount = attemptToGetDoubleFromText(valueAsString);
    if (amount == null) {
      return buildWarning(context, valueAsString);
    }
    return SelectableText(
      doubleToCurrency(amount),
      textAlign: TextAlign.right,
    );
  }
}
