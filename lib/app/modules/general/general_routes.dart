import 'package:get/get.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/modules/general/general_page.dart';

class GeneralRoutes {
  GeneralRoutes._();

  static final routes = [
    GetPage(
      name: Constants.routeSettingsPage,
      page: () => const GeneralPage(),
    ),
  ];
}
