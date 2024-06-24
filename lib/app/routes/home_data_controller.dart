import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:money/app/core/helpers/file_systems.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/settings.dart';
import 'package:money/app/data/storage/data/data.dart';

class DataController extends GetxController {
  // Observable variables
  RxBool isLoading = true.obs;
  RxList<String> data = <String>[].obs;

  String get getUniqueState => '${Data().version}';

  @override
  void onInit() {
    super.onInit();
    debugLog('FileLoaderController onInit()');
    // loadLastFileSaved();
  }

  // Async method to fetch data
  Future<void> loadLastFileSaved() async {
    try {
      isLoading.value = true;
      final PreferenceController preferenceController = Get.find();

      if (preferenceController.mru.isNotEmpty) {
        await loadFile(DataSource(preferenceController.mru.first));
        Get.offNamed(Constants.routeHomePage);
        isLoading.value = false;
        return;
      }
    } catch (e) {
      // Handle error
      debugLog("Error fetching data: $e");
    }
    // Once the file is loaded, navigate to the main screen
    isLoading.value = false;

    Future.delayed(Duration.zero, () {
      Get.offNamed(Constants.routeWelcomePage);
    });
  }

  Future<void> loadDemoData() async {
    isLoading.value = true;
    Settings().fileManager.fullPathToLastOpenedFile = '';
    Settings().preferrenceSave();
    Data().loadFromDemoData();
    isLoading.value = false;
  }

  Future<void> loadFile(final DataSource dataSource) async {
    Settings().closeFile(false); // ensure that we closed current file and state

    await Data().loadFromPath(dataSource).then((final bool success) async {
      if (success) {
        final PreferenceController preferenceController = Get.find();
        preferenceController.addToMRU(dataSource.filePath);
      }
      isLoading.value = false;
    });
  }
}

class DataSource {
  DataSource([
    this.filePath = '',
    Uint8List? fileBytes,
  ]) : fileBytes = fileBytes ?? Uint8List(0);

  String filePath;
  Uint8List fileBytes;

  bool get isLocalFile => fileBytes.isEmpty && filePath.isNotEmpty && filePath.contains(MyFileSystems.pathSeparator);
  bool get isByteFile => fileBytes.isNotEmpty && filePath.isNotEmpty;
}
