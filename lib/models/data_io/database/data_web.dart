import 'package:money/helpers/json_helper.dart';

/// TODO implement the Sqlite3 WASM Web Support see https://pub.dev/packages/sqlite3#wasm-web-support
class MyDatabaseImplementation {
  MyDatabaseImplementation(final String fileToOpen) {
    //
  }

  List<Json> select(final String query) {
    return <Json>[];
  }

  void dispose() {}
}
