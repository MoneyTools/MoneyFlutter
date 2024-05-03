import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/money_objects/accounts/account.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/storage/data/data_mutations.dart';
import 'package:money/storage/file_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CashflowViewAs {
  sankey,
  recurring,
}

class Settings extends ChangeNotifier {
  String getUniqueSate() {
    return '$colorSelected $useDarkMode ${Data().version}';
  }

  void rebuild() {
    notifyListeners();
  }

  /// State for Preferences
  bool _isPreferenceLoaded = false;

  bool get isPreferenceLoaded => _isPreferenceLoaded;

  set isPreferenceLoaded(bool value) {
    _isPreferenceLoaded = value;
    notifyListeners();
  }

  /// Dark/Light theme
  bool _useDarkMode = false;

  bool get useDarkMode => _useDarkMode;

  set useDarkMode(bool value) {
    _useDarkMode = value;
    notifyListeners();
  }

  /// Color theme
  int _colorSelected = 0;

  int get colorSelected => _colorSelected;

  set colorSelected(int value) {
    _colorSelected = value;
    notifyListeners();
  }

  bool isSmallScreen = true;

  /// What screen is selected
  ViewId _selectedScreen = ViewId.viewCashFlow;

  ViewId get selectedView => _selectedScreen;

  set selectedView(ViewId value) {
    _selectedScreen = value;
    notifyListeners();
  }

  FileManager fileManager = FileManager();

  bool rentals = false;
  bool includeClosedAccounts = false;

  bool _isDetailsPanelExpanded = false;

  bool get isDetailsPanelExpanded => _isDetailsPanelExpanded;

  set isDetailsPanelExpanded(bool value) {
    _isDetailsPanelExpanded = value;
    notifyListeners();
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
      store();
      notifyListeners();
      return true;
    }
    return false;
  }

  double textScale = 1.0;

  // Tracking changes
  final DataMutations trackMutations = DataMutations();

  //--------------------------------------------------------
  Map<String, MyJson> views = <String, MyJson>{};

  MyJson? getLastViewSettings(final String viewOfModel) {
    final MyJson? viewSetting = views[viewOfModel];
    return viewSetting;
  }

  static final Settings _singleton = Settings._internal();

  factory Settings() {
    return _singleton;
  }

  Settings._internal();

  Future<bool> retrieve() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    colorSelected = intValueOrDefault(preferences.getInt(settingKeyTheme));
    textScale = doubleValueOrDefault(preferences.getDouble(settingKeyTextScale), defaultValueIfNull: 1.0);
    useDarkMode = boolValueOrDefault(preferences.getBool(settingKeyDarkMode), defaultValueIfNull: false);

    rentals = preferences.getBool(settingKeyRentalsSupport) == true;
    cashflowViewAs = CashflowViewAs.values[
        intValueOrDefault(preferences.getInt(settingKeyCashflowView), defaultValueIfNull: CashflowViewAs.sankey.index)];
    cashflowRecurringOccurrences =
        intValueOrDefault(preferences.getInt(settingKeyCashflowRecurringOccurrences), defaultValueIfNull: 12);
    includeClosedAccounts = preferences.getBool(settingKeyIncludeClosedAccounts) == true;
    apiKeyForStocks = preferences.getString(settingKeyStockApiKey) ?? '';

    isDetailsPanelExpanded = preferences.getBool(settingKeyDetailsPanelExpanded) == true;
    fileManager.fullPathToLastOpenedFile = preferences.getString(settingKeyLastLoadedPathToDatabase) ?? '';

    views = loadMapFromPrefs(preferences, settingKeyViewsMap);

    isPreferenceLoaded = true;
    return true;
  }

  void store() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(settingKeyTextScale, textScale);
    await preferences.setInt(settingKeyTheme, colorSelected);
    await preferences.setInt(settingKeyCashflowView, cashflowViewAs.index);
    await preferences.setInt(settingKeyCashflowRecurringOccurrences, cashflowRecurringOccurrences);
    await preferences.setBool(settingKeyDarkMode, useDarkMode);
    await preferences.setBool(settingKeyIncludeClosedAccounts, includeClosedAccounts);
    await preferences.setBool(settingKeyRentalsSupport, rentals);
    await preferences.setString(settingKeyStockApiKey, apiKeyForStocks);

    storeMapToPrefs(preferences, settingKeyViewsMap, views);

    if (fileManager.fullPathToLastOpenedFile.isEmpty) {
      await preferences.remove(settingKeyLastLoadedPathToDatabase);
    } else {
      await preferences.setString(settingKeyLastLoadedPathToDatabase, fileManager.fullPathToLastOpenedFile);
    }
  }

  void stash(final String key, final String value) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(key, value);
  }

  Future<String> unStash(final String key, final String value) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(key) ?? '';
  }

  ThemeData getThemeData() {
    // Validate color range
    if (colorSelected > colorOptions.length) {
      colorSelected = 0;
    }

    final ThemeData themeData = ThemeData(
      colorSchemeSeed: colorOptions[colorSelected],
      brightness: useDarkMode ? Brightness.dark : Brightness.light,
    );
    return themeData;
  }

  Map<String, MyJson> loadMapFromPrefs(
    final SharedPreferences prefs,
    final String key,
  ) {
    try {
      final String? serializedMap = prefs.getString(key);
      if (serializedMap != null) {
        // first deserialize
        final MyJson parsedMap = json.decode(serializedMap) as MyJson;

        // second to JSon map
        final Map<String, MyJson> resultMap =
            parsedMap.map((final String key, final dynamic value) => MapEntry<String, MyJson>(key, value as MyJson));

        return resultMap;
      }
    } catch (_) {
      //
    }

    return <String, MyJson>{};
  }

  void storeMapToPrefs(
    final SharedPreferences prefs,
    final String key,
    final Map<String, MyJson> mapOfJson,
  ) {
    prefs.setString(key, json.encode(mapOfJson));
  }

  Account? mostRecentlySelectedAccount;
}

Future<void> saveBoolArray(final String key, List<bool> boolArray) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> boolStrings = boolArray.map((boolValue) => boolValue.toString()).toList();
  String encodedArray = json.encode(boolStrings);
  await prefs.setString(key, encodedArray);
}

Future<List<bool>> getBoolArray(final String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? encodedArray = prefs.getString(key);
  if (encodedArray != null) {
    List<String> boolStrings = json.decode(encodedArray).cast<String>();
    List<bool> boolArray = boolStrings.map((boolString) => boolString == 'true').toList();
    return boolArray;
  } else {
    return []; // Default value if array is not found
  }
}
