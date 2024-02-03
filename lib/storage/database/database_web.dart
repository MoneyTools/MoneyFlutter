import 'package:money/helpers/json_helper.dart';

/// TODO implement the Sqlite3 WASM Web Support see https://pub.dev/packages/sqlite3#wasm-web-support
class MyDatabaseImplementation {
  MyDatabaseImplementation(final String fileToOpen) {
    //
  }

  List<MyJson> select(final String query) {
    return [];
  }

  /// SQL Insert
  void insert(final String tableName, final MyJson data) {}

  /// SQL Delete
  void delete(final String tableName, final int id) {}

  /// SQL Update
  void update(final String tableName, final int id, final MyJson jsonMap) {}

  void dispose() {}
}
