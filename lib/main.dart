import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/core/theme/theme_controler.dart';
import 'package:money/app/controller/general_controller.dart';
import 'package:money/app/modules/general/general_routes.dart';
import 'package:money/app/controller/data_controller.dart';
import 'package:money/app/modules/home/home_routes.dart';
import 'package:money/app/modules/policies/policy_routes.dart';
import 'package:money/app/modules/splash_screen.dart';
import 'package:money/app/modules/welcome/welcome_page.dart';
import 'package:money/app/modules/welcome/welcome_routes.dart';

import 'app/core/bindings/application_bindings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeController themeController = Get.put(ThemeController());
  final GeneralController settingController = Get.put(GeneralController());
  final PreferenceController preferenceController = Get.put(PreferenceController());
  final DataController dataController = Get.put(DataController());

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get.updateLocale(const Locale('en', 'US'));

    return Obx(
      () {
        final String k =
            '${settingController.getUniqueState}|${preferenceController.getUniqueState}|${dataController.getUniqueState}';

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
                }),
            ...HomeRoutes.routes,
            ...WelcomeRoutes.routes,
            ...GeneralRoutes.routes,
            ...PolicyRoutes.routes,
          ],
        );
      },
    );
  }
}
