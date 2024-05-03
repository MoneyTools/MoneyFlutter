class AccumulatorSum<T, V> {
  final Map<T, V> values = {};

  void cumulate(T key, V value) {
    if (values.containsKey(key)) {
      // Use dynamic type for accumulated value as specific behavior depends on T
      final V? existingValue = values[key];
      values[key] = _accumulate(existingValue as V, value);
    } else {
      values[key] = value;
    }
  }

  // Replace this function with your specific logic for accumulating values of type T
  dynamic _accumulate(V existingValue, V value) {
    return (existingValue as num) + (value as num);
  }

  dynamic getValue(T key) {
    return values[key] ?? 0;
  }
}

class AccumulatorList<T, V> {
  final Map<T, Set<V>> _values = {};

  void cumulate(T key, V value) {
    if (_values.containsKey(key)) {
      final existingSet = _values[key] as Set<V>;
      existingSet.add(value);
    } else {
      // first time setting the set
      _values[key] = <V>{value}; // Ensure type safety for the set
    }
  }

  List<T> getKeys() {
    return _values.keys.toList();
  }

  List<V> getValues(T key) {
    return _values[key]?.toList() ?? [];
  }
}
