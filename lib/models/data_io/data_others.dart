import 'package:sqlite3/sqlite3.dart';

class MyDatabase {
  late final Database _db;

  MyDatabase(final String fileToOpen) {
    _db = sqlite3.open(fileToOpen);
  }

  List<Map<String, Object?>> select(final String query) {
    return _db.select(query);
  }

  void dispose() {
    _db.dispose();
  }
}
