// ignore_for_file: unnecessary_this
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/core/helpers/file_systems.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/core/widgets/snack_bar.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/data/storage/data/data_mutations.dart';
import 'package:path/path.dart' as p;

class DataController extends GetxController {
  static DataController get to => Get.find();

  // Observable variables
  RxBool isLoading = true.obs;
  RxList<String> data = <String>[].obs;
  RxString currentLoadedFileName = Constants.untitledFileName.obs;
  Rxn<DateTime> currentLoadedFileDateTime = Rxn<DateTime>();
  String fileName = '';
  String get getUniqueState => '${Data().version}';
  bool get isUntitled => currentLoadedFileName.value == Constants.untitledFileName;

  // Tracking changes
  DataMutations trackMutations = DataMutations();

  void dataFileIsClosed() {
    currentLoadedFileName.value = Constants.untitledFileName;
    currentLoadedFileDateTime.value = null;
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
    Data().loadFromDemoData();
    isLoading.value = false;
  }

  Future<void> loadFile(final DataSource dataSource) async {
    this.closeFile(false); // ensure that we closed current file and state

    await Data().loadFromPath(dataSource).then((final bool success) async {
      if (success) {
        setCurrentFileName(dataSource.filePath);
        currentLoadedFileDateTime.value = await getFileModifiedTime(dataSource.filePath);
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

      if (PreferenceController.to.mru.isNotEmpty) {
        await loadFile(DataSource(PreferenceController.to.mru.first));
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
      debugLog('Error fetching data: $e');
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

  static Future<DateTime?> getFileModifiedTime(String filePath) async {
    try {
      if (await MyFileSystems.doesFileExist(filePath)) {
        final file = File(filePath);
        final fileStat = await file.stat();
        return fileStat.modified;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void closeFile([bool rebuild = true]) {
    Data().close();
    DataController.to.dataFileIsClosed();
    DataController.to.trackMutations.reset();
  }

  void onFileNew() async {
    this.closeFile();

    Data().accounts.addNewAccount('New Bank Account');
    PreferenceController.to.setView(ViewId.viewAccounts);
  }

  Future<void> loadFileFromPath(final DataSource dataSource) async {
    final DataController dataController = Get.find();
    dataController.loadFile(dataSource);
  }

  void onShowFileLocation() async {
    String path = await DataController.to.generateNextFolderToSaveTo();
    showLocalFolder(path);
  }

  void onSaveToCsv() async {
    final String fullPathToFileName = await Data().saveToCsv();

    PreferenceController.to.addToMRU(fullPathToFileName);

    Data().assessMutationsCountOfAllModels();
  }

  void onSaveToSql() async {
    String fileNameAndPath = DataController.to.currentLoadedFileName.value;

    if (fileNameAndPath.isEmpty) {
      // this happens if the user started with a new file and click save to SQL
      fileNameAndPath = await DataController.to.defaultFolderToSaveTo('mymoney.mmdb');
    }

    Data().saveToSql(
      filePathToLoad: fileNameAndPath,
      callbackWhenLoaded: (final bool success, final String message) {
        if (success) {
          Data().assessMutationsCountOfAllModels();
        } else {
          SnackBarService.displayError(autoDismiss: false, message: message);
        }
      },
    );

    PreferenceController.to.addToMRU(fileNameAndPath);
  }

  Future<bool> onFileOpen() async {
    FilePickerResult? pickerResult;

    const supportedFileTypes = <String>[
      'mmdb',
      'mmcsv',
      'sdf',
      'qfx',
      'ofx',
      'json',
    ];

    try {
      // WEB
      if (kIsWeb) {
        pickerResult = await FilePicker.platform.pickFiles(
          type: FileType.any,
        );
      } else
      // Mobile
      if (Platform.isAndroid || Platform.isIOS) {
        // See https://github.com/miguelpruivo/flutter_file_picker/issues/729
        pickerResult = await FilePicker.platform.pickFiles(type: FileType.any);
      } else
      // Desktop
      {
        pickerResult = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: supportedFileTypes,
        );
      }
    } catch (e) {
      debugLog(e.toString());
      SnackBarService.displayError(message: e.toString());
      return false;
    }

    if (pickerResult != null && pickerResult.files.isNotEmpty) {
      try {
        final String? fileExtension = pickerResult.files.single.extension;

        if (fileExtension == 'mmdb' || fileExtension == 'mmcsv') {
          DataSource dataSource = DataSource();
          if (kIsWeb) {
            PlatformFile file = pickerResult.files.first;
            dataSource.filePath = file.name;
            dataSource.fileBytes = file.bytes!;
          } else {
            dataSource.filePath = pickerResult.files.single.path ?? '';
          }
          final DataController dataController = Get.find();
          dataController.loadFile(dataSource);
          return true;
        }
      } catch (e) {
        debugLog(e.toString());
        SnackBarService.displayError(message: e.toString());
      }
    }
    return false;
  }
}

class DataSource {
  DataSource([
    this.filePath = '',
    Uint8List? fileBytes,
  ]) : fileBytes = fileBytes ?? Uint8List(0);
  String filePath;

  Uint8List fileBytes;

  bool get isByteFile => fileBytes.isNotEmpty && filePath.isNotEmpty;
  bool get isLocalFile => fileBytes.isEmpty && filePath.isNotEmpty && filePath.contains(MyFileSystems.pathSeparator);
}
