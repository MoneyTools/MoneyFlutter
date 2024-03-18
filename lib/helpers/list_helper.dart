import 'dart:math';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/helpers/string_helper.dart';

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
T? getFirstElement<T>(final List<int> indices, final List<dynamic> list) {
  if (indices.isNotEmpty) {
    final int index = indices.first;
    if (isBetweenOrEqual(index, 0, list.length - 1)) {
      return list[index] as T?;
    }
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
    return (a - b).toInt();
  } else {
    return (b - a).toInt();
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

T? getFirstSelectedItemFromSelectionList<T>(List<int> listOfSelectedItem, List<T> listOfItems) {
  if (listOfSelectedItem.isEmpty) {
    return null;
  }
  final int indexOfFirsSelectedAccount = listOfSelectedItem.first;
  return listOfItems[indexOfFirsSelectedAccount];
}
