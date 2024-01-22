import 'dart:convert';

typedef MyJson = Map<String, dynamic>;

/// helpers for retrieving value as types
extension MyJsonExtensions on MyJson {
  static String toJson(final dynamic object) {
    return jsonEncode(object);
  }

  static T fromJson<T>(final String jsonString) {
    return jsonDecode(jsonString) as T;
  }

  /// Generic converter the caller is responsible
  /// This may throw an exception
  T? getValue<T>(final String key, {final T? defaultValue}) {
    if (containsKey(key)) {
      return this[key] as T;
    }
    return defaultValue;
  }

  int getInt(final String key, [final int defaultIfNotFound = 0]) {
    final dynamic value = this[key];
    if (value == null) {
      return defaultIfNotFound;
    }
    try {
      return value as int;
    } catch (_) {
      return defaultIfNotFound;
    }
  }

  double getDouble(
    final String key, [
    final double defaultIfNotFound = 0.0,
  ]) {
    final dynamic value = this[key];
    if (value == null) {
      return defaultIfNotFound;
    }
    try {
      if (value is int) {
        return (value).toDouble();
      }
      return value as double;
    } catch (_) {
      return defaultIfNotFound;
    }
  }

  bool getBool(
    final String key, [
    final bool defaultIfNotFound = false,
  ]) {
    final dynamic value = this[key];
    if (value == null) {
      return defaultIfNotFound;
    }
    try {
      return value as bool;
    } catch (_) {
      return defaultIfNotFound;
    }
  }

  String getString(
    final String key, [
    final String defaultIfNotFound = '',
  ]) {
    final dynamic value = this[key];
    if (value == null) {
      return defaultIfNotFound;
    }
    try {
      return value as String;
    } catch (_) {
      return defaultIfNotFound;
    }
  }

  /// Expected input format to be
  /// '1999-12-25T00:00:00.000'
  /// or
  /// '1999-12-25'
  DateTime getDate(
    final String key, [
    final DateTime? defaultIfNotFound,
  ]) {
    final dynamic value = this[key];
    if (value == null) {
      return defaultIfNotFound ?? DateTime.parse('1970-01-01');
    }
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return defaultIfNotFound ?? DateTime.parse('1970-01-01');
    }
  }
}
