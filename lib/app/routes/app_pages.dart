import 'package:get/get.dart';
import 'package:money/app/data/models/settings.dart';
import 'package:money/app/modules/splash_screen.dart';
import 'package:money/app/modules/welcome/welcome_page.dart';

import 'home_routes.dart';
import 'welcome_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
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
  ];
}
