import 'package:flutter/material.dart';

class Constants {
  static const String demoData = "<Demo Data>";

  // NavigationRail shows if the screen width is greater or equal to
  // screenWidthThreshold; otherwise, NavigationBar is used for navigation.
  static const double narrowScreenWidthThreshold = 450;

  static const double targetHeight = 200.0;
  static const double gapBetweenChannels = 14.0;
  static const double minBlockHeight = 3.0;

  static const colorIncome = Color(0xff2f6001);
  static const colorExpense = Color(0xff730000);
  static const colorNet = Color(0xff0061AD);
}

const indexOfDefaultColor = 1; // Blue

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
