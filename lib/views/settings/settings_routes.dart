import 'package:get/get.dart';
import 'package:money/data/models/constants.dart';
import 'package:money/views/settings/settings_page.dart';

class SettingsRoutes {
  SettingsRoutes._();

  static final routes = [
    GetPage(
      name: Constants.routeSettingsPage,
      page: () => const SettingsPage(),
    ),
  ];
}
