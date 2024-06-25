import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/semantic_text.dart';
import 'package:money/app/data/models/date_range.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';

class ValueQuality {
  final String valueAsString;
  final String warningMessage = '';

  const ValueQuality(this.valueAsString);

  bool get hasError {
    return warningMessage.isNotEmpty;
  }

  double asAmount() {
    return attemptToGetDoubleFromText(valueAsString) ?? 0.00;
  }

  DateTime asDate() {
    return attemptToGetDateFromText(valueAsString) ?? DateTime.now();
  }

  String asString() {
    return valueAsString;
  }

  Widget valueAsAmountWidget(final BuildContext context) {
    if (valueAsString.isEmpty) {
      return buildWarning(context, '< no amount >');
    }

    double? amount = attemptToGetDoubleFromText(valueAsString);
    if (amount == null) {
      return buildWarning(context, valueAsString);
    }
    return widgetDoubleAsCurrency(amount);
  }

  static SelectableText widgetDoubleAsCurrency(final double amount) {
    return SelectableText(
      doubleToCurrency(amount),
      textAlign: TextAlign.right,
      style: TextStyle(color: amount > 0 ? Colors.green : Colors.red),
    );
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
}

class ValuesQuality {
  bool exist = false;
  final ValueQuality date;
  final ValueQuality description;
  final ValueQuality amount;

  ValuesQuality({required this.date, required this.description, required this.amount});

  factory ValuesQuality.empty() {
    return ValuesQuality(
        date: const ValueQuality(''), description: const ValueQuality(''), amount: const ValueQuality(''));
  }

  bool containsErrors() {
    return date.hasError || description.hasError || amount.hasError;
  }

  bool checkIfExistAlready() {
    exist = isTransactionAlreadyInTheSystem(
      dateTime: date.asDate(),
      payeeAsText: description.asString(),
      amount: amount.asAmount(),
    );
    return exist;
  }

  static DateRange getDateRange(final List<ValuesQuality> list) {
    DateRange range = DateRange();
    for (final v in list) {
      range.inflate(v.date.asDate());
    }
    return range;
  }

  static void sort(final List<ValuesQuality> list, final int sortBy, final bool ascending) {
    list.sort((a, b) {
      switch (sortBy) {
        case 0:
          return sortByDate(a.date.asDate(), b.date.asDate(), ascending);
        case 1:
          return sortByString(a.description.asString(), b.description.asString(), ascending);
        case 2:
          return sortByValue(a.amount.asAmount(), b.amount.asAmount(), ascending);
      }
      return 0;
    });
  }
}

/// The `ValuesParser` class is responsible for parsing input data and extracting
/// relevant values from it. It provides methods for parsing, transforming, and
/// validating the extracted values.
class ValuesParser {
  List<ValuesQuality> _values = [];
  String errorMessage = '';
  List<Widget> rows = [];

  bool get isEmpty {
    return onlyNewTransactions.isEmpty;
  }

  bool get isNotEmpty {
    return !isEmpty;
  }

  static void evaluateExistence(List<ValuesQuality> values) {
    for (final vq in values) {
      vq.checkIfExistAlready();
    }
  }

  // ignore: unnecessary_getters_setters
  List<ValuesQuality> get lines {
    //
    return _values;
  }

  List<ValuesQuality> get onlyNewTransactions {
    return _values.where((item) => !item.exist).toList();
  }

  set lines(List<ValuesQuality> value) {
    //
    _values = value;
  }

  void add(final ValuesQuality item) {
    _values.add(item);
  }

  ValuesQuality attemptToExtractTriples(
    String line,
  ) {
    String date = '';
    String description = '';
    String amount = '';

    line.trim();
    List<String> threeValues = line.split(RegExp(r'\t|\s|;|\|')).where((token) => token.trim().isNotEmpty).toList();

    // Happy path
    // Date Description Amount
    switch (threeValues.length) {
      case 2:
        DateTime? possibleDate = attemptToGetDateFromText(threeValues.first);
        if (possibleDate == null) {
          description = threeValues.first;
        } else {
          date = threeValues.first;
        }

        double? possibleAmount = attemptToGetDoubleFromText(threeValues.last);
        if (possibleAmount == null) {
          description = threeValues.last;
        } else {
          amount = threeValues.last;
        }
      case 1:
        double? possibleAmount = attemptToGetDoubleFromText(threeValues.first);
        if (possibleAmount == null) {
          date = threeValues.first;
        } else {
          amount = possibleAmount.toString();
        }
      case 0:
        return ValuesQuality.empty();
      case 3:
      default:
        date = threeValues.first;
        description = threeValues.sublist(1, threeValues.length - 1).join(' ');
        amount = threeValues.last;
    }

    return ValuesQuality(
      date: ValueQuality(date),
      description: ValueQuality(description),
      amount: ValueQuality(amount),
    );
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
    List<List<String>> lines = getLinesFromRawText(inputString);
    if (lines.isNotEmpty) {
      for (var line in lines) {
        if (line.isNotEmpty) {
          add(attemptToExtractTriples(line.join(';')));
        }
      }
    }
  }

  List<String> getListOfAmountString() {
    final List<String> list = [];
    for (final value in _values) {
      list.add(value.amount.valueAsString);
    }
    return list;
  }

  List<String> getListOfDatesString() {
    final List<String> list = [];
    for (final value in _values) {
      list.add(value.date.valueAsString);
    }
    return list;
  }

  List<String> getListOfDescriptionString() {
    final List<String> list = [];
    for (final value in _values) {
      list.add(value.description.valueAsString);
    }
    return list;
  }

  static String assembleIntoSinceTextBuffer(
    final String multiStringDates,
    final String multiStringDescriptions,
    final String multiStringAmounts,
  ) {
    int maxLines = 0;
    List<String> dates = multiStringDates.split('\n');
    maxLines = max(maxLines, dates.length);
    List<String> descriptions = multiStringDescriptions.split('\n');
    maxLines = max(maxLines, descriptions.length);
    List<String> amounts = multiStringAmounts.split('\n');
    maxLines = max(maxLines, amounts.length);

    // Make them all the same length
    dates = padList(dates, maxLines, '');
    descriptions = padList(descriptions, maxLines, '');
    amounts = padList(amounts, maxLines, '');

    String singleText = '';
    for (int line = 0; line < maxLines; line++) {
      singleText += '${dates[line]}; ${descriptions[line]}; ${amounts[line]}\n';
    }
    return singleText;
  }
}

bool isTransactionAlreadyInTheSystem({
  required final DateTime dateTime,
  required final String payeeAsText,
  required final double amount,
}) {
  return getTransactionAlreadyInTheSystem(
        dateTime: dateTime,
        payeeAsText: payeeAsText,
        amount: amount,
      ) !=
      null;
}

Transaction? getTransactionAlreadyInTheSystem({
  required final DateTime dateTime,
  required final String payeeAsText,
  required final double amount,
}) {
  return Data().transactions.findExistingTransaction(
        dateTime: dateTime,
        payeeAsText: payeeAsText,
        amount: amount,
      );
}
