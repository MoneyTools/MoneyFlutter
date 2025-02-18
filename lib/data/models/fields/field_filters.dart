import 'package:money/core/helpers/json_helper.dart';
import 'package:money/data/models/fields/field_filters.dart';

/// Exports
export 'package:money/data/models/fields/field_filter.dart';

/// Group a lists of filters
class FieldFilters {
  FieldFilters([List<FieldFilter>? inputList]) {
    this.list = inputList ?? <FieldFilter>[];
  }

  /// Constructs a `FieldFilters` instance from a JSON map.
  ///
  /// The JSON map is expected to have a `'filters'` key, which should be a list of JSON
  /// objects representing `FieldFilter` instances. This method creates a new `FieldFilters`
  /// instance and populates its `list` with `FieldFilter` instances constructed from the
  /// JSON objects.
  factory FieldFilters.fromJson(final Map<String, dynamic> json) {
    final List<FieldFilter> filters = (json['filters'] as List<MyJson>).map((MyJson filterJson) => FieldFilter.fromJson(filterJson)).toList();
    return FieldFilters(filters);
  }

  /// Constructs a `FieldFilters` instance from a JSON string.
  ///
  /// The JSON string is expected to be a valid JSON representation of a `FieldFilters` object.
  /// This method decodes the JSON string and uses `fromJson` to create a new `FieldFilters` instance.
  factory FieldFilters.fromJsonString(final String jsonString) {
    if (jsonString.isEmpty) {
      return FieldFilters();
    }
    final Map<String, dynamic> json = jsonDecode(jsonString) as Map<String, dynamic>;
    return FieldFilters.fromJson(json);
  }

  /// Constructs a `FieldFilters` instance from a list of string pairs.
  ///
  /// Each pair in the `inputList` is expected to be in the format `"fieldName=strings"`,
  /// where `fieldName` is the name of the field and `strings` is a pipe-separated list of
  /// string values to filter by.
  ///
  /// This method iterates through the `inputList`, splits each pair on the `=` character,
  /// and creates a new `FieldFilter` instance for each pair, adding it to the `list` of
  /// the `FieldFilters` instance.
  ///
  /// If a pair in the `inputList` does not have exactly two tokens (i.e., the `=` character),
  /// it is skipped and not added to the `list`.
  FieldFilters.fromList(final List<String> inputList) {
    for (final String pair in inputList) {
      final List<String> tokens = pair.split('=');
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

  List<FieldFilter> list = <FieldFilter>[];

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
    return <String, dynamic>{
      'filters': list.map((FieldFilter filter) => filter.toJson()).toList(),
    };
  }

  String toJsonString() {
    return jsonEncode(<String, List<Map<String, dynamic>>>{
      'filters': list.map((FieldFilter filter) => filter.toJson()).toList(),
    });
  }

  /// Returns a list of string representations of the [FieldFilter] instances in the [list].
  List<String> toStringList() {
    return list.map((FieldFilter filter) => filter.toString()).toList();
  }
}
