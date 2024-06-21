import 'dart:typed_data';

import 'package:money/helpers/date_helper.dart';
import 'package:money/helpers/file_systems.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/settings.dart';
import 'package:path/path.dart' as p;

class FileManager {
  String fullPathToLastOpenedFile = '';
  List<String> mru = [];
  Uint8List fileBytes = Uint8List(0); // use for WebInMemory SQL database
  DateTime? dataFileLastUpdateDateTime;
  String fileName = '';

  String getLastModifiedDateTime() {
    return dateToDateTimeString(dataFileLastUpdateDateTime);
  }

  void rememberWhereTheDataCameFrom(final String dataSource) async {
    addToMRU(dataSource);
    fullPathToLastOpenedFile = dataSource;
    if (dataSource.isEmpty) {
      dataFileLastUpdateDateTime = null;
    }
    await Settings().preferrenceSave();
  }

  // move or add the [filePathAndName] to the top of the list of MRU
  void addToMRU(final String filePathAndName) {
    if (filePathAndName.isNotEmpty) {
      mru.remove(filePathAndName);
      mru.insert(0, filePathAndName);
    }
  }

  Future<String> generateNextFolderToSaveTo() async {
    if (fullPathToLastOpenedFile.isNotEmpty) {
      if (p.extension(fullPathToLastOpenedFile) == 'mmcsv' || p.extension(fullPathToLastOpenedFile) == 'mmdb') {
        return p.dirname(fullPathToLastOpenedFile);
      }
    }
    return await getDocumentDirectory();
  }

  Future<String> defaultFolderToSaveTo(final String defaultFileName) async {
    return MyFileSystems.append(await getDocumentDirectory(), defaultFileName);
  }
}
