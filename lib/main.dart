import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:money/app/core/theme/theme_controler.dart';
import 'package:money/app/data/models/settings.dart';
import 'package:money/app/routes/home_data_controller.dart';

import 'app/core/bindings/application_bindings.dart';
import 'app/routes/app_pages.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ThemeController themeController = Get.put(ThemeController());
  final Settings settingController = Get.put(Settings());
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
          getPages: AppPages.routes,
        );
      },
    );
  }
}
