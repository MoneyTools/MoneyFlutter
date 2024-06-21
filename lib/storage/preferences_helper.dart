import 'dart:convert';

import 'package:money/app/core/helpers/json_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  // Singleton instance of PreferencesHelper
  static final PreferencesHelper _instance = PreferencesHelper._internal();

  // Factory constructor to return the singleton instance
  factory PreferencesHelper() {
    return _instance;
  }

  // Private constructor for singleton pattern
  PreferencesHelper._internal();

  // SharedPreferences instance
  static SharedPreferences? _preferences;

  // Initialize the SharedPreferences instance
  static Future<PreferencesHelper> init() async {
    _preferences = await SharedPreferences.getInstance();
    return PreferencesHelper();
  }

  // Set a string value to preferences
  Future<void> setString(String key, String value, [bool removeIfEmpty = false]) async {
    if (removeIfEmpty && value.isEmpty) {
      await remove(key);
    } else {
      await _preferences?.setString(key, value);
    }
  }

  // Retrieve a string value from preferences
  String? getString(String key) {
    return _preferences?.getString(key);
  }

  // Set an integer value to preferences
  Future<void> setInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  // Retrieve an integer value from preferences
  int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  // Set a boolean value to preferences
  Future<void> setBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  // Retrieve a boolean value from preferences
  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  // Set a double value to preferences
  Future<void> setDouble(String key, double value) async {
    await _preferences?.setDouble(key, value);
  }

  // Retrieve a double value from preferences
  double? getDouble(String key) {
    return _preferences?.getDouble(key);
  }

  // Set a list of strings to preferences
  Future<void> setStringList(String key, List<String> value) async {
    if (value.isEmpty) {
      remove(key);
    } else {
      await _preferences?.setStringList(key, value);
    }
  }

  // Retrieve a list of strings from preferences
  List<String>? getStringList(String key) {
    return _preferences?.getStringList(key);
  }

  // Retrieve a MyJson object value from preferences
  Map<String, MyJson> getMapOfMyJson(final String key) {
    try {
      final String? serializedMap = _preferences?.getString(key);
      if (serializedMap != null) {
        // first deserialize
        final MyJson parsedMap = json.decode(serializedMap) as MyJson;

        // second to JSon map
        final Map<String, MyJson> resultMap =
            parsedMap.map((final String key, final dynamic value) => MapEntry<String, MyJson>(key, value as MyJson));

        return resultMap;
      }
    } catch (_) {
      //
    }

    return <String, MyJson>{};
  }

  Future<void> setMapOfMyJson(
    final String key,
    final Map<String, MyJson> mapOfJson,
  ) async {
    _preferences?.setString(key, json.encode(mapOfJson));
  }

  Future<void> setMyJson(
    final String key,
    final MyJson myJson,
  ) async {
    _preferences?.setString(key, json.encode(myJson));
  }

  // Remove a value from preferences
  Future<void> remove(String key) async {
    await _preferences?.remove(key);
  }

  // Clear all values from preferences
  Future<void> clear() async {
    await _preferences?.clear();
  }
}
