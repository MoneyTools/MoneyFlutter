import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/data/models/constants.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  RxBool isDarkTheme = false.obs;
  RxInt colorSelected = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadThemeFromPreferences();
  }

  void toggleThemeMode() {
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
    isDarkTheme.value = PreferenceController.to.getBool(settingKeyDarkMode, false);
    colorSelected.value = PreferenceController.to.getInt(settingKeyTheme, 0);
    Get.changeTheme(themeData);
  }

  void saveThemeToPreferences() async {
    PreferenceController.to.setBool(settingKeyDarkMode, isDarkTheme.value);
    PreferenceController.to.setInt(settingKeyTheme, colorSelected.value);
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

  //--------------------------------------------------------
  // Font scaling

  void fontScaleDecrease() {
    fontScaleDelta(-0.10);
  }

  void fontScaleIncrease() {
    fontScaleDelta(0.10);
  }

  void fontScaleMultiplyBy(final double factor) {
    setFontScaleTo(PreferenceController.to.textScale * factor);
  }

  void fontScaleDelta(final double addOrSubtract) {
    setFontScaleTo(PreferenceController.to.textScale + addOrSubtract);
  }

  bool setFontScaleTo(final double newScale) {
    final int cleanValue = (newScale * 100).round();
    if (isBetweenOrEqual(cleanValue, 40, 400)) {
      PreferenceController.to.textScale = cleanValue / 100.0;

      return true;
    }
    return false;
  }
}
