import 'package:get/get.dart';
import 'package:money/app/data/models/constants.dart';

import '../modules/welcome/welcome_binding.dart';
import '../modules/welcome/welcome_page.dart';

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
