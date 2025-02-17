import 'package:get/get.dart';
import 'package:money/data/models/constants.dart';
import 'package:money/views/settings/settings_page.dart';

/// Defines the routes for the settings page in the application.
class SettingsRoutes {
  SettingsRoutes._();

  /// Defines the routes for the settings page in the application.
  /// This includes a single route for the SettingsPage.
  static final routes = [
    GetPage<dynamic>(
      name: Constants.routeSettingsPage,
      page: () => const SettingsPage(),
    ),
  ];
}
