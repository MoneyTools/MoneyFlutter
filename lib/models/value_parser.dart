import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/helpers/date_helper.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/widgets/semantic_text.dart';

class ValuesParser {
  List<ValuesQuality> _values = [];
  String errorMessage = '';
  List<Widget> rows = [];

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
    if (lines.isNotEmpty) {
      for (var line in lines) {
        if (line.isNotEmpty) {
          add(attemptToExtractTriples(line));
        }
      }
    }
  }

  Widget buildPresentation(context) {
    List<Widget> rows = [];

    if (lines.isNotEmpty) {
      for (var line in lines) {
        rows.add(
          Row(children: [
            SizedBox(width: 100, child: line.date.valueAsDateWidget(context)),
            // Date
            SizedBox(width: 300, child: line.description.valueAsTextWidget(context)),
            // Description
            SizedBox(width: 100, child: line.amount.valueAsAmountWidget(context)),
            // Amount
          ]),
        );
      }
    }

    return rows.isEmpty
        ? buildWarning(context, 'Not input text')
        : Column(mainAxisAlignment: MainAxisAlignment.start, children: rows);
  }

  ValuesQuality attemptToExtractTriples(
    String line,
  ) {
    line.trim();
    List<String> threeValues = line.split(RegExp(r'\t|\s|;|,|\|')).where((token) => token.trim().isNotEmpty).toList();

    // Happy path
    // Date Description Amount
    if (threeValues.length >= 3) {
      String date = threeValues.first;
      String description = threeValues.sublist(1, threeValues.length - 1).join(' ');
      String amount = threeValues.last;
      return ValuesQuality(
          date: ValueQuality(date), description: ValueQuality(description), amount: ValueQuality(amount));
    }

    // Date Description
    if (threeValues.length == 2) {
      String date = threeValues.first;
      String description = threeValues.last;

      return ValuesQuality(
          date: ValueQuality(date), description: ValueQuality(description), amount: const ValueQuality(''));
    }

    // Date
    if (threeValues.length == 1) {
      String date = threeValues.first;

      return ValuesQuality(
          date: ValueQuality(date), description: const ValueQuality(''), amount: const ValueQuality(''));
    }

    return ValuesQuality.empty();
  }
}

class ValuesQuality {
  final ValueQuality date;
  final ValueQuality description;
  final ValueQuality amount;

  bool containsErrors() {
    return date.hasError || description.hasError || amount.hasError;
  }

  ValuesQuality({required this.date, required this.description, required this.amount});

  factory ValuesQuality.empty() {
    return ValuesQuality(
        date: const ValueQuality(''), description: const ValueQuality(''), amount: const ValueQuality(''));
  }
}

class ValueQuality {
  final String valueAsString;
  final String warningMessage = '';

  const ValueQuality(this.valueAsString);

  bool get hasError {
    return warningMessage.isNotEmpty;
  }

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
    if (valueAsString.isEmpty) {
      return buildWarning(context, '< no date >');
    }

    final parsedDate = attemptToGetDateFromText(valueAsString);
    if (parsedDate == null) {
      return buildWarning(context, valueAsString);
    }

    String dateText = DateFormat('yyyy-MM-dd').format(parsedDate);
    return SelectableText(dateText);
  }

  Widget valueAsTextWidget(final BuildContext context) {
    if (valueAsString.isEmpty) {
      return buildWarning(context, '< no description >');
    }
    return SelectableText(valueAsString);
  }

  Widget valueAsAmountWidget(final BuildContext context) {
    if (valueAsString.isEmpty) {
      return buildWarning(context, '< no amount >');
    }

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
