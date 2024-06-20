// ignore_for_file: unnecessary_this

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:money/helpers/list_helper.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/fields/field_filter.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/storage/data/data_mutations.dart';
import 'package:money/storage/file_manager.dart';
import 'package:money/storage/preferences_helper.dart';
import 'package:money/widgets/snack_bar.dart';

class Settings extends ChangeNotifier {
  String getUniqueSate() {
    return '$colorSelected $useDarkMode ${Data().version} $includeClosedAccounts $includeRentalManagement';
  }

  void rebuild() {
    notifyListeners();
  }

  /// State for Preferences
  bool _isPreferenceLoaded = false;

  bool get isPreferenceLoaded => _isPreferenceLoaded;

  set isPreferenceLoaded(bool value) {
    _isPreferenceLoaded = value;
    rebuild();
  }

  /// Dark/Light theme
  bool _useDarkMode = false;

  bool get useDarkMode => _useDarkMode;

  set useDarkMode(bool value) {
    _useDarkMode = value;
    rebuild();
  }

  /// Color theme
  int _colorSelected = 0;

  int get colorSelected => _colorSelected;

  set colorSelected(int value) {
    _colorSelected = value;
    rebuild();
  }

  bool isSmallScreen = true;

  /// What screen is selected
  ViewId _selectedScreen = ViewId.viewCashFlow;

  ViewId get selectedView => _selectedScreen;

  set selectedView(ViewId value) {
    _selectedScreen = value;
    rebuild();
  }

  FileManager fileManager = FileManager();

  /// Support Rental Management
  bool _rentals = false;

  bool get includeRentalManagement => _rentals;

  set includeRentalManagement(bool value) {
    _rentals = value;
    rebuild();
  }

  /// Hide/Show Closed Accounts
  bool _includeClosedAccounts = false;

  bool get includeClosedAccounts => _includeClosedAccounts;

  set includeClosedAccounts(bool value) {
    _includeClosedAccounts = value;
    Settings().preferrenceSave();
    rebuild();
  }

  /// Hide/Show Info panel
  bool _isDetailsPanelExpanded = false;

  bool get isDetailsPanelExpanded => _isDetailsPanelExpanded;

  set isDetailsPanelExpanded(bool value) {
    _isDetailsPanelExpanded = value;
    rebuild();
  }

  CashflowViewAs cashflowViewAs = CashflowViewAs.sankey;
  int cashflowRecurringOccurrences = 12;
  String apiKeyForStocks = '';

  //--------------------------------------------------------
  // Font scaling

  void fontScaleDecrease() {
    fontScaleDelta(-0.10);
  }

  void fontScaleIncrease() {
    fontScaleDelta(0.10);
  }

  void fontScaleMultiplyBy(final double factor) {
    setFontScaleTo(textScale * factor);
  }

  void fontScaleDelta(final double addOrSubtract) {
    setFontScaleTo(textScale + addOrSubtract);
  }

  bool setFontScaleTo(final double newScale) {
    final int cleanValue = (newScale * 100).round();
    if (isBetweenOrEqual(cleanValue, 40, 400)) {
      textScale = cleanValue / 100.0;
      preferrenceSave();
      rebuild();
      return true;
    }
    return false;
  }

  double textScale = 1.0;

  // Tracking changes
  final DataMutations trackMutations = DataMutations();

  static final Settings _singleton = Settings._internal();

  factory Settings() {
    return _singleton;
  }

  Settings._internal();

  Future<bool> preferrenceLoad() async {
    final PreferencesHelper preferences = await PreferencesHelper.init();

    colorSelected = intValueOrDefault(preferences.getInt(settingKeyTheme));
    textScale = doubleValueOrDefault(preferences.getDouble(settingKeyTextScale), defaultValueIfNull: 1.0);
    useDarkMode = boolValueOrDefault(preferences.getBool(settingKeyDarkMode), defaultValueIfNull: false);

    includeRentalManagement = preferences.getBool(settingKeyRentalsSupport) == true;
    cashflowViewAs = CashflowViewAs.values[
        intValueOrDefault(preferences.getInt(settingKeyCashflowView), defaultValueIfNull: CashflowViewAs.sankey.index)];
    cashflowRecurringOccurrences =
        intValueOrDefault(preferences.getInt(settingKeyCashflowRecurringOccurrences), defaultValueIfNull: 12);
    _includeClosedAccounts = preferences.getBool(settingKeyIncludeClosedAccounts) == true;
    apiKeyForStocks = preferences.getString(settingKeyStockApiKey) ?? '';

    isDetailsPanelExpanded = preferences.getBool(settingKeyDetailsPanelExpanded) == true;
    fileManager.fullPathToLastOpenedFile = preferences.getString(settingKeyLastLoadedPathToDatabase) ?? '';
    fileManager.mru = preferences.getStringList(settingKeyMRU) ?? [];

    isPreferenceLoaded = true;
    return true;
  }

  Future<void> preferrenceSave() async {
    final PreferencesHelper preferences = PreferencesHelper();
    await preferences.setDouble(settingKeyTextScale, textScale);
    await preferences.setInt(settingKeyTheme, colorSelected);
    await preferences.setInt(settingKeyCashflowView, cashflowViewAs.index);
    await preferences.setInt(settingKeyCashflowRecurringOccurrences, cashflowRecurringOccurrences);
    await preferences.setBool(settingKeyDarkMode, useDarkMode);
    await preferences.setBool(settingKeyIncludeClosedAccounts, includeClosedAccounts);
    await preferences.setBool(settingKeyRentalsSupport, includeRentalManagement);
    await preferences.setString(settingKeyStockApiKey, apiKeyForStocks);

    // last path to the source of data
    await preferences.setString(settingKeyLastLoadedPathToDatabase, fileManager.fullPathToLastOpenedFile, true);
    await preferences.setStringList(settingKeyMRU, fileManager.mru);
  }

  ThemeData getThemeData() {
    // Validate color range
    if (!isIndexInRange(colorOptions, colorSelected)) {
      colorSelected = 0;
    }

    final ThemeData themeData = ThemeData(
      colorSchemeSeed: colorOptions[colorSelected],
      brightness: useDarkMode ? Brightness.dark : Brightness.light,
    );
    return themeData;
  }

  void closeFile([bool rebuild = true]) {
    Settings().fileManager.state = DataFileState.empty;
    this.fileManager.fullPathToLastOpenedFile = '';
    this.preferrenceSave();
    Data().close();
    this.trackMutations.reset();
    if (rebuild) {
      this.rebuild();
    }
  }

  void loadFileFromPath(final String path) async {
    this.fileManager.state = DataFileState.loading;
    closeFile(false); // ensure that we closed current file and state

    Timer(const Duration(milliseconds: 200), () async {
      await Data().loadFromPath(filePathToLoad: path).then((final bool success) {
        // if (success) {
        Settings().fileManager.state = DataFileState.loaded;
        Settings().rebuild();
        // }
      });
      this.rebuild();
    });
  }

  void onSaveToCsv() async {
    final String fullPathToFileName = await Data().saveToCsv();
    Settings().fileManager.rememberWhereTheDataCameFrom(fullPathToFileName);
    Data().assessMutationsCountOfAllModels();
  }

  void onSaveToSql() async {
    if (Settings().fileManager.fullPathToLastOpenedFile.isEmpty) {
      // this happens if the user started with a new file and click save to SQL
      Settings().fileManager.fullPathToLastOpenedFile =
          await Settings().fileManager.defaultFolderToSaveTo('mymoney.mmdb');
    }

    Data().saveToSql(
        filePathToLoad: Settings().fileManager.fullPathToLastOpenedFile,
        callbackWhenLoaded: (final bool success, final String message) {
          if (success) {
            Data().assessMutationsCountOfAllModels();
          } else {
            SnackBarService.display(autoDismiss: false, message: message);
          }
        });

    Settings().fileManager.rememberWhereTheDataCameFrom(Settings().fileManager.fullPathToLastOpenedFile);
  }
}

/// Navigation helpers

void switchViewTransacionnForPayee(final String payeeName) {
  FieldFilters fieldFilters = FieldFilters();
  fieldFilters.add(
      FieldFilter(fieldName: Constants.viewTransactionFieldnamePayee, filterTextInLowerCase: payeeName.toLowerCase()));

  PreferencesHelper().setStringList(
    ViewId.viewTransactions.getViewPreferenceId(settingKeyFilterColumnsText),
    fieldFilters.toStringList(),
  );

  // Switch view
  Settings().selectedView = ViewId.viewTransactions;
}

enum CashflowViewAs {
  sankey,
  recurringIncomes,
  recurringExpenses,
}
