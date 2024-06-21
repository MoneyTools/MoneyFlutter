import 'package:flutter/material.dart';

import 'package:money/app/core/theme/theme_controler.dart';
import 'package:get/get.dart';
import 'package:money/app/data/models/constants.dart';

import 'app/core/bindings/application_bindings.dart';
import 'app/routes/app_pages.dart';

void main() {
  Get.updateLocale(const Locale('en', 'US'));
  final ThemeController themeController = Get.put(ThemeController());
  runApp(
    Obx(
      () {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeController.themeDataLight,
          darkTheme: themeController.themeDataDark,
          themeMode: themeController.isDarkTheme.value ? ThemeMode.dark : ThemeMode.light,
          title: 'MyMoney by VTeam',
          initialBinding: ApplicationBindings(),
          initialRoute: Constants.routeWelcomePage,
          getPages: AppPages.routes,
        );
      },
    ),
  );
}
