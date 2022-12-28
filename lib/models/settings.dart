import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers.dart';
import 'constants.dart';

class Settings {
  bool prefLoaded = false;
  int colorSelected = 0;
  int screenIndex = 0;
  String? pathToDatabase;
  bool isBottomPanelExpanded = false;
  int materialVersion = 2;
  bool rentals = false;
  bool useDarkMode = false;

  load({Function? onLoaded}) async {
    var preferences = await SharedPreferences.getInstance();
    materialVersion = intValueOrDefault(preferences.getInt(prefMaterialVersion), defaultValueIfNull: 2);
    colorSelected = intValueOrDefault(preferences.getInt(prefColor));
    useDarkMode = boolValueOrDefault(preferences.getBool(prefDarkMode), defaultValueIfNull: false);

    pathToDatabase = preferences.getString(prefLastLoadedPathToDatabase);
    rentals = preferences.getBool(prefRentals) == true;
    prefLoaded = true;
    if (onLoaded != null) {
      onLoaded();
    }
  }

  save() async {
    var preferences = await SharedPreferences.getInstance();
    preferences.setInt(prefMaterialVersion, materialVersion);
    preferences.setInt(prefColor, colorSelected);
    preferences.setBool(prefDarkMode, useDarkMode);
    preferences.setBool(prefRentals, rentals);
    if (pathToDatabase == null) {
      preferences.remove(prefLastLoadedPathToDatabase);
    } else {
      preferences.setString(prefLastLoadedPathToDatabase, pathToDatabase.toString());
    }
  }

  ThemeData getThemeData() {
    var themeData = ThemeData(
      colorSchemeSeed: colorOptions[colorSelected],
      useMaterial3: materialVersion == 3,
      brightness: useDarkMode ? Brightness.dark : Brightness.light,
    );
    return themeData;
  }
}
