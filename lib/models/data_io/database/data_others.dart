import 'package:money/helpers/json_helper.dart';
import 'package:sqlite3/sqlite3.dart';

class MyDatabaseImplementation {
  late final Database _db;

  MyDatabaseImplementation(final String fileToOpen) {
    _db = sqlite3.open(fileToOpen);
  }

  List<Json> select(final String query) {
    return _db.select(query);
  }

  void dispose() {
    _db.dispose();
  }
}
