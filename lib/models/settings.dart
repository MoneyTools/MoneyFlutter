import 'package:flutter/material.dart';
import 'package:money/helpers/json_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/constants.dart';
import 'dart:convert';

import 'package:path/path.dart' as p;

class Settings {
  bool prefLoaded = false;
  int colorSelected = 0;
  bool isSmallDevice = true;
  int screenIndex = 0;
  String? pathToDatabase;
  String? get pathToDatabaseFolder => p.dirname(Settings().pathToDatabase!);
  bool isDetailsPanelExpanded = false;
  bool includeClosedAccounts = false;
  bool rentals = false;
  bool useDarkMode = false;
  double textScale = 1.0;
  Map<String, Json> views = <String, Json>{};

  Function? onChanged;

  static final Settings _singleton = Settings._internal();

  factory Settings() {
    return _singleton;
  }

  Settings._internal();

  void fireOnChanged() {
    onChanged?.call();
  }

  void load({final Function? onLoaded}) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    colorSelected = intValueOrDefault(preferences.getInt(prefColor));
    textScale = doubleValueOrDefault(preferences.getDouble(prefTextScale), defaultValueIfNull: 1.0);
    useDarkMode = boolValueOrDefault(preferences.getBool(prefDarkMode), defaultValueIfNull: false);

    pathToDatabase = preferences.getString(prefLastLoadedPathToDatabase);
    rentals = preferences.getBool(prefRentals) == true;
    includeClosedAccounts = preferences.getBool(prefIncludeClosedAccounts) == true;
    isDetailsPanelExpanded = preferences.getBool(prefIsDetailsPanelExpanded) == true;

    views = loadMapFromPrefs(preferences, prefViews);

    prefLoaded = true;
    if (onLoaded != null) {
      onLoaded();
    }
  }

  void save() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(prefTextScale, textScale);
    await preferences.setInt(prefColor, colorSelected);

    await preferences.setBool(prefDarkMode, useDarkMode);
    await preferences.setBool(prefIncludeClosedAccounts, includeClosedAccounts);
    await preferences.setBool(prefRentals, rentals);

    saveMapToPrefs(preferences, prefViews, views);

    if (pathToDatabase == null) {
      await preferences.remove(prefLastLoadedPathToDatabase);
    } else {
      await preferences.setString(prefLastLoadedPathToDatabase, pathToDatabase.toString());
    }
  }

  ThemeData getThemeData() {
    // Validate color range
    if (colorSelected > colorOptions.length) {
      colorSelected = 0;
    }

    final ThemeData themeData = ThemeData(
      colorSchemeSeed: colorOptions[colorSelected],
      brightness: useDarkMode ? Brightness.dark : Brightness.light,
    );
    return themeData;
  }

  Map<String, Json> loadMapFromPrefs(
    final SharedPreferences prefs,
    final String key,
  ) {
    try {
      final String? serializedMap = prefs.getString(key);
      if (serializedMap != null) {
        // first deserialize
        final Map<String, dynamic> parsedMap = json.decode(serializedMap) as Map<String, dynamic>;

        // second to JSon map
        final Map<String, Json> resultMap =
            parsedMap.map((final String key, final dynamic value) => MapEntry<String, Json>(key, value as Json));

        return resultMap;
      }
    } catch (_) {
      //
    }

    return <String, Json>{};
  }

  void saveMapToPrefs(
    final SharedPreferences prefs,
    final String key,
    final Map<String, Json> mapOfJson,
  ) {
    prefs.setString(key, json.encode(mapOfJson));
  }
}
