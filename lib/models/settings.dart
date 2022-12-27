import 'package:flutter/material.dart';

import 'constants.dart';

class Settings {
  int colorSelected = 0;
  int screenIndex = 0;
  String? pathToDatabase;
  bool isBottomPanelExpanded = false;

  /* Default theme */
  ThemeData themeData = ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: colorOptions[indexOfDefaultColor]);

  isDarkMode() {
    return themeData.brightness == Brightness.dark;
  }

}