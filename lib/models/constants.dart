import 'package:flutter/material.dart';

class Constants {
  static const String demoData = '<Demo Data>';

  // NavigationRail shows if the screen width is greater or equal to
  // screenWidthThreshold; otherwise, NavigationBar is used for navigation.
  static const double narrowScreenWidthThreshold = 450;

  static const double targetHeight = 200.0;
  static const double sanKeyColumnWidth = 200.0;
  static const double gapBetweenChannels = 14.0;
  static const double minBlockHeight = 3.0;

  static const Color colorIncome = Color(0xaa4b6735);
  static const Color colorExpense = Color(0xaa813e3e);
  static const Color colorNet = Color(0xaa5c8aab);

  static const int commandTextScaleIncrease = 3000;
  static const int commandTextScaleDecrease = 3001;
  static const int commandIncludeClosedAccount = 4000;
  static const int commandIncludeRentals = 5000;
}

const List<Color> colorOptions = <Color>[
  Colors.deepPurple,
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.pink,
];

const List<String> colorText = <String>[
  'Purple',
  'Blue',
  'Teal',
  'Green',
  'Yellow',
  'Orange',
  'Pink',
];

const String prefLastLoadedPathToDatabase = 'lastLoadedPathToDatabase';
const String prefColor = 'themeColor';
const String prefDarkMode = 'themeDarkMode';
const String prefIncludeClosedAccounts = 'includeClosedAccounts';
const String prefRentals = 'rentals';
const String prefTextScale = 'textScale';
