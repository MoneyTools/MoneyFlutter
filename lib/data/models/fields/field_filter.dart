// ignore_for_file: unnecessary_this

import 'package:money/core/controller/selection_controller.dart';
import 'package:money/core/helpers/ranges.dart';
import 'package:money/core/helpers/string_helper.dart';

/// List of string values in lower case associated to a fieldName
/// e.g.  'Color', ['blue', 'red']
class FieldFilter {
  /// Constructs a new instance of the `FieldFilter` class.
  ///
  /// The `fieldName` parameter specifies the name of the field.
  /// The `strings` parameter is a list of dynamic values representing the string values associated with the field.
  /// The `byDateRange` parameter is a boolean indicating whether the filter is based on a date range. It defaults to `false`.
  FieldFilter({
    required this.fieldName,
    required this.strings,
    this.byDateRange = false,
  });

  /// Creates a new `FieldFilter` instance from a JSON map.
  ///
  /// The JSON map is expected to have the following keys:
  /// - `fieldName`: a `String` representing the name of the field.
  /// - `strings`: a list of `dynamic` values representing the string values associated with the field.
  /// - `byDateRange`: a `bool` indicating whether the filter is based on a date range.
  ///
  /// The `byDateRange` value is set to `false` if it is not present in the JSON map.
  factory FieldFilter.fromJson(Map<String, dynamic> json) {
    return FieldFilter(
      fieldName: json['fieldName'] as String,
      strings: List<dynamic>.from(json['strings']),
      byDateRange: json['byDateRange'] as bool? ?? false,
    );
  }

  // Optionally, instead of absolute dates, you can use date range
  // the list of string will be expected to contain only two text representation of dates 'YYYY-MM-DD'
  // the first one is the Min Date and the second Max Date
  final bool byDateRange;

  /// name of the field
  final String fieldName;

  /// the list of string that the field must match when filtering
  final List<dynamic> strings;

  /// Returns a string representation of the `FieldFilter` instance in the format:
  /// `'$fieldName=${strings.join("|")}byDateRange:$byDateRange'`.
  ///
  /// This method is used for debugging and logging purposes.
  @override
  String toString() {
    return toJsonString();
  }

  DateRange get asDateRange => DateRange.fromText(strings.first, strings.last);

  /// Checks if the given [value] is contained in the [strings] list, ignoring case.
  ///
  /// Returns `true` if a string in the [strings] list matches the [value] ignoring case, `false` otherwise.
  bool contains(final dynamic value) {
    final String? found = this.strings.firstWhereOrNull((text) {
      return stringCompareIgnoreCasing2(text, value as String) == 0;
    });
    return found != null;
  }

  /// Converts the `FieldFilter` instance to a JSON map.
  ///
  /// The resulting map contains the following keys:
  /// - `fieldName`: a `String` representing the name of the field.
  /// - `strings`: a list of `dynamic` values representing the string values associated with the field.
  /// - `byDateRange`: a `bool` indicating whether the filter is based on a date range.
  Map<String, dynamic> toJson() {
    return {
      'fieldName': fieldName,
      'strings': strings,
      'byDateRange': byDateRange,
    };
  }

  /// Converts the `FieldFilter` instance to a JSON string.
  String toJsonString() {
    return '{"fieldName":"$fieldName","strings":${strings.toString()},"byDateRange":$byDateRange}';
  }
}
