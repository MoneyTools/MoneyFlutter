import 'package:flutter/material.dart';

const List<Color> themeAsColors = <Color>[
  Colors.deepPurple,
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.pink,
];

const List<String> themeColorNames = <String>[
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
const String settingKeyTheme = 'themeColor';
const String settingKeyDetailsPanelExpanded = 'isDetailsPanelExpanded';
const String settingKeyDomainAccountsInfoTransactions = 'accountDetailsTransactions';
const String settingKeyFilterText = 'filterText';
const String settingKeyFilterColumnsText = 'filterColumnsText';
const String settingKeyIncludeClosedAccounts = 'includeClosedAccounts';
const String settingKeyMRU = 'mru';
const String settingKeyRentalsSupport = 'rentals';
const String settingKeySelectedDetailsPanelTab = 'selectedDetailsPanelTab';
const String settingKeySelectedListItemId = 'selectedItemId';
const String settingKeySortAscending = 'sortAscending';
const String settingKeySortBy = 'sortBy';
const String settingKeyStockApiKey = 'stockServiceApiKey';
const String settingKeyTextScale = 'textScale';

const String settingKeyDomainAccounts = 'accounts';
const String settingKeyDomainCategories = 'categories';
const String settingKeyDomainPayees = 'payees';

class Constants {
  static const int commandAddTransactions = 1400;
  static const int commandFileClose = 2006;
  static const int commandFileLocation = 2002;
  static const int commandFileNew = 2000;
  static const int commandFileOpen = 2001;
  static const int commandFileSaveCsv = 2004;
  static const int commandFileSaveSql = 2005;
  static const int commandIncludeClosedAccount = 1200;
  static const int commandRebalance = 1500;
  static const int commandSettings = 1100;
  static const int commandTextZoom = 1000;
  static const String defaultCurrency = 'USD';
  static const double gapBetweenChannels = 14.0;
  // Keys
  static const Key keyAddNewItem = Key('key_add_new_item');

  static const Key keyCancelButton = Key('key_cancel_button');
  static const Key keyCopyListToClipboardHeaderInfoPanel = Key('keyCopyListToClipboardHeaderInfoPanel');
  static const Key keyCopyListToClipboardHeaderMain = Key('keyCopyListToClipboardHeaderMain');
  static const Key keyDeleteSelectedItems = Key('key_delete_button');
  static const Key keyEditSelectedItems = Key('key_edit_item');
  static const Key keyInfoPanelExpando = Key('key_info_panel_expando');
  static const Key keyMergeButton = Key('key_merge_button');
  static const Key keyMruButton = Key('key_mru_button');
  static const Key keyMultiSelectionToggle = Key('key_multi_selection_toggle');
  static const Key keyPendingChanges = Key('key_pending_changes');
  static const Key keySettingsButton = Key('key_settings_button');
  static const Key keyZoomDecrease = Key('keyZoomDecrease');
  static const Key keyZoomIncrease = Key('keyZoomIncrease');
  static const Key keyZoomNormal = Key('keyZoomNormal');
  static const double minBlockHeight = 3.0;
  static String mockStockSymbol = '<not real>';
  static String routeHomePage = '/home';
  static String routePolicyPage = '/policy';
  static String routeSettingsPage = '/settings';
  static String routeWelcomePage = '/welcome';
  static const double sanKeyColumnWidth = 200.0;
  static const double screenWidthMedium = 1200;
  static const double screenWithSmall = 600;
  static const double targetHeight = 200.0;
  static String untitledFileName = 'Untitled';
  static String viewStockFieldNameAccount = 'Account';
  static String viewStockFieldNameSymbol = 'Symbol';
  static String viewTransactionFieldNameAccount = 'Account';
  static String viewTransactionFieldNameCategory = 'Category';
  static String viewTransactionFieldNamePayee = 'Payee/Transfer';
}

class SizeForDoubles {
  static const double huge = 55;
  static const double large = 13;
  static const double largeX = 21;
  static const double largeXX = 34;
  static const double nano = 2;
  static const double normal = 8;
  static const double one = 1;
  static const double small = 5;
  static const double tiny = 3;
}

class SizeForPadding {
  static const double huge = 21;
  static const double large = 13;
  static const double medium = 5;
  static const double nano = 2;
  static const double normal = 8;
  static const double small = 3;
}

class SizeForText {
  static const double huge = 34;
  static const double large = 21;
  static const double medium = 13;
  static const double nano = 8;
  static const double normal = 18;
  static const double small = 10;
}

class SizeForIcon {
  static const double huge = 55;
  static const double large = 34;
  static const double medium = 21;
  static const double small = 13;
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
        return Icons.query_stats_outlined;
      case ViewId.viewAccounts:
        return Icons.account_balance_outlined;
      case ViewId.viewCategories:
        return Icons.category_outlined;
      case ViewId.viewPayees:
        return Icons.groups_3_outlined;
      case ViewId.viewAliases:
        return Icons.how_to_reg_outlined;
      case ViewId.viewTransactions:
        return Icons.receipt_long_outlined;
      case ViewId.viewTransfers:
        return Icons.swap_horiz_outlined;
      case ViewId.viewInvestments:
        return Icons.stacked_line_chart_outlined;
      case ViewId.viewStocks:
        return Icons.candlestick_chart_outlined;
      case ViewId.viewRentals:
        return Icons.location_city_outlined;
      case ViewId.viewPolicy:
        return Icons.policy_outlined;
    }
  }

  Icon getIcon() {
    return Icon(getIconData());
  }
}

class MyKeys {
  static const keyHeaderFilterTextInput = Key('key_header_filter_input');
}
