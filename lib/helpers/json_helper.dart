import 'dart:convert';

import 'package:money/helpers/misc_helpers.dart';

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
      if (value is int) {
        return value;
      }
      return int.parse(value);
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
      if (value is String) {
        return attemptToGetDoubleFromText(value) ?? 0.0;
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
      if (value is bool) {
        return value;
      }

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
  DateTime? getDate(
    final String key, [
    final DateTime? defaultIfNotFound,
  ]) {
    final dynamic value = this[key];

    if (value == null || value.toString().isEmpty) {
      return defaultIfNotFound;
    }

    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return defaultIfNotFound;
    }
  }
}

String encodeValueWrapStringTypes(dynamic value) {
  if (value is String) {
    return "'$value'";
  } else {
    return value.toString();
  }
}

MyJson myJsonFromKeyValuePairs(List<String> keys, List<String> values) {
  MyJson object = {};
  for (int i = 0; i < keys.length; i++) {
    object[keys[i]] = values[i];
  }
  return object;
}

/// Diff between to JSon object
MyJson myJsonDiff({required MyJson before, required MyJson after}) {
  MyJson diff = MyJson();

  after.forEach((key, valueAfter) {
    dynamic valueBefore = before[key];
    if (valueBefore != valueAfter) {
      diff[key] = {
        'before': valueBefore,
        'after': valueAfter,
      };
    }
  });
  return diff;
}
