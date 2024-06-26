class FieldFilter {
  FieldFilter({required this.fieldName, required this.filterTextInLowerCase}) {
    filterTextInLowerCase = filterTextInLowerCase.toLowerCase();
  }

  factory FieldFilter.fromJson(Map<String, dynamic> json) {
    return FieldFilter(
      fieldName: json['fieldName'] as String,
      filterTextInLowerCase: json['filterTextInLowerCase'] as String,
    );
  }
  final String fieldName;
  late String filterTextInLowerCase;

  Map<String, dynamic> toJson() {
    return {
      'fieldName': fieldName,
      'filterTextInLowerCase': filterTextInLowerCase,
    };
  }

  @override
  String toString() {
    return '$fieldName=$filterTextInLowerCase';
  }
}

class FieldFilters {
  FieldFilters();

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
            filterTextInLowerCase: tokens[1].toLowerCase(),
          ),
        );
      }
    }
  }

  List<FieldFilter> list = [];

  bool get isEmpty => list.isEmpty;

  int get length => list.length;

  void clear() {
    list.clear();
  }

  void add(final FieldFilter ff) {
    list.add(ff);
  }

  // @override
  // String toString() {
  //   return list.join(';');
  // }

  List<String> toStringList() {
    return list.map((filter) => filter.toString()).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'list': list.map((filter) => filter.toJson()).toList(),
    };
  }
}
