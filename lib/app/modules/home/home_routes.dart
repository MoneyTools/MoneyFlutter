import 'package:get/get.dart';
import 'package:money/app/data/models/constants.dart';
import 'home_binding.dart';
import 'home_page.dart';

class HomeRoutes {
  HomeRoutes._();

  static final routes = [
    GetPage(
      name: Constants.routeHomePage,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
  ];
}
