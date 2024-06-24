import 'package:get/get.dart';
import 'package:money/app/data/models/constants.dart';

import 'welcome_binding.dart';
import 'welcome_page.dart';

class WelcomeRoutes {
  WelcomeRoutes._();

  static final routes = [
    GetPage(
      name: Constants.routeWelcomePage,
      page: () => const WelcomePage(),
      binding: WelcomeBinding(),
    ),
  ];
}
