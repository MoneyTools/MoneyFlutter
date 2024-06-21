import 'package:get/get.dart';

import '../modules/welcome/welcome_binding.dart';
import '../modules/welcome/welcome_page.dart';

class WelcomeRoutes {
  WelcomeRoutes._();

  static const welcome = '/welcome';

  static final routes = [
    GetPage(
      name: welcome,
      page: () => const WelcomePage(),
      binding: WelcomeBinding(),
    ),
  ];
}
