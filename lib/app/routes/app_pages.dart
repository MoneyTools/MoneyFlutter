import 'home_routes.dart';
import 'welcome_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    ...HomeRoutes.routes,
    ...WelcomeRoutes.routes,
  ];
}
