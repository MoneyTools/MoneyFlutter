import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class Settings {
  int colorSelected = 0;
  int screenIndex = 0;
  String? pathToDatabase;
  bool isBottomPanelExpanded = false;

  bool rentals = false;

  /* Default theme */
  ThemeData themeData = ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: colorOptions[indexOfDefaultColor]);

  load(onLoaded) async {
    SharedPreferences.getInstance().then((preferences) {
      pathToDatabase = preferences.getString(prefLastLoadedPathToDatabase);
      rentals = preferences.getBool(prefRentals) == true;
      onLoaded();
    });
  }

  save() {}

  isDarkMode() {
    return themeData.brightness == Brightness.dark;
  }
}
