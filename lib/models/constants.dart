import 'package:flutter/material.dart';

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

const String settingKeyCashflowRecurringOccurrences = 'keyCashflowOccurrences';
const String settingKeyCashflowView = 'keyCashflowView';
const String settingKeyDarkMode = 'themeDarkMode';
const String settingKeyDetailsPanelExpanded = 'isDetailsPanelExpanded';
const String settingKeyDomainAccounts = 'accountDetailsTransactions';
const String settingKeyFilterText = 'filterText';
const String settingKeyIncludeClosedAccounts = 'includeClosedAccounts';
const String settingKeyLastLoadedPathToDatabase = 'lastLoadedPathToDatabase';
const String settingKeyRentalsSupport = 'rentals';
const String settingKeySelectedDetailsPanelTab = 'selectedDetailsPanelTab';
const String settingKeySelectedListItemId = 'selectedItemId';
const String settingKeySortAscending = 'sortAscending';
const String settingKeySortBy = 'sortBy';
const String settingKeyStockApiKey = 'stockServiceApiKey';
const String settingKeyTextScale = 'textScale';
const String settingKeyTheme = 'themeColor';
const String settingKeyViewsMap = 'views';

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
  static const int commandSettings = 1100;
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

class IntValues {
  static int maxSigned(int bitCount) {
    RangeError.checkValueInInterval(bitCount, 1, 64);
    return (1 << (bitCount - 1)) - 1;
  }

  // ...
  static int maxUnsigned(int bitCount) {
    RangeError.checkValueInInterval(bitCount, 1, 64);
    return (1 << bitCount) - 1;
  }

  static int minSigned(int bitCount) {
    RangeError.checkValueInInterval(bitCount, 1, 64);
    return (-1 << (bitCount - 1)) - 1;
  }

  static int minUnsigned(int bitCount) {
    RangeError.checkValueInInterval(bitCount, 1, 64);
    return (-1 << (bitCount - 1));
  }
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
  viewInvestments,
  viewStocks,
  viewRentals,
  viewPolicy,
}
