/// TODO implement the Sqlite3 WASM Web Support see https://pub.dev/packages/sqlite3#wasm-web-support
class MyDatabase {
  MyDatabase(final String fileToOpen) {
    //
  }

  List<Map<String, Object?>> select(final String query) {
    return <Map<String, Object?>>[];
  }

  void dispose() {}
}
