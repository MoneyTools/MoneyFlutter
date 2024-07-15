import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/core/helpers/ranges.dart';

/// A generic class that accumulates values of type `V` associated with keys of type `T`.
/// It uses a `Map<K, Set<V>>` to store the accumulated values.
class AccumulatorList<K, V> {
  final Map<K, Set<V>> values = {};

  void clear() {
    values.clear();
  }

  bool containsKey(K key) {
    return values.containsKey(key);
  }

  bool containsKeyValue(K key, V value) {
    var setFound = values[key];
    if (setFound == null) {
      // the key is not a match
      return false;
    }

    return setFound.contains(value);
  }

  /// Adds a value of type `V` to the set associated with the provided `key` of type `K`.
  ///
  /// If the `key` already exists in the `values` map, it retrieves the existing set
  /// and adds the `value` to that set. If the `key` doesn't exist, it creates a new
  /// set containing the `value` and associates it with the `key` in the `values` map.
  void cumulate(K key, V value) {
    if (values.containsKey(key)) {
      final existingSet = values[key] as Set<V>;
      existingSet.add(value);
    } else {
      // first time setting the set
      values[key] = <V>{value}; // Ensure type safety for the set
    }
  }

  /// Returns a list of all the keys present in the `values` map.
  List<K> getKeys() {
    return values.keys.toList();
  }

  /// Retrieves the set of values associated with the provided `key`.
  ///
  /// If the `key` exists in the `values` map, it converts the set to a list and returns it.
  /// If the `key` doesn't exist, it returns an empty list.
  List<V> getList(K key) {
    return values[key]?.toList() ?? [];
  }

  Set<V>? getValue(K key) {
    return values[key];
  }
}

/// Tally values
class AccumulatorSum<K, V> {
  final Map<K, V> values = {};

  void clear() {
    values.clear();
  }

  bool containsKey(K key) {
    return values.containsKey(key);
  }

  void cumulate(K key, V value) {
    if (values.containsKey(key)) {
      // Use dynamic type for accumulated value as specific behavior depends on T
      final V? existingValue = values[key];
      values[key] = _accumulate(existingValue as V, value);
    } else {
      values[key] = value;
    }
  }

  List<MapEntry<K, V>> getEntries() {
    return values.entries.toList();
  }

  K? getKeyWithLargestSum() {
    K? keyFound;
    V? maxFound;

    values.forEach(
      (key, value) {
        if (keyFound == null) {
          keyFound = key;
          maxFound = value;
        } else {
          if ((maxFound as num) < (value as num)) {
            keyFound = key;
            maxFound = value;
          }
        }
      },
    );
    return keyFound;
  }

  dynamic getValue(K key) {
    return values[key] ?? 0;
  }

  // Replace this function with your specific logic for accumulating values of type T
  dynamic _accumulate(V existingValue, V value) {
    return (existingValue as num) + (value as num);
  }
}

/// Keep track of oldest and newest date range
class AccumulatorDateRange<K> {
  final Map<K, DateRange> values = {};

  void clear() {
    values.clear();
  }

  bool containsKey(K key) {
    return values.containsKey(key);
  }

  void cumulate(K key, DateTime value) {
    if (values.containsKey(key)) {
      values[key]!.inflate(value);
    } else {
      values[key] = DateRange()..inflate(value);
    }
  }

  List<MapEntry<K, DateRange>> getEntries() {
    return values.entries.toList();
  }

  DateRange? getValue(K key) {
    return values[key];
  }
}

/// Keep track of oldest and newest date range
class AccumulatorAverage<K> {
  final Map<K, RunningAverage> values = {};

  void clear() {
    values.clear();
  }

  bool containsKey(K key) {
    return values.containsKey(key);
  }

  void cumulate(K key, num value) {
    RunningAverage average = values.containsKey(key) ? values[key]! : values[key] = RunningAverage();
    average.addValue(value);
  }

  RunningAverage? getValue(K key) {
    return values[key];
  }
}

/// Ensure unique Key [K] instances, that cumulate unique instance of [I] another accumulator
/// for Sum of [V]
class MapAccumulatorSum<K, I, V> {
  Map<K, AccumulatorSum<I, V>> map = {};

  void cumulate(K k, I i, V v) {
    if (!map.containsKey(k)) {
      map[k] = AccumulatorSum<I, V>();
    }
    map[k]!.cumulate(i, v);
  }

  AccumulatorSum<I, V>? getLevel1(K key) {
    return map[key];
  }
}

/// Ensure unique Key [K] instances, that cumulate unique instance of [I] another accumulator
/// for Set of [V]
class MapAccumulatorSet<K, I, V> {
  Map<K, AccumulatorList<I, V>> map = {};

  void cumulate(K k, I i, V v) {
    if (!map.containsKey(k)) {
      map[k] = AccumulatorList<I, V>();
    }
    map[k]!.cumulate(i, v);
  }

  /// for example
  /// cumulating 'species', 'number of Legs', 'name'
  /// MapAccumulatorSet<String, int, String>
  /// find ('bird', 2) returns ['duck', 'owl'])
  ///
  /// cumulating 'Account ID', 'PayeeNames', 'Categories'
  /// find (42, 'Starbucks') returns [12,33,207])
  Set<V> find(K key1, I key2) {
    final foundInLevel1 = map[key1];
    return foundInLevel1?.getValue(key2) ?? <V>{};
  }

  AccumulatorList<I, V>? getLevel1(K key1) {
    return map[key1];
  }
}

class RunningAverage {
  NumRange range = NumRange(
    min: double.infinity,
    max: -double.infinity,
  );

  int _count = 0;
  int _countZeros = 0;
  num _sum = 0.0;

  void addValue(num newValue) {
    if (isAlmostZero(newValue)) {
      _countZeros++;
    } else {
      _sum += newValue.abs();
      _count++;
      range.inflate(newValue);
    }
  }

  String get descriptionAsInt => 'Average\n${range.descriptionAsInt}\n$descriptionCount';

  String get descriptionAsMoney => 'Average\n${range.descriptionAsMoney}\n$descriptionCount';

  String get descriptionCount {
    if (_countZeros == 0) {
      return '$_count entries.';
    }
    return '$_count of ${_count + _countZeros} non zero entries.';
  }

  double getAverage({includingZeros = false}) {
    if (_count == 0) {
      return 0.0; // Handle case where no values have been added yet
    }
    if (includingZeros) {
      return _sum / (_count + _countZeros);
    }
    return _sum / _count;
  }
}
