// ignore_for_file: unnecessary_this

import 'package:money/app/controller/selection_controller.dart';
import 'package:money/app/core/helpers/string_helper.dart';

/// List of string values in lower case associated to a fieldName
/// e.g.  'Color', ['blue', 'red']
class FieldFilter {
  FieldFilter({required this.fieldName, required this.strings}) {
    this.strings = strings;
  }

  factory FieldFilter.fromJson(Map<String, dynamic> json) {
    return FieldFilter(
      fieldName: json['fieldName'] as String,
      strings: json['filterTextInLowerCase'].split('|'),
    );
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

  Map<String, dynamic> toJson() {
    return {
      'fieldName': fieldName,
      'filterTextInLowerCase': strings,
    };
  }
}

/// Group a lists of filters
class FieldFilters {
  FieldFilters([List<FieldFilter>? inputList]) {
    this.list = inputList ?? [];
  }

  FieldFilters.fromJson(final Map<String, dynamic> json) {
    list = (json['list'] as List<dynamic>).map((item) => FieldFilter.fromJson(item as Map<String, dynamic>)).toList();
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

  Map<String, dynamic> toJson() {
    return {
      'list': list.map((filter) => filter.toJson()).toList(),
    };
  }

  List<String> toStringList() {
    return list.map((filter) => filter.toString()).toList();
  }
}
