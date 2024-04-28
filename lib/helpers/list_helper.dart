import 'dart:math';

import 'package:collection/collection.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/money_objects/money_object.dart';

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
T? getMoneyObjectFromFirstSelectedId<T>(final List<int> selectedIds, final List<dynamic> listOfItems) {
  if (selectedIds.isNotEmpty) {
    final int id = selectedIds.first;
    return listOfItems.firstWhereOrNull((element) => (element as MoneyObject).uniqueId == id);
  }
  return null;
}

int sortByString(final dynamic a, final dynamic b, final bool ascending) {
  if (ascending) {
    return stringCompareIgnoreCasing1(a as String, b as String);
  } else {
    return stringCompareIgnoreCasing1(b as String, a as String);
  }
}

int sortByValue(final num a, final num b, final bool ascending) {
  if (ascending) {
    return a.compareTo(b);
  } else {
    return b.compareTo(a);
  }
}

int sortByDate(final DateTime? a, final DateTime? b, [final bool ascending = true]) {
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

class SortedSet<T> {
  final List<T> _elements = [];
  final int Function(T a, T b) compare; // Custom comparator function

  SortedSet(this.compare);

  void add(T element) {
    int insertionIndex = _findInsertionIndex(element);
    _elements.insert(insertionIndex, element);
  }

  int _findInsertionIndex(T element) {
    int low = 0;
    int high = _elements.length;
    while (low < high) {
      final mid = (low + high) ~/ 2;
      final comparison = compare(element, _elements[mid]);
      if (comparison < 0) {
        high = mid;
      } else {
        low = mid + 1;
      }
    }
    return low;
  }
}

List<List<int>> resizeMatrix(List<List<int>> matrix, int newRowCount, int newColCount) {
  // Calculate scaling factors for rows and columns
  double rowScaleFactor = matrix.length / newRowCount;
  double colScaleFactor = matrix[0].length / newColCount;

  // Initialize the resized matrix
  List<List<int>> resizedMatrix = List.generate(newRowCount, (_) => List<int>.filled(newColCount, 0));

  // Fill in the resized matrix using the scaling factors
  for (int newRow = 0; newRow < newRowCount; newRow++) {
    for (int newCol = 0; newCol < newColCount; newCol++) {
      // Calculate the corresponding indices in the original matrix
      double originalRow = newRow * rowScaleFactor + (rowScaleFactor / 2);
      double originalCol = newCol * colScaleFactor + (colScaleFactor / 2);

      // Convert to integer indices
      int originalRowIndex = originalRow.toInt().clamp(0, matrix.length - 1);
      int originalColIndex = originalCol.toInt().clamp(0, matrix[0].length - 1);

      // Copy the value from the original matrix to the resized matrix
      resizedMatrix[newRow][newCol] = matrix[originalRowIndex][originalColIndex];
    }
  }

  return resizedMatrix;
}
