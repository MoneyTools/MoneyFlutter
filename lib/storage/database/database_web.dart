import 'dart:typed_data';

import 'package:money/helpers/json_helper.dart';
import 'package:sqlite3/wasm.dart';

/// implement the Sqlite3 WASM Web Support see https://pub.dev/packages/sqlite3#wasm-web-support
class MyDatabaseImplementation {
  late final CommonDatabase _db;

  Future<void> load(final String fileToOpen, final Uint8List fileBytes) async {
    _db = await sqliteLoadFromMemory(fileBytes);
    // debugLog(_db.toString());
  }

  List<MyJson> select(final String query) {
    return _db.select(query);
  }

  /// SQL Insert
  void insert(final String tableName, final MyJson data) {}

  /// SQL Delete
  void delete(final String tableName, final int id) {}

  /// SQL Update
  void update(final String tableName, final int id, final MyJson jsonMap) {}

  void dispose() {}
}

Future<CommonDatabase> sqliteLoadFromMemory(Uint8List fileBytes) async {
  // Load the WebAssembly module
  final sqlite3 = await _loadSqlite3Wasm();

  // Create an in-memory database
  final db = sqlite3.openInMemory();

  // Load the database file bytes into the in-memory database
  db.execute('CREATE TABLE temp_table(data BLOB)');
  db.execute('INSERT INTO temp_table (data) VALUES (?)', [fileBytes]);

  return db;
}

Future<WasmSqlite3> _loadSqlite3Wasm() async {
  return await WasmSqlite3.loadFromUrl(Uri(path: 'sqlite3.wasm'));

  // final response = await http.get(Uri.parse('/sqlite3.wasm'));
  // if (response.statusCode != 200) {
  //   throw Exception('Failed to load sqlite3.wasm');
  // }
  // return await WasmSqlite3.load(
  //   response.bodyBytes,
  //   // environment: SqliteEnvironment.fromJsObject(),
  // );
}
