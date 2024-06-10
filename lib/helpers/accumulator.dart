class AccumulatorList<T, V> {
  final Map<T, Set<V>> values = {};

  void cumulate(T key, V value) {
    if (values.containsKey(key)) {
      final existingSet = values[key] as Set<V>;
      existingSet.add(value);
    } else {
      // first time setting the set
      values[key] = <V>{value}; // Ensure type safety for the set
    }
  }

  List<T> getKeys() {
    return values.keys.toList();
  }

  List<V> getList(T key) {
    return values[key]?.toList() ?? [];
  }
}

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
