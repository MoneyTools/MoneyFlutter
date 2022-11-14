intValueOrDefault(int? value, int defaultValueIfNull) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}
