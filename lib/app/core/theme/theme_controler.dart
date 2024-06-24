import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  RxBool isDarkTheme = false.obs;
  RxInt colorSelected = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadThemeFromPreferences();
  }

  void toggleTheme() {
    isDarkTheme.value = !isDarkTheme.value;
    saveThemeToPreferences();
    Get.changeTheme(themeData);
  }

  void setThemeColor(final int index) {
    colorSelected.value = index;
    saveThemeToPreferences();
    Get.changeTheme(themeData);
  }

  void loadThemeFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDarkTheme.value = prefs.getBool(settingKeyDarkMode) ?? false;
    colorSelected.value = prefs.getInt(settingKeyTheme) ?? 0;
    Get.changeTheme(themeData);
  }

  void saveThemeToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(settingKeyDarkMode, isDarkTheme.value);
    prefs.setInt(settingKeyTheme, colorSelected.value);
  }

  ThemeData get themeData {
    return isDarkTheme.value ? themeDataDark : themeDataLight;
  }

  ThemeData get themeDataLight {
    // Validate color range
    if (!isIndexInRange(colorOptions, colorSelected.value)) {
      colorSelected = 0.obs;
    }
    final ThemeData themeData = ThemeData(
      colorSchemeSeed: colorOptions[colorSelected.value],
      brightness: Brightness.light,
    );
    return themeData;
  }

  ThemeData get themeDataDark {
    // Validate color range
    if (!isIndexInRange(colorOptions, colorSelected.value)) {
      colorSelected = 0.obs;
    }
    final ThemeData themeData = ThemeData(
      colorSchemeSeed: colorOptions[colorSelected.value],
      brightness: Brightness.dark,
    );
    return themeData;
  }
}
