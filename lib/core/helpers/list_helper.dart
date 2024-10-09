import 'dart:math';

import 'package:collection/collection.dart';
import 'package:money/core/helpers/string_helper.dart';
import 'package:money/data/models/money_objects/money_object.dart';

/// Calculates a list of evenly spaced values between a start and end value.
///
/// This function takes a start value, an end value, and the desired number of
/// entries in the resulting list. It calculates the step size between each
/// value and generates a list of evenly spaced values between the start and
/// end values.
///
/// If the number of entries is less than or equal to 1, an empty list is
/// returned.
///
/// Example usage:
///
/// ```dart
/// List<double> spread = calculateSpread(1.0, 5.0, 5);
/// print(spread); // Output: [1.0, 2.0, 3.0, 4.0, 5.0]
/// ```
///
/// Parameters:
///   start (double): The starting value of the spread.
///   end (double): The ending value of the spread.
///   numEntries (int): The desired number of entries in the resulting list.
///
/// Returns:
///   A list of evenly spaced values between the start and end values.
///   If numEntries is less than or equal to 1, an empty list is returned.
List<double> calculateSpread(double start, double end, int numEntries) {
  // Check if numEntries is valid
  if (numEntries <= 1) {
    return [];
  }

  // Calculate the step size between each value
  double step = (end - start) / (numEntries - 1);

  // Initialize an empty list to store the spread values
  List<double> spread = [];

  // Generate the spread values and add them to the list
  for (int i = 0; i < numEntries; i++) {
    spread.add(start + i * step);
  }

  return spread;
}

/// Converts a Map to a List of Pair objects.
///
/// This function takes a Map and converts it to a List of Pair objects,
/// where each Pair object contains a key-value pair from the input Map.
///
/// The function is generic and can handle any type of key and value in the
/// input Map. The types of the key and value are specified using the type
/// parameters `T` and `U`, respectively.
///
/// Example usage:
///
/// ```dart
/// Map<String, int> myMap = {'apple': 1, 'banana': 2, 'orange': 3};
/// List<Pair<String, int>> pairList = convertMapToListOfPair<String, int>(myMap);
/// print(pairList); // Output: [(apple, 1), (banana, 2), (orange, 3)]
/// ```
///
/// Parameters:
///   map (Map<dynamic, dynamic>): The input Map to be converted.
///
/// Type Parameters:
///   T: The type of the keys in the input Map.
///   U: The type of the values in the input Map.
///
/// Returns:
///   A List of Pair objects, where each Pair contains a key-value pair
///   from the input Map.
List<Pair<T, U>> convertMapToListOfPair<T, U>(Map<dynamic, dynamic> map) {
  // Initialize an empty list to store the Pair objects
  List<Pair<T, U>> list = [];

  // Iterate over the entries in the input Map
  map.forEach((key, value) {
    // Create a Pair object with the current key and value
    list.add(Pair(key, value));
  });

  // Return the list of Pair objects
  return list;
}

/// Converts a list of key-value pairs to a list of percentages.
///
/// This function takes a list of `KeyValue` objects, where each object
/// represents a key-value pair. The function calculates the total sum of
/// all values and then converts each value to a percentage of the total sum.
/// The resulting list contains `KeyValue` objects with the same keys as the
/// input list, but with the values representing the corresponding percentages.
///
/// If the total sum of values is zero, all percentages are set to 0.0.
///
/// Example usage:
///
/// ```dart
/// List<KeyValue> keyValuePairs = [
///   KeyValue(key: 'A', value: 10.0),
///   KeyValue(key: 'B', value: 20.0),
///   KeyValue(key: 'C', value: 30.0),
/// ];
///
/// List<KeyValue> percentages = convertToPercentages(keyValuePairs);
/// print(percentages); // Output: [KeyValue(key: 'A', value: 16.67), KeyValue(key: 'B', value: 33.33), KeyValue(key: 'C', value: 50.0)]
/// ```
///
/// Parameters:
///   keyValuePairs (List<KeyValue>): The input list of `KeyValue` objects.
///
/// Returns:
///   A list of `KeyValue` objects, where each object contains a key from the
///   input list and a value representing the corresponding percentage of the
///   total sum of values.
List<KeyValue> convertToPercentages(List<KeyValue> keyValuePairs) {
  // Calculate total amount
  double totalAmount = keyValuePairs.fold(0, (prev, entry) => prev + entry.value);

  // Convert each amount to a percentage and retain key association
  List<KeyValue> percentages = keyValuePairs.map((entry) {
    double percentage = (entry.value / totalAmount) * 100;
    return KeyValue(
      key: entry.key,
      value: percentage.isNaN ? 0.0 : percentage,
    ); // Handle division by zero
  }).toList();

  return percentages;
}

List<num> getMinMaxValues(final List<double> list) {
  if (list.isEmpty) {
    return <num>[0, 0];
  }
  if (list.length == 1) {
    return <num>[list[0], list[0]];
  }

  double valueMin = 0.0;
  double valueMax = 0.0;
  if (list[0] < list[1]) {
    valueMin = list[0];
    valueMax = list[1];
  } else {
    valueMin = list[1];
    valueMax = list[0];

    for (double value in list) {
      valueMin = min(valueMin, value);
      valueMax = max(valueMax, value);
    }
  }
  return <num>[valueMin, valueMax];
}

/// Return the first element of type T in a list given a list of possible index;
T? getMoneyObjectFromFirstSelectedId<T>(
  final List<int> selectedIds,
  final List<dynamic> listOfItems,
) {
  if (selectedIds.isNotEmpty) {
    final int id = selectedIds.first;
    return listOfItems.firstWhereOrNull((element) => (element as MoneyObject).uniqueId == id);
  }
  return null;
}

bool isIndexInRange(List array, int index) {
  return index >= 0 && index < array.length;
}

List<String> padList(List<String> list, int length, String padding) {
  if (list.length >= length) {
    return list;
  }
  List<String> paddedList = List<String>.from(list);
  for (int i = list.length; i < length; i++) {
    paddedList.add(padding);
  }
  return paddedList;
}

int sortByDate(
  final DateTime? a,
  final DateTime? b, [
  final bool ascending = true,
]) {
  if (a == null && b == null) {
    return 0;
  }

  if (ascending) {
    if (a == null) {
      return -1;
    }
    if (b == null) {
      return 1;
    }
    return a.compareTo(b);
  } else {
    if (a == null) {
      return 1;
    }
    if (b == null) {
      return -1;
    }
    return b.compareTo(a);
  }
}

int sortByString(final dynamic a, final dynamic b, final bool ascending) {
  if (ascending) {
    return stringCompareIgnoreCasing2(a.toString(), b.toString());
  } else {
    return stringCompareIgnoreCasing2(b.toString(), a.toString());
  }
}

int sortByValue(final num a, final num b, final bool ascending) {
  if (ascending) {
    return a.compareTo(b);
  } else {
    return b.compareTo(a);
  }
}

class KeyValue {
  KeyValue({required this.key, required this.value});

  dynamic key;
  dynamic value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is! KeyValue) {
      return false;
    }

    final otherKeyValue = other;
    return key == otherKeyValue.key && value == otherKeyValue.value;
  }

  @override
  int get hashCode => Object.hash(key, value);

  @override
  String toString() {
    return '$key:$value';
  }
}

class Pair<F, S> {
  Pair(this.first, this.second);

  F first;
  S second;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Pair<F, S> && other.first == first && other.second == second;
  }

  @override
  int get hashCode => first.hashCode ^ second.hashCode;

  @override
  String toString() => '($first, $second)';
}

class Triple<F, S, T> {
  Triple(this.first, this.second, this.third);

  F first;
  S second;
  T third;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Triple<F, S, T> && other.first == first && other.second == second && other.third == third;
  }

  @override
  int get hashCode => first.hashCode ^ second.hashCode ^ third.hashCode;

  @override
  String toString() => '($first, $second, $third)';
}

List<String> enumToStringList<T>(List<T> enumValues) {
  return enumValues.map((e) => e.toString().split('.').last).toList();
}

extension RandomItemExtension<T> on List<T> {
  T getRandomItem() {
    final random = Random();
    if (isEmpty) {
      throw Exception('Cannot get random item from an empty list');
    }
    return this[random.nextInt(length)];
  }
}
