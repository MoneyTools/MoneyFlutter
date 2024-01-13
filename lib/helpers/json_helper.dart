typedef Json = Map<String, dynamic>;

int jsonGetInt(
  final Json json,
  final String key, [
  final int defaultIfNotFound = 0,
]) {
  final dynamic value = json[key];
  if (value == null) {
    return defaultIfNotFound;
  }
  try {
    return value as int;
  } catch (_) {
    return defaultIfNotFound;
  }
}

double jsonGetDouble(
  final Json json,
  final String key, [
  final double defaultIfNotFound = 0.0,
]) {
  final dynamic value = json[key];
  if (value == null) {
    return defaultIfNotFound;
  }
  try {
    return value as double;
  } catch (_) {
    return defaultIfNotFound;
  }
}

bool jsonGetBool(
  final Json json,
  final String key, [
  final bool defaultIfNotFound = false,
]) {
  final dynamic value = json[key];
  if (value == null) {
    return defaultIfNotFound;
  }
  try {
    return value as bool;
  } catch (_) {
    return defaultIfNotFound;
  }
}

String jsonGetString(
  final Json json,
  final String key, [
  final String defaultIfNotFound = '',
]) {
  final dynamic value = json[key];
  if (value == null) {
    return defaultIfNotFound;
  }
  try {
    return value as String;
  } catch (_) {
    return defaultIfNotFound;
  }
}

DateTime jsonGetDate(
  final Json json,
  final String key, {
  final DateTime? defaultIfNotFound,
}) {
  final dynamic value = json[key];
  if (value == null) {
    return defaultIfNotFound ?? DateTime.parse('19070-01-01');
  }
  try {
    return value as DateTime;
  } catch (_) {
    return defaultIfNotFound ?? DateTime.parse('19070-01-01');
  }
}
