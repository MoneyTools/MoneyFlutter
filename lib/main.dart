import 'package:get/get.dart';
import 'package:money/core/controller/data_controller.dart';
import 'package:money/core/controller/keyboard_controller.dart';
import 'package:money/core/controller/list_controller.dart';
import 'package:money/core/controller/my_window_manager.dart';
import 'package:money/core/controller/preferences_controller.dart';
import 'package:money/core/controller/theme_controller.dart';
import 'package:money/core/widgets/widgets.dart';
import 'package:money/views/home/home_routes.dart';
import 'package:money/views/platforms/platforms_routes.dart';
import 'package:money/views/policies/policy_routes.dart';
import 'package:money/views/settings/settings_routes.dart';
import 'package:money/views/splash_page.dart';
import 'package:money/views/welcome/welcome_page.dart';
import 'package:money/views/welcome/welcome_routes.dart';

import 'core/bindings/application_bindings.dart';

/// The main entry point for the MoneyFlutter application.
/// Sets up the app structure, theming, and initial routes.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MyWindowManager.setupMainWindow();

  runApp(MyApp());
}

/// Root widget of the application.
/// Configures the overall app theme and initial route.
class MyApp extends StatelessWidget {
  MyApp({super.key});

  final DataController dataController = Get.put(DataController());
  final ListControllerSidePanel listControllerSidePanel = Get.put(
    ListControllerSidePanel(),
  );

  // Use in the two major list
  final ListControllerMain listControllerMain = Get.put(ListControllerMain());

  // Leave these declared in this order
  final PreferenceController preferenceController = Get.put(
    PreferenceController(),
  );

  // Keyboard support
  final ShortcutController shortcutController = Get.put(ShortcutController());

  // Theme Color and Font Size
  final ThemeController themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    // Get.updateLocale(const Locale('en', 'US'));

    // Cache the S/M/L width for Widget that do not have access to BuildContext
    themeController.isDeviceWidthSmall.value = context.isWidthSmall;
    themeController.isDeviceWidthMedium.value = context.isWidthMedium;
    themeController.isDeviceWidthLarge.value = context.isWidthLarge;

    return Obx(() {
      final String k = preferenceController.getUniqueState;

      return GetMaterialApp(
        key: Key(k),
        debugShowCheckedModeBanner: false,
        theme: themeController.themeDataLight,
        darkTheme: themeController.themeDataDark,
        themeMode:
            themeController.isDarkTheme.value
                ? ThemeMode.dark
                : ThemeMode.light,
        title: 'MyMoney by VTeam',
        initialBinding: ApplicationBindings(),
        initialRoute: '/',
        getPages: <GetPage<dynamic>>[
          GetPage<dynamic>(
            name: '/',
            page: () {
              final PreferenceController preferenceController = Get.find();
              if (preferenceController.isReady.value) {
                return const WelcomePage();
              }
              return const SplashScreen();
            },
          ),
          ...HomeRoutes.routes,
          ...WelcomeRoutes.routes,
          ...SettingsRoutes.routes,
          ...PlatformsRoutes.routes,
          ...PolicyRoutes.routes,
        ],
      );
    });
  }
}
