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
  String fileName = '';

  DataFileState state = DataFileState.empty;

  void rememberWhereTheDataCameFrom(final String dataSource) async {
    fullPathToLastOpenedFile = dataSource;
    Settings().save();
  }

  Future<String> generateNextFolderToSaveTo() async {
    if (fullPathToLastOpenedFile.isNotEmpty) {
      if (p.extension(fullPathToLastOpenedFile) == 'mmcsv' || p.extension(fullPathToLastOpenedFile) == 'mmdb') {
        return p.dirname(fullPathToLastOpenedFile);
      }
    }
    return await getDocumentDirectory();
  }

  bool shouldLoadLastDataFile() {
    return state == DataFileState.empty && fullPathToLastOpenedFile.isNotEmpty;
  }
}
