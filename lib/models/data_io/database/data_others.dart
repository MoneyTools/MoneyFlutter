import 'package:money/helpers/json_helper.dart';
import 'package:sqlite3/sqlite3.dart';

class MyDatabaseImplementation {
  late final Database _db;

  MyDatabaseImplementation(final String fileToOpen) {
    _db = sqlite3.open(fileToOpen);
  }

  List<MyJson> select(final String query) {
    return _db.select(query);
  }

  void insert(final String tableName, final MyJson data) {
    _db.execute(buildInsertCommand(tableName, data));
  }

  void dispose() {
    _db.dispose();
  }

  String buildInsertCommand(String tableName, MyJson data) {
    final columnNames = data.keys.join(', ');
    final columnValues = data.values.map((value) {
      if (value is String) {
        return "'$value'";
      } else {
        return value.toString();
      }
    }).join(', ');

    return 'INSERT INTO $tableName ($columnNames) VALUES ($columnValues)';
  }
}
