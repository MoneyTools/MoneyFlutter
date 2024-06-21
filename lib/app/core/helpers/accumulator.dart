import 'package:money/models/date_range.dart';

/// A generic class that accumulates values of type `V` associated with keys of type `T`.
/// It uses a `Map<K, Set<V>>` to store the accumulated values.
class AccumulatorList<K, V> {
  final Map<K, Set<V>> values = {};

  void clear() {
    values.clear();
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

  bool containsKey(K key) {
    return values.containsKey(key);
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
}

/// Tally values
class AccumulatorSum<K, V> {
  final Map<K, V> values = {};

  void clear() {
    values.clear();
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

  bool containsKey(K key) {
    return values.containsKey(key);
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

  List<MapEntry<K, V>> getEntries() {
    return values.entries.toList();
  }
}

/// Tally values
class AccumulatorDateRange<K> {
  final Map<K, DateRange> values = {};

  void clear() {
    values.clear();
  }

  void cumulate(K key, DateTime value) {
    if (values.containsKey(key)) {
      values[key]!.inflate(value);
    } else {
      values[key] = DateRange()..inflate(value);
    }
  }

  bool containsKey(K key) {
    return values.containsKey(key);
  }

  DateRange? getValue(K key) {
    return values[key];
  }

  List<MapEntry<K, DateRange>> getEntries() {
    return values.entries.toList();
  }
}

/// Ensure unique Key [K] instances, that cumulate unique instance of [I] another accumulator
/// this last accumulator stores [V]
class MapAccumulator<K, I, V> {
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
