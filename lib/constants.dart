import 'package:flutter/material.dart';

class Constants {
  static const String demoData = "<Demo Data>";

  // NavigationRail shows if the screen width is greater or equal to
  // screenWidthThreshold; otherwise, NavigationBar is used for navigation.
  static const double narrowScreenWidthThreshold = 450;
}

const List<Color> colorOptions = [
  Colors.deepPurple,
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.pink,
];

const List<String> colorText = <String>[
  "Purple",
  "Blue",
  "Teal",
  "Green",
  "Yellow",
  "Orange",
  "Pink",
];

const prefLastLoadedPathToDatabase = 'lastLoadedPathToDatabase';
const prefMaterialVersion = 'themeMaterialVersion';
const prefColor = 'themeColor';
const prefDarkMode = 'themeDarkMode';
