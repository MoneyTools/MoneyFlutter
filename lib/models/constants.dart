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
const String settingKeyDomainAccountsInfoTransactions = 'accountDetailsTransactions';
const String settingKeyFilterText = 'filterText';
const String settingKeyFilterColumnsText = 'filterColumnsText';
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

const String settingKeyDomainAccounts = 'accounts';
const String settingKeyDomainCategories = 'categories';
const String settingKeyDomainPayees = 'payees';

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
  static const int commandFileSaveCsv = 2004;
  static const int commandFileSaveSql = 2005;
  static const int commandFileClose = 2006;

  static String viewTransactionFieldnameAccount = 'Account';
  static String viewTransactionFieldnamePayee = 'Payee/Transfer';
  static String viewTransactionFieldnameCategory = 'Category';
}

class SizeForDoubles {
  static const double one = 1;
  static const double nano = 2;
  static const double tiny = 3;
  static const double small = 5;
  static const double normal = 8;
  static const double large = 13;
  static const double largeX = 21;
  static const double largeXX = 34;
  static const double huge = 55;
}

class SizeForPadding {
  static const double small = 3;
  static const double medium = 8;
  static const double large = 13;
  static const double huge = 21;
}

class SizeForText {
  static const double small = 8;
  static const double medium = 13;
  static const double large = 21;
  static const double huge = 34;
}

class SizeForIcon {
  static const double small = 13;
  static const double medium = 21;
  static const double large = 34;
  static const double huge = 55;
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

extension ViewExtension on ViewId {
  String getViewPreferenceId(final String suffix) {
    // ignore: unnecessary_this
    return '${this.name.toLowerCase()}_$suffix';
  }

  IconData getIconData() {
    switch (this) {
      case ViewId.viewCashFlow:
        return Icons.analytics;
      case ViewId.viewAccounts:
        return Icons.account_balance;
      case ViewId.viewCategories:
        return Icons.type_specimen;
      case ViewId.viewPayees:
        return Icons.groups;
      case ViewId.viewAliases:
        return Icons.how_to_reg;
      case ViewId.viewTransactions:
        return Icons.receipt_long;
      case ViewId.viewTransfers:
        return Icons.swap_horiz;
      case ViewId.viewInvestments:
        return Icons.stacked_line_chart;
      case ViewId.viewStocks:
        return Icons.candlestick_chart_outlined;
      case ViewId.viewRentals:
        return Icons.location_city;
      case ViewId.viewPolicy:
        return Icons.policy;
    }
  }

  Icon getIcon() {
    return Icon(getIconData());
  }
}
