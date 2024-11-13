// ignore_for_file: unnecessary_this

import 'package:money/core/controller/selection_controller.dart';
import 'package:money/core/helpers/string_helper.dart';

/// List of string values in lower case associated to a fieldName
/// e.g.  'Color', ['blue', 'red']
class FieldFilter {
  FieldFilter({required this.fieldName, required this.strings}) {
    this.strings = strings;
  }

  final String fieldName;

  List<String> strings = [];

  @override
  String toString() {
    return '$fieldName=${strings.join("|")}';
  }

  bool contains(final String textToMatch) {
    final found = this.strings.firstWhereOrNull((text) {
      return stringCompareIgnoreCasing2(text, textToMatch) == 0;
    });
    return found != null;
  }
}

/// Group a lists of filters
class FieldFilters {
  FieldFilters([List<FieldFilter>? inputList]) {
    this.list = inputList ?? [];
  }

  FieldFilters.fromList(final List<String> inputList) {
    for (final pair in inputList) {
      final tokens = pair.split('=');
      if (tokens.length == 2) {
        list.add(
          FieldFilter(
            fieldName: tokens[0],
            strings: tokens[1].split('|'),
          ),
        );
      }
    }
  }

  List<FieldFilter> list = [];

  @override
  String toString() {
    return toStringList().join(', ');
  }

  void add(final FieldFilter ff) {
    list.add(ff);
  }

  void clear() {
    list.clear();
  }

  bool get isEmpty => list.isEmpty;

  bool get isNotEmpty => !isEmpty;

  int get length => list.length;

  List<String> toStringList() {
    return list.map((filter) => filter.toString()).toList();
  }
}
