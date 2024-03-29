import 'package:flutter/material.dart';

class Constants {
  static const String demoData = '<Demo Data>';
  static const String newDataFile = '<New file>';
  static const String defaultCurrency = 'USD';

  // NavigationRail shows if the screen width is greater or equal to
  // screenWidthThreshold; otherwise, NavigationBar is used for navigation.
  static const double narrowScreenWidthThreshold = 600;

  static const double targetHeight = 200.0;
  static const double sanKeyColumnWidth = 200.0;
  static const double gapBetweenChannels = 14.0;
  static const double minBlockHeight = 3.0;

  static const int commandTextZoom = 1000;
  static const int commandCurrencies = 1100;
  static const int commandIncludeClosedAccount = 1200;
  static const int commandIncludeRentals = 1300;
  static const int commandAddTransactions = 1400;

  static const int commandFileNew = 2000;
  static const int commandFileOpen = 2001;
  static const int commandFileLocation = 2002;
  static const int commandFileSaveCsv = 2003;
  static const int commandFileSaveSql = 2004;
  static const int commandFileClose = 2005;
}

enum ViewId {
  viewCashFlow,
  viewAccounts,
  viewLoans,
  viewCategories,
  viewPayees,
  viewAliases,
  viewTransactions,
  viewTransfers,
  viewRentals,
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

const String perfDomainAccounts = 'accountDetailsTransactions';

const String prefLastLoadedPathToDatabase = 'lastLoadedPathToDatabase';
const String prefColor = 'themeColor';
const String prefDarkMode = 'themeDarkMode';
const String prefIncludeClosedAccounts = 'includeClosedAccounts';
const String prefIsDetailsPanelExpanded = 'isDetailsPanelExpanded';
const String prefRentals = 'rentals';
const String prefTextScale = 'textScale';
const String prefViews = 'views';
const String prefSortBy = 'sortBy';
const String prefSortAscending = 'sortAscending';
const String prefSelectedListItemIndex = 'selectedItemIndex';
const String prefSelectedDetailsPanelTab = 'selectedDetailsPanelTab';

class IntValues {
  // ...
  static int maxUnsigned(int bitCount) {
    RangeError.checkValueInInterval(bitCount, 1, 64);
    return (1 << bitCount) - 1;
  }

  static int minSigned(int bitCount) {
    RangeError.checkValueInInterval(bitCount, 1, 64);
    return (-1 << (bitCount - 1)) - 1;
  }

  static int maxSigned(int bitCount) {
    RangeError.checkValueInInterval(bitCount, 1, 64);
    return (1 << (bitCount - 1)) - 1;
  }

  static int minUnsigned(int bitCount) {
    RangeError.checkValueInInterval(bitCount, 1, 64);
    return (-1 << (bitCount - 1));
  }
}
