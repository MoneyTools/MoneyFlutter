import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/core/controller/preferences_controller.dart';
import 'package:money/core/helpers/list_helper.dart';
import 'package:money/core/helpers/misc_helpers.dart';
import 'package:money/data/models/constants.dart';
import 'package:window_manager/window_manager.dart';

/// Controller for managing app theme settings including:
/// - Light/dark mode switching
/// - Primary color scheme selection
/// - Device width responsive breakpoints
/// - Font scaling
/// - Window size management
/// - Theme persistence
class ThemeController extends GetxController {
  RxInt colorSelected = 0.obs;
  RxBool isDarkTheme = false.obs;
  RxBool isDeviceWidthLarge = false.obs;
  RxBool isDeviceWidthMedium = true.obs;
  RxBool isDeviceWidthSmall = false.obs;
  Color primaryColor = Colors.grey;

  @override
  void onInit() {
    super.onInit();
    loadThemeFromPreferences();
  }

  //--------------------------------------------------------
  // Font scaling

  void fontScaleDecrease() {
    fontScaleDelta(-0.10);
  }

  void fontScaleDelta(final double addOrSubtract) {
    setFontScaleTo(PreferenceController.to.textScale + addOrSubtract);
  }

  void fontScaleIncrease() {
    fontScaleDelta(0.10);
  }

  void loadThemeFromPreferences() async {
    if (!PreferenceController.to.isReady.value) {
      await PreferenceController.to.init();
    }
    isDarkTheme.value = PreferenceController.to.getBool(
      settingKeyDarkMode,
      false,
    );
    colorSelected.value = PreferenceController.to.getInt(settingKeyTheme, 0);
    updateTheme();
  }

  void saveThemeToPreferences() async {
    PreferenceController.to.setBool(settingKeyDarkMode, isDarkTheme.value);
    PreferenceController.to.setInt(settingKeyTheme, colorSelected.value);
  }

  void setAppSizeToLarge() {
    windowManager.ensureInitialized().then((void _) {
      final WindowOptions windowOptions = const WindowOptions(
        size: Size(1800, 900),
        minimumSize: Size(Constants.screenWithSmall, 800),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
        title: 'MyMoney by vTeam',
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    });
  }

  void setAppSizeToMedium() {
    windowManager.ensureInitialized().then((void _) {
      final WindowOptions windowOptions = const WindowOptions(
        size: Size(Constants.screenWidthMedium, 900),
        minimumSize: Size(Constants.screenWidthMedium, 800),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
        title: 'MyMoney by vTeam',
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    });
  }

  void setAppSizeToSmall() {
    windowManager.ensureInitialized().then((void _) {
      final WindowOptions windowOptions = const WindowOptions(
        size: Size(Constants.screenWithSmall, 900),
        maximumSize: Size(Constants.screenWithSmall, 900),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
        title: 'MyMoney by vTeam',
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    });
  }

  bool setFontScaleTo(final double newScale) {
    final int cleanValue = (newScale * 100).round();
    if (isBetweenOrEqual(cleanValue, 40, 400)) {
      PreferenceController.to.textScale = cleanValue / 100.0;

      return true;
    }
    return false;
  }

  void setThemeColor(final int index) {
    colorSelected.value = index;
    primaryColor = themeData.colorScheme.primary;
    saveThemeToPreferences();
    updateTheme();
  }

  ThemeData get themeData => isDarkTheme.value ? themeDataDark : themeDataLight;

  ThemeData get themeDataDark {
    // Validate color range
    if (!isIndexInRange(themeAsColors, colorSelected.value)) {
      colorSelected = 0.obs;
    }

    final ThemeData themeData = ThemeData(
      colorSchemeSeed: themeAsColors[colorSelected.value],
      brightness: Brightness.dark,
    );
    return themeData;
  }

  ThemeData get themeDataLight {
    // Validate color range
    if (!isIndexInRange(themeAsColors, colorSelected.value)) {
      colorSelected = 0.obs;
    }
    final ThemeData themeData = ThemeData(
      colorSchemeSeed: themeAsColors[colorSelected.value],
      brightness: Brightness.light,
    );
    return themeData;
  }

  static ThemeController get to => Get.find();

  void toggleThemeMode() {
    isDarkTheme.value = !isDarkTheme.value;
    primaryColor = themeData.colorScheme.primary;
    saveThemeToPreferences();
    updateTheme();
  }

  /// this will rebuild the app to use the current theme
  void updateTheme() {
    primaryColor = themeData.colorScheme.primary;
    Get.changeTheme(themeData);
  }
}
