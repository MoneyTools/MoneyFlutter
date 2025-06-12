import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:money/core/helpers/file_systems.dart'; // Assuming this exists and has 'append'
import 'package:money/core/helpers/string_helper.dart'; // For logger, Constants
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
// It's not clear where showLocalFolder comes from. If it's a custom utility,
// this service might need a way to access it, or it's part of MyFileSystems.
// For now, we'll assume MyFileSystems might have it or it's a global utility.

// Definition for DataSource, assuming it will be moved here or be accessible.
// If it remains in data_controller.dart, this import would be needed:
// import 'package:money/core/controller/data_controller.dart'; // For DataSource

class DataSource {
  DataSource({this.filePath = '', Uint8List? fileBytes}) : _fileBytes = fileBytes ?? Uint8List(0);

  final String filePath;
  final Uint8List _fileBytes;

  Uint8List get fileBytes => _fileBytes;

  bool get hasBytes => _fileBytes.isNotEmpty;
  bool get hasPath => filePath.isNotEmpty;
}

class FileService {
  static const List<String> _supportedFileExtensions = <String>[
    'mmdb',
    'mmcsv',
    'sdf',
    'qfx',
    'ofx',
    'json',
  ];

  Future<DataSource?> pickOpenFile() async {
    FilePickerResult? pickerResult;

    try {
      if (kIsWeb) {
        pickerResult = await FilePicker.platform.pickFiles(type: FileType.any); // Web doesn't reliably support custom extensions
      } else if (Platform.isAndroid || Platform.isIOS) {
        pickerResult = await FilePicker.platform.pickFiles(type: FileType.any); // Might be better to allow any on mobile too
      } else {
        // Desktop
        pickerResult = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: _supportedFileExtensions,
        );
      }

      if (pickerResult != null && pickerResult.files.isNotEmpty) {
        final PlatformFile file = pickerResult.files.first;
        final String? fileExtension = file.extension?.toLowerCase();

        // Validate if the extension is one we generally handle for direct loading
        // This is a loose validation here, DataController/Data layer will do the strict check.
        if (_supportedFileExtensions.contains(fileExtension) || kIsWeb || Platform.isAndroid || Platform.isIOS) {
          if (kIsWeb) {
            return DataSource(
              filePath: file.name,
              fileBytes: file.bytes!,
            );
          } else {
            return DataSource(
              filePath: file.path ?? file.name, // file.path should be available on desktop/mobile
            );
          }
        } else {
          logger.w('User picked an unsupported file type: $fileExtension');
          // Optionally, show a message to the user here via a snackbar service if available globally
          return null;
        }
      }
    } catch (e) {
      logger.e('Error picking file: ${e.toString()}');
      // Optionally, show a message to the user
      return null;
    }
    return null;
  }

  Future<String?> getSavePath({
    required String defaultFileName,
    List<String>? allowedExtensions,
  }) async {
    String? outputFile;
    try {
      // For web, save dialogs are handled by browser, usually just providing filename
      // For desktop, FilePicker can be used to get a save path.
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
         outputFile = await FilePicker.platform.saveFile(
            dialogTitle: 'Please select an output file:',
            fileName: defaultFileName,
            allowedExtensions: allowedExtensions,
            type: allowedExtensions != null && allowedExtensions.isNotEmpty ? FileType.custom : FileType.any,
         );
      } else {
        // On Web and Mobile, direct save dialogs like desktop are not standard.
        // Typically, you'd provide the bytes to a download mechanism on web,
        // or save to app-specific/shared storage on mobile.
        // This method's current signature is more desktop-like.
        // For now, we'll just return the defaultFileName, implying the caller handles the actual "save" action.
        logger.i("getSavePath: Web/Mobile platforms might not use a save dialog in this way. Returning defaultFileName.");
        outputFile = defaultFileName; // Placeholder for web/mobile behavior
      }
      return outputFile;
    } catch (e) {
      logger.e('Error getting save path: ${e.toString()}');
      return null;
    }
  }

  Future<String> getDefaultSaveDirectory() async {
    if (kIsWeb) {
      // Web doesn't have a concept of a user-browsable "documents" directory via path_provider
      return ''; // Or handle differently, e.g. by always "downloading"
    }
    try {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e) {
      logger.e('Error getting documents directory: ${e.toString()}');
      return '.'; // Fallback to current directory or handle error appropriately
    }
  }

  Future<String> getDefaultSavePathForFile(String fileName) async {
    final dir = await getDefaultSaveDirectory();
    if (dir.isEmpty && kIsWeb) { // Web case
        return fileName;
    }
    return MyFileSystems.append(dir, fileName); // Assuming MyFileSystems.append handles path joining correctly
  }

  Future<String> getParentDirectoryForFileToSave(String? existingFilePath, String defaultExtension) async {
    if (existingFilePath != null && existingFilePath.isNotEmpty) {
      final String currentExtension = p.extension(existingFilePath).replaceFirst('.', '');
      // Check if the existing file's extension is one of our primary data formats
      if (currentExtension == 'mmdb' || currentExtension == 'mmcsv' || currentExtension == defaultExtension) {
        final String dirName = p.dirname(existingFilePath);
        if (dirName.isNotEmpty && dirName != '.') {
             return dirName;
        }
      }
    }
    return await getDefaultSaveDirectory();
  }

  Future<DateTime?> getFileModifiedTime(String filePath) async {
    if (kIsWeb) {
      // Cannot get file modified time from path for web post-selection via standard file APIs
      return null;
    }
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.lastModified();
      }
    } catch (e) {
      logger.e('Error getting file modified time for $filePath: ${e.toString()}');
    }
    return null;
  }

  Future<void> showFileInExplorer(String path) async {
    if (kIsWeb) {
      logger.i("showFileInExplorer: Not applicable for web platform.");
      return;
    }
    try {
      // Assuming showLocalFolder is a global or static utility function.
      // This might come from a helper class like MyFileSystems or a platform channel.
      // Example: MyFileSystems.showLocalFolder(path);
      // For this implementation, we'll log and assume it exists elsewhere.
      logger.i("Attempting to show '$path' in explorer via external utility showLocalFolder.");
      // Replace with actual call if available: e.g. await Desktop.open(path) or custom code.
      // For now, this is a conceptual placeholder.
      // If using url_launcher, it could be:
      // final uri = Uri.file(path);
      // if (await canLaunchUrl(uri)) {
      //   await launchUrl(uri);
      // } else {
      //   logger.e('Could not launch $path');
      // }
      // However, launchUrl might open the file, not show it in explorer.
      // This functionality is often platform-specific.
      MyFileSystems.showPathInSystemExplorer(path); // Placeholder for actual implementation
    } catch (e) {
      logger.e('Error showing path $path in explorer: ${e.toString()}');
    }
  }
}

// Placeholder for logger if not globally available or part of StringHelper
// class Logger {
//   void e(String message) => print('ERROR: $message');
//   void w(String message) => print('WARN: $message');
//   void i(String message) => print('INFO: $message');
// }
// final logger = Logger();

// Placeholder for Constants if not part of StringHelper
// class Constants {
//   static const String untitledFileName = 'Untitled';
// }

// Minimal MyFileSystems for placeholder if not available
// class MyFileSystems {
//   static String append(String part1, String part2) => p.join(part1, part2);
//   static Future<void> showPathInSystemExplorer(String path) async {
//     print("Mock: Showing $path in system explorer");
//     // Actual implementation would use platform channels or specific packages.
//   }
// }
