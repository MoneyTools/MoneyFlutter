import 'package:money/helpers/date_helper.dart';
import 'package:money/helpers/file_systems.dart';
import 'package:money/helpers/string_helper.dart';
import 'package:money/models/settings.dart';
import 'package:path/path.dart' as p;

enum DataFileState {
  empty,
  loading,
  loaded,
}

class FileManager {
  String fullPathToLastOpenedFile = '';
  DateTime? dataFileLastUpdateDateTime;
  String fileName = '';

  String getLastModifiedDateTime() {
    return geDateAndTimeAsText(dataFileLastUpdateDateTime);
  }

  DataFileState state = DataFileState.empty;

  void rememberWhereTheDataCameFrom(final String dataSource) async {
    fullPathToLastOpenedFile = dataSource;
    if (dataSource.isEmpty) {
      dataFileLastUpdateDateTime = null;
    }
    Settings().preferrenceSave();
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

  bool shouldLoadLastDataFile() {
    return state == DataFileState.empty && fullPathToLastOpenedFile.isNotEmpty;
  }
}
