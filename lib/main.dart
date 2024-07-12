import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/controller/data_controller.dart';
import 'package:money/app/controller/keyboard_controller.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/controller/theme_controler.dart';
import 'package:money/app/modules/home/home_routes.dart';
import 'package:money/app/modules/policies/policy_routes.dart';
import 'package:money/app/modules/settings/settings_routes.dart';
import 'package:money/app/modules/splash_screen.dart';
import 'package:money/app/modules/welcome/welcome_page.dart';
import 'package:money/app/modules/welcome/welcome_routes.dart';

import 'app/core/bindings/application_bindings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final DataController dataController = Get.put(DataController());
  // Leave these declared in this order
  final PreferenceController preferenceController = Get.put(PreferenceController());

  final ShortcutController shortcutController = Get.put(ShortcutController());
  final ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    // Get.updateLocale(const Locale('en', 'US'));

    return Obx(
      () {
        final String k = preferenceController.getUniqueState;

        // debugLog('Obx-GetMaterialApp');
        return GetMaterialApp(
          key: Key(k),
          debugShowCheckedModeBanner: false,
          theme: themeController.themeDataLight,
          darkTheme: themeController.themeDataDark,
          themeMode: themeController.isDarkTheme.value ? ThemeMode.dark : ThemeMode.light,
          title: 'MyMoney by VTeam',
          initialBinding: ApplicationBindings(),
          initialRoute: '/',
          getPages: [
            GetPage(
              name: '/',
              page: () {
                PreferenceController preferenceController = Get.find();
                if (preferenceController.isReady.value) {
                  return const WelcomePage();
                }
                return const SplashScreen();
              },
            ),
            ...HomeRoutes.routes,
            ...WelcomeRoutes.routes,
            ...SettingsRoutes.routes,
            ...PolicyRoutes.routes,
          ],
        );
      },
    );
  }
}
