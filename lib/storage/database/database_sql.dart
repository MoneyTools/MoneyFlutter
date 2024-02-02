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

  /// SQL Insert
  void insert(final String tableName, final MyJson data) {
    final columnNames = data.keys.join(', ');
    final columnValues = data.values.map((value) => encodeValueWrapStringTypes(value)).join(', ');
    _db.execute('INSERT INTO $tableName ($columnNames) VALUES ($columnValues)');
  }

  /// SQL Delete
  void delete(final String tableName, final int id) {
    _db.execute('DELETE FROM $tableName WHERE Id=$id;');
  }

  /// SQL Update
  void update(final String tableName, final int id, final MyJson jsonMap) {
    final List<String> setStatements =
        jsonMap.keys.map((key) => '$key = ${encodeValueWrapStringTypes(jsonMap[key])}').toList();

    String fieldNamesAndValues = setStatements.join(', ');
    _db.execute('UPDATE $tableName SET $fieldNamesAndValues} WHERE Id=$id;');
  }

  void dispose() {
    _db.dispose();
  }
}
