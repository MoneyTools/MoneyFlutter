import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:money/helpers.dart';
import 'package:money/models/constants.dart';

class Settings {
  bool prefLoaded = false;
  int colorSelected = 0;
  int screenIndex = 0;
  String? pathToDatabase;
  bool isBottomPanelExpanded = false;
  bool includeClosedAccounts = false;
  bool rentals = false;
  bool useDarkMode = false;
  double textScale = 1.0;

  static final Settings _singleton = Settings._internal();

  factory Settings() {
    return _singleton;
  }

  Settings._internal();

  load({final Function? onLoaded}) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    colorSelected = intValueOrDefault(preferences.getInt(prefColor));
    textScale = doubleValueOrDefault(preferences.getDouble(prefTextScale), defaultValueIfNull: 1.0);
    useDarkMode = boolValueOrDefault(preferences.getBool(prefDarkMode), defaultValueIfNull: false);

    pathToDatabase = preferences.getString(prefLastLoadedPathToDatabase);
    rentals = preferences.getBool(prefRentals) == true;
    includeClosedAccounts = preferences.getBool(prefIncludeClosedAccounts) == true;
    prefLoaded = true;
    if (onLoaded != null) {
      onLoaded();
    }
  }

  save() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setDouble(prefTextScale, textScale);
    preferences.setInt(prefColor, colorSelected);
    preferences.setBool(prefDarkMode, useDarkMode);
    preferences.setBool(prefIncludeClosedAccounts, includeClosedAccounts);
    preferences.setBool(prefRentals, rentals);
    if (pathToDatabase == null) {
      preferences.remove(prefLastLoadedPathToDatabase);
    } else {
      preferences.setString(prefLastLoadedPathToDatabase, pathToDatabase.toString());
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
}
