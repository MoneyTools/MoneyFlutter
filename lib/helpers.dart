numValueOrDefault(num? value, {num defaultValueIfNull=0}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}

intValueOrDefault(int? value, {int defaultValueIfNull=0}) {
  if (value == null) {
    return defaultValueIfNull;
  }
  return value;
}
