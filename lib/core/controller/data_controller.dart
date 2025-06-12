// ignore_for_file: unnecessary_this
import 'dart:io'; // Keep for Platform checks if any remain, or if used by Data()
import 'dart:typed_data'; // Keep for Uint8List if used by Data()

import 'package:flutter/foundation.dart'; // Keep for kIsWeb if used
import 'package:get/get.dart';
import 'package:money/core/controller/preferences_controller.dart';
// Remove direct file system helpers if all usage is through FileService
// import 'package:money/core/helpers/file_systems.dart'; // MyFileSystems may still be used by Data()
import 'package:money/core/helpers/string_helper.dart'; // For logger, Constants
import 'package:money/core/services/file_service.dart'; // Import the new FileService
import 'package:money/core/widgets/snack_bar.dart';
import 'package:money/data/models/money_objects/accounts/account.dart';
import 'package:money/data/storage/data/data.dart';
import 'package:money/data/storage/data/data_mutations.dart';
// Remove path if all path logic is in FileService
import 'package:path/path.dart' as p;


/// Controller for managing data file operations.
/// Features:
/// - Load/save files in multiple formats (delegating to FileService and Data)
/// - Track file state and modifications
/// - Manage MRU list
class DataController extends GetxController {
  // FileService will be obtained via Get.find() or constructor
  // Not making it static as it might have its own dependencies or state if it evolves.
  final FileService _fileService = Get.find<FileService>();

  Rxn<DateTime> currentLoadedFileDateTime = Rxn<DateTime>();
  RxString currentLoadedFileName = Constants.untitledFileName.obs;
  // data field seems unused, consider removing if confirmed elsewhere.
  // RxList<String> data = <String>[].obs;
  // String fileName = ''; // This also seems unused in the provided snippet.

  RxBool isLoading = true.obs;
  DataMutations trackMutations = DataMutations();

  void closeFile([bool rebuild = true]) {
    Data().close();
    dataFileIsClosed();
    trackMutations.reset();
    isLoading.value = false;
    // 'rebuild' parameter seems to imply UI update, ensure GetX handles this or call relevant update methods.
  }

  void dataFileIsClosed() {
    currentLoadedFileName.value = Constants.untitledFileName;
    currentLoadedFileDateTime.value = null;
  }

  // This method is now mostly handled by FileService.getDefaultSavePathForFile
  // or FileService.getSavePath. If DataController still needs a default name construction,
  // it would use FileService.
  Future<String> _getDefaultSavePath(String defaultFileName) async {
    return _fileService.getDefaultSavePathForFile(defaultFileName);
  }

  // This method is now mostly handled by FileService.getParentDirectoryForFileToSave
  Future<String> _getDirectoryToSaveTo() async {
    return _fileService.getParentDirectoryForFileToSave(
      currentLoadedFileName.value == Constants.untitledFileName ? null : currentLoadedFileName.value,
      'mmdb', // Assuming 'mmdb' is a common default, or make this dynamic
    );
  }

  bool get isUntitled => currentLoadedFileName.value == Constants.untitledFileName;

  String get lastUpdateAsString => '${trackMutations.lastDateTimeChanged}';

  Future<void> loadDemoData() async {
    isLoading.value = true;
    // Assuming Data().loadFromDemoData() doesn't involve direct file picking.
    // If it loads a bundled asset, that logic is within Data().
    Data().loadFromDemoData();
    // After loading demo data, the file isn't "saved" in a user-accessible location yet.
    dataFileIsClosed(); // Reflects that it's not a user-saved file.
    trackMutations.reset(); // Demo data is a clean slate.
    isLoading.value = false;
  }

  // Centralized file loading logic, now using FileService for DataSource
  Future<bool> _loadFileInternal(DataSource dataSource) async {
    this.closeFile(false); // Ensure current file and state are closed

    isLoading.value = true;
    final bool success = await Data().loadFromPath(dataSource);
    isLoading.value = false;

    if (success) {
      setCurrentFileName(dataSource.filePath); // filePath might be just a name for web
      if (dataSource.hasPath && !kIsWeb) { // Only get modified time if it's a real path and not web
          currentLoadedFileDateTime.value = await _fileService.getFileModifiedTime(dataSource.filePath);
      } else {
          currentLoadedFileDateTime.value = null; // No relevant modified time for web-loaded bytes or if no path
      }
      // Navigation should be handled by the caller or a dedicated navigation service if complex.
      // For now, keeping it as it was.
      Future<Null>.delayed(Duration.zero, () {
        Get.offNamed<dynamic>(Constants.routeHomePage);
      });
    } else {
      // If loading failed, reset to untitled state
      dataFileIsClosed();
    }
    return success;
  }

  // Retained for API compatibility if anything external calls this directly.
  // Otherwise, it could be merged or made private.
  Future<bool> loadFile(final DataSource dataSource) async {
    return _loadFileInternal(dataSource);
  }

  Future<void> loadLastFileSaved() async {
    try {
      isLoading.value = true;
      if (PreferenceController.to.mru.isNotEmpty) {
        final String lastFilePath = PreferenceController.to.mru.first;
        // We need to construct a DataSource. For desktop, path is enough.
        // For web, if MRU could store web "files", this would need more info.
        // Assuming MRU paths are device paths for now.
        // If lastFilePath could be a web "name", FileService would need a way to "re-open" it,
        // which is not typical for web file handling (usually re-pick).
        // This implies MRU for web might be less useful or behave differently.
        DataSource? dataSource;
        if (kIsWeb) {
            // This is tricky for web. MRU usually stores paths, but web files are bytes post-picker.
            // We can't directly re-load from a "path" (name) on web without user re-picking.
            // For now, if it's web and MRU has something, it's likely a non-web path, which is an issue.
            // Or, if it's a name of a file previously loaded via picker, we can't get its bytes again here.
            // This indicates a potential design consideration for MRU on web.
            // Let's assume for now MRU paths are non-web, or this won't work as expected on web.
            logger.w("loadLastFileSaved on web: MRU may not be reliable for direct file re-loading without user interaction.");
            // To prevent errors, clear loading and navigate to welcome, similar to no MRU.
             isLoading.value = false;
             Future<Null>.delayed(Duration.zero, () {
               Get.offNamed<dynamic>(Constants.routeWelcomePage);
             });
            return;
        } else {
            dataSource = DataSource(filePath: lastFilePath);
        }
        await _loadFileInternal(dataSource);
        return;
      } else {
        isLoading.value = false;
        Future<Null>.delayed(Duration.zero, () {
          Get.offNamed<dynamic>(Constants.routeWelcomePage);
        });
      }
    } catch (e) {
      logger.e('Error fetching data: $e');
      isLoading.value = false;
      dataFileIsClosed(); // Ensure clean state on error
    }
  }

  void onFileNew() async {
    this.closeFile(); // Closes current data, resets state to untitled

    // The following logic is application-specific for creating a new "session"
    // and doesn't directly involve FileService opening/saving a file yet.
    final Account newAccount = Data().accounts.addNewAccount('New Bank Account');
    PreferenceController.to.jumpToView(
      viewId: ViewId.viewAccounts,
      selectedId: newAccount.uniqueId,
      textFilter: '',
      columnFilters: null,
    );
    // File is considered "new" and "untitled", not yet saved.
    // Mutations will start tracking from this point for a future save.
  }

  Future<bool> onFileOpen() async {
    final DataSource? dataSource = await _fileService.pickOpenFile();
    if (dataSource != null) {
      // Check if the picked source is of a type that implies direct loading (mmdb, mmcsv)
      // Other types like QFX, OFX, JSON might go through an import flow rather than direct load.
      // The original code checked for 'mmdb' or 'mmcsv' extension after picking.
      // FileService.pickOpenFile now has _supportedFileExtensions, which is broader.
      // We need to decide if all "supported" types imply a full load or if some are imports.
      // For now, assume any DataSource returned by pickOpenFile is meant for direct loading.
      // This matches the previous logic more closely.
      final String? fileExtension = dataSource.hasPath ? p.extension(dataSource.filePath).toLowerCase().replaceFirst('.', '') : null;

      if (dataSource.hasBytes || (fileExtension != null && (fileExtension == 'mmdb' || fileExtension == 'mmcsv'))) {
         return await _loadFileInternal(dataSource);
      } else {
        // Handle other file types (QIF, OFX, JSON) - typically these are IMPORTED, not OPENED.
        // This part of the logic might need to be moved to an "import" flow.
        // For now, mimicking the old behavior: if it's not mmdb/mmcsv, it didn't load.
        // This is a good point for future improvement: distinguish "open project" from "import into current project".
        logger.i("File picked is not a primary data file (mmdb/mmcsv). Consider an import flow. Path: ${dataSource.filePath}");
        SnackBarService.displayInfo(message: "Selected file (${dataSource.filePath}) is not a primary data file. Use import options if available.");
        return false;
      }
    }
    return false;
  }

  void onSaveToCsv() async {
    if (Data().isEmpty()) {
      SnackBarService.displayInfo(message: "No data to save.");
      return;
    }

    // 1. Get the desired save path from FileService
    String? actualFileName = currentLoadedFileName.value;
    if (isUntitled || p.extension(actualFileName).toLowerCase() != '.mmcsv') {
        actualFileName = 'mymoney.mmcsv'; // Default name
    }

    final String targetDirectory = await _getDirectoryToSaveTo();
    final String suggestedPath = p.join(targetDirectory, actualFileName);

    final String? savePath = await _fileService.getSavePath(
      defaultFileName: suggestedPath, // FileService might just use the filename part
      allowedExtensions: ['mmcsv'],
    );

    if (savePath != null && savePath.isNotEmpty) {
      isLoading.value = true;
      try {
        // 2. Tell Data() to save to that path
        // Assuming Data().saveToCsv now takes the full path.
        // If Data().saveToCsv() returns the path it saved to, use that.
        final String savedFilePath = await Data().saveToCsv(filePathToSaveTo: savePath);

        // 3. Update state based on successful save
        setCurrentFileName(savedFilePath); // Update current file to the new CSV path
        currentLoadedFileDateTime.value = await _fileService.getFileModifiedTime(savedFilePath);
        PreferenceController.to.addToMRU(savedFilePath);
        trackMutations.reset(); // Data is now saved
        SnackBarService.displayInfo(message: 'Saved to $savedFilePath');
      } catch (e) {
        logger.e('Error saving to CSV: ${e.toString()}');
        SnackBarService.displayError(message: 'Error saving to CSV: ${e.toString()}');
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<bool> onSaveToSql({bool saveAs = false}) async {
    if (Data().isEmpty()) {
      SnackBarService.displayInfo(message: "No data to save.");
      return false;
    }

    String fileNameAndPath = currentLoadedFileName.value;

    // If "Save As" or if the current file is not an mmdb, or it's untitled, get a new path.
    if (saveAs || isUntitled || p.extension(fileNameAndPath).toLowerCase() != '.mmdb') {
      final String targetDirectory = await _getDirectoryToSaveTo();
      final String suggestedPath = p.join(targetDirectory, 'mymoney.mmdb');

      fileNameAndPath = await _fileService.getSavePath(
        defaultFileName: suggestedPath, // FileService might just use the filename part
        allowedExtensions: ['mmdb'],
      ) ?? ''; // Ensure it's not null
    }

    if (fileNameAndPath.isEmpty) {
      return false; // User cancelled Save As
    }

    isLoading.value = true;
    bool success = false;
    try {
      // Data().saveToSql should handle the actual writing to fileNameAndPath
      success = await Data().saveToSql(
        filePath: fileNameAndPath,
        onSaveCompleted: (final bool opSuccess, final String message) {
          // This callback is a bit redundant if saveToSql awaits and returns status.
          // Assuming it's for finer-grained status updates during the save.
          if (opSuccess) {
            if (message.isNotEmpty) SnackBarService.displayInfo(message: message);
          } else {
            SnackBarService.displayError(autoDismiss: false, message: message);
          }
        },
      );

      if (success) {
        setCurrentFileName(fileNameAndPath);
        currentLoadedFileDateTime.value = await _fileService.getFileModifiedTime(fileNameAndPath);
        PreferenceController.to.addToMRU(fileNameAndPath);
        trackMutations.reset();
        // SnackBar for success already handled by onSaveCompleted or could be added here
      }
    } catch (e) {
        logger.e('Error saving to SQL: ${e.toString()}');
        SnackBarService.displayError(message: 'Error saving to SQL: ${e.toString()}');
        success = false;
    } finally {
        isLoading.value = false;
    }
    return success;
  }

  void onShowFileLocation() async {
    if (!isUntitled && currentLoadedFileName.value.isNotEmpty) {
      // Use FileService to show the directory of the current file.
      // p.dirname might be needed if currentLoadedFileName is a full path.
      // If it's just a name (e.g. for web), this might not make sense.
      if (!kIsWeb) { // Showing file location is not applicable for web-loaded files
        final String directoryPath = p.dirname(currentLoadedFileName.value);
        if (directoryPath.isNotEmpty && directoryPath != '.') {
             await _fileService.showFileInExplorer(directoryPath);
        } else {
            // If it's just a filename without a path, show the default save directory
            final String defaultSaveDir = await _fileService.getDefaultSaveDirectory();
            await _fileService.showFileInExplorer(defaultSaveDir);
        }
      } else {
        SnackBarService.displayInfo(message: "File location not applicable for web-loaded data.");
      }
    } else {
      // If no file is loaded, show the default location where files would be saved.
      final String defaultSaveDir = await _fileService.getDefaultSaveDirectory();
      await _fileService.showFileInExplorer(defaultSaveDir);
    }
  }

  void setCurrentFileName(final String filenameLoaded) {
    // Normalize filename for display and storage if needed
    currentLoadedFileName.value = filenameLoaded;
    if (filenameLoaded != Constants.untitledFileName) {
        PreferenceController.to.addToMRU(filenameLoaded);
    }
  }

  static DataController get to => Get.find();
}

// The DataSource class definition should be REMOVED from here,
// as it's now part of file_service.dart.
// class DataSource { ... }
