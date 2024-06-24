import 'package:get/get.dart';
import 'package:money/app/data/models/constants.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_page.dart';

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
