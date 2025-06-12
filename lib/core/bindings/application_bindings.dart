import 'package:get/get.dart';
import 'package:money/core/services/file_service.dart'; // Import the FileService

/// Initial dependency bindings for the application.
/// Responsible for:
/// - Setting up core controllers
/// - Initializing services
/// - Configuring dependencies
class ApplicationBindings extends Bindings {
  @override
  void dependencies() {
    // Register FileService as a lazy singleton.
    // It will be created once Get.find<FileService>() is called for the first time.
    Get.lazyPut<FileService>(() => FileService());

    // Other existing bindings (if any) would remain here.
    // For example, if DataController and others were registered here:
    // Get.lazyPut<PreferenceController>(() => PreferenceController());
    // Get.lazyPut<ThemeController>(() => ThemeController());
    // Get.lazyPut<DataController>(() => DataController());
    // Get.lazyPut<ListControllerSidePanel>(() => ListControllerSidePanel());
    // Get.lazyPut<ListControllerMain>(() => ListControllerMain());
  }
}
