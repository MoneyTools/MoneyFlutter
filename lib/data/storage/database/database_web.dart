// ignore_for_file: avoid_web_libraries_in_flutter, avoid_print
import 'dart:async';
import 'dart:js' as js;
import 'dart:typed_data';
import 'package:money/core/helpers/json_helper.dart';

/// implement the Sqlite3 WASM Web Support see https://pub.dev/packages/sqlite3#wasm-web-support
class MyDatabaseImplementation {
  void dispose() {}

  void execute(final String query) {}

  /// SQL Delete
  void itemDelete(final String tableName, final String whereClause) {}

  /// SQL Insert
  void itemInsert(final String tableName, final MyJson data) {}

  /// SQL Update
  void itemUpdate(final String tableName, final MyJson jsonMap, final String whereClause) {}

  Future<void> load(final String fileToOpen, final Uint8List fileBytes) async {
    try {
      final jsArray = js.JsObject.jsify(fileBytes);
      // Pass the array to JavaScript function to load the database
      await js.context.callMethod('loadDatabaseFromBinary', [jsArray]);
    } catch (e) {
      // Rollback the transaction if an error occurs
      // _db.execute('ROLLBACK');
      // print('Error loading database: $e');
      rethrow;
    } finally {
      // Clean up the temporary table
      // _db.execute('DROP TABLE IF EXISTS temp_table');
    }
  }

  Future<List<Map<String, dynamic>>> select(final String query) async {
    try {
      final jsObjectResult = await js.context.callMethod('executeSql', [query]);

      if (jsObjectResult == null || jsObjectResult.length == 0) {
        // no results found from the query
        // print('No results found');
        return [];
      }

      // Access the first result set, ensuring it's a JsObject
      final dynamic firstResult = jsObjectResult[0];
      if (firstResult == null || firstResult is! js.JsObject) {
        print('Error: The result set structure is unexpected.');
        return [];
      }
      // Convert the JsObject result to List<Map<String, dynamic>>
      return _convertJsResultToList(firstResult);
    } catch (e) {
      print('Error executing query: $e');
      return [];
    }
  }

  /// Check if a table exists in the database
  Future<bool> tableExists(final String tableName) async {
    try {
      final list = await select("SELECT name FROM sqlite_master WHERE type='table'");
      return _listMapContains(list, 'name', tableName);
    } catch (e) {
      print('Error checking if table exists: $e');
      return false;
    }
  }

  // Helper to convert JsObject to List<Map<String, dynamic>>
  List<Map<String, dynamic>> _convertJsResultToList(js.JsObject jsResult) {
    final List<String> columns = List<String>.from(jsResult['columns'] as List);
    final List<dynamic> values = jsResult['values'] as List;
    if (values.isEmpty) {
      return [];
    }
    // Map each row's values to its column name
    return values.map((row) {
      final rowValues = row as List;
      return Map<String, dynamic>.fromIterables(columns, rowValues);
    }).toList();
  }

  bool _listMapContains(List<Map<String, dynamic>> list, String field, String value) {
    return list.any((map) => map[field] == value);
  }
}
