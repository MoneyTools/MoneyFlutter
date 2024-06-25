import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:money/app/core/helpers/file_systems.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/controller/general_controller.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/data/storage/data/data_mutations.dart';
import 'package:path/path.dart' as p;

class DataController extends GetxController {
  // Observable variables
  RxBool isLoading = true.obs;
  RxList<String> data = <String>[].obs;
  RxString currentLoadedFileName = Constants.untitledFileName.obs;

  DateTime? dataFileLastUpdateDateTime;

  String fileName = '';
  String get getUniqueState => '${Data().version}';
  bool get isUntitled => currentLoadedFileName.value == Constants.untitledFileName;

  // Tracking changes
  DataMutations trackMutations = DataMutations();

  void dataFileIsClosed() {
    currentLoadedFileName.value = Constants.untitledFileName;
  }

  Future<String> defaultFolderToSaveTo(final String defaultFileName) async {
    return MyFileSystems.append(await getDocumentDirectory(), defaultFileName);
  }

  Future<String> generateNextFolderToSaveTo() async {
    if (currentLoadedFileName.value.isNotEmpty) {
      if (p.extension(currentLoadedFileName.value) == 'mmcsv' || p.extension(currentLoadedFileName.value) == 'mmdb') {
        return p.dirname(currentLoadedFileName.value);
      }
    }
    return await getDocumentDirectory();
  }

  Future<void> loadDemoData() async {
    isLoading.value = true;
    Settings().preferrenceSave();
    Data().loadFromDemoData();
    isLoading.value = false;
  }

  Future<void> loadFile(final DataSource dataSource) async {
    Settings().closeFile(false); // ensure that we closed current file and state

    await Data().loadFromPath(dataSource).then((final bool success) async {
      if (success) {
        setCurrentFileName(dataSource.filePath);
        Future.delayed(Duration.zero, () {
          Get.offNamed(Constants.routeHomePage);
        });
      }
      isLoading.value = false;
    });
  }

  // Async method to fetch data
  Future<void> loadLastFileSaved() async {
    try {
      isLoading.value = true;
      final PreferenceController preferenceController = Get.find();

      if (preferenceController.mru.isNotEmpty) {
        await loadFile(DataSource(preferenceController.mru.first));
        return;
      } else {
        // Once the file is loaded, navigate to the main screen
        isLoading.value = false;

        Future.delayed(Duration.zero, () {
          Get.offNamed(Constants.routeWelcomePage);
        });
      }
    } catch (e) {
      // Handle error
      debugLog("Error fetching data: $e");
    }
  }

  @override
  void onInit() {
    super.onInit();
    debugLog('FileLoaderController onInit()');
    // loadLastFileSaved();
  }

  void setCurrentFileName(final String filenameLoaded) {
    currentLoadedFileName.value = filenameLoaded;
    final PreferenceController preferenceController = Get.find();
    preferenceController.addToMRU(filenameLoaded);
  }
}

class DataSource {
  String filePath;

  Uint8List fileBytes;
  DataSource([
    this.filePath = '',
    Uint8List? fileBytes,
  ]) : fileBytes = fileBytes ?? Uint8List(0);

  bool get isByteFile => fileBytes.isNotEmpty && filePath.isNotEmpty;
  bool get isLocalFile => fileBytes.isEmpty && filePath.isNotEmpty && filePath.contains(MyFileSystems.pathSeparator);
}
