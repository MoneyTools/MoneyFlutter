import 'package:flutter/material.dart';
import 'package:money/helpers/json_helper.dart';
import 'package:money/storage/data/data_mutations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/constants.dart';
import 'dart:convert';

class Settings {
  bool prefLoaded = false;
  int colorSelected = 0;
  bool isSmallDevice = true;
  int screenIndex = 0;
  String? lastOpenedDataSource;

  bool isDetailsPanelExpanded = false;
  bool includeClosedAccounts = false;
  bool rentals = false;
  bool useDarkMode = false;

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
      save();
      fireOnChanged();
      return true;
    }
    return false;
  }

  double textScale = 1.0;

  // Tracking changes
  final DataMutations trackMutations = DataMutations();

  //--------------------------------------------------------
  Map<String, MyJson> views = <String, MyJson>{};

  Function? onChanged;

  static final Settings _singleton = Settings._internal();

  factory Settings() {
    return _singleton;
  }

  Settings._internal();

  void fireOnChanged() {
    onChanged?.call();
  }

  void load({final Function? onLoaded}) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    colorSelected = intValueOrDefault(preferences.getInt(prefColor));
    textScale = doubleValueOrDefault(preferences.getDouble(prefTextScale), defaultValueIfNull: 1.0);
    useDarkMode = boolValueOrDefault(preferences.getBool(prefDarkMode), defaultValueIfNull: false);

    lastOpenedDataSource = preferences.getString(prefLastLoadedPathToDatabase);
    rentals = preferences.getBool(prefRentals) == true;
    includeClosedAccounts = preferences.getBool(prefIncludeClosedAccounts) == true;
    isDetailsPanelExpanded = preferences.getBool(prefIsDetailsPanelExpanded) == true;

    views = loadMapFromPrefs(preferences, prefViews);

    prefLoaded = true;
    if (onLoaded != null) {
      onLoaded();
    }
  }

  void save() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(prefTextScale, textScale);
    await preferences.setInt(prefColor, colorSelected);

    await preferences.setBool(prefDarkMode, useDarkMode);
    await preferences.setBool(prefIncludeClosedAccounts, includeClosedAccounts);
    await preferences.setBool(prefRentals, rentals);

    saveMapToPrefs(preferences, prefViews, views);

    if (lastOpenedDataSource == null) {
      await preferences.remove(prefLastLoadedPathToDatabase);
    } else {
      await preferences.setString(prefLastLoadedPathToDatabase, lastOpenedDataSource.toString());
    }
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

  void saveMapToPrefs(
    final SharedPreferences prefs,
    final String key,
    final Map<String, MyJson> mapOfJson,
  ) {
    prefs.setString(key, json.encode(mapOfJson));
  }
}
