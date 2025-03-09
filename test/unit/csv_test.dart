import 'package:flutter_test/flutter_test.dart';
import 'package:money/core/helpers/json_helper.dart';
import 'package:money/core/helpers/string_helper.dart';

void main() {
  group('getLinesFromTextBlob', () {
    test('parses simple comma-separated values', () {
      const String input = 'field1,field2,field3';
      final List<List<String>> expected = <List<String>>[
        <String>['field1', 'field2', 'field3'],
      ];
      expect(getLinesFromRawTextWithSeparator(input), expected);
    });

    test('parses multiple lines', () {
      const String input = 'field1,field2,field3\nfield4,field5,field6';
      final List<List<String>> expected = <List<String>>[
        <String>['field1', 'field2', 'field3'],
        <String>['field4', 'field5', 'field6'],
      ];
      expect(getLinesFromRawTextWithSeparator(input), expected);
    });

    test('handles quoted fields with commas', () {
      const String input = '"field1,with,commas",field2,field3';
      final List<List<String>> expected = <List<String>>[
        <String>['field1,with,commas', 'field2', 'field3'],
      ];
      expect(getLinesFromRawTextWithSeparator(input), expected);
    });

    test('handles quoted fields spanning multiple lines', () {
      const String input = '"field1\nspanning\nmultiple\nlines",field2,field3';
      final List<List<String>> expected = <List<String>>[
        <String>['field1\nspanning\nmultiple\nlines', 'field2', 'field3'],
      ];
      expect(getLinesFromRawTextWithSeparator(input), expected);
    });

    test('handles escaped double quotes', () {
      const String input = 'field1,"field2""with""escaped""quotes",field3';
      final List<List<String>> expected = <List<String>>[
        <String>['field1', 'field2"with"escaped"quotes', 'field3'],
      ];
      expect(getLinesFromRawTextWithSeparator(input), expected);
    });

    test('handles empty fields', () {
      const String input = 'field1,,field3';
      final List<List<String>> expected = <List<String>>[
        <String>['field1', '', 'field3'],
      ];
      expect(getLinesFromRawTextWithSeparator(input), expected);
    });

    test('handles trailing commas', () {
      const String input = 'field1,field2,';
      final List<List<String>> expected = <List<String>>[
        <String>['field1', 'field2', ''],
      ];
      expect(getLinesFromRawTextWithSeparator(input), expected);
    });
  });

  group('rawCsvStringToListOfJsonObjects', () {
    test('parses empty CSV', () {
      const String input = 'header1,header2';
      final List<Map<String, dynamic>> expected = <Map<String, dynamic>>[];
      expect(convertFromRawCsvTextToListOfJSonObject(input), expected);
    });

    test('parses CSV with one row', () {
      const String input = 'name,age\nJohn,30';
      final List<Map<String, String>> expected = <Map<String, String>>[
        <String, String>{'name': 'John', 'age': '30'},
      ];
      expect(convertFromRawCsvTextToListOfJSonObject(input), expected);
    });

    test('parses CSV with multiple rows', () {
      const String input = 'name,age\nJohn,30\nJane,25\nBob,40';
      final List<Map<String, String>> expected = <Map<String, String>>[
        <String, String>{'name': 'John', 'age': '30'},
        <String, String>{'name': 'Jane', 'age': '25'},
        <String, String>{'name': 'Bob', 'age': '40'},
      ];
      expect(convertFromRawCsvTextToListOfJSonObject(input), expected);
    });

    test('handles quoted fields with commas', () {
      const String input = 'name,address\nJohn,"123 Main St, AnyTown, USA"';
      final List<Map<String, String>> expected = <Map<String, String>>[
        <String, String>{
          'name': 'John',
          'address': '123 Main St, AnyTown, USA',
        },
      ];
      expect(convertFromRawCsvTextToListOfJSonObject(input), expected);
    });

    test('handles missing fields', () {
      const String input = 'name,age,email\nJohn,30,\nJane,25,jane@example.com';
      final List<Map<String, String>> expected = <Map<String, String>>[
        <String, String>{'name': 'John', 'age': '30', 'email': ''},
        <String, String>{
          'name': 'Jane',
          'age': '25',
          'email': 'jane@example.com',
        },
      ];
      expect(convertFromRawCsvTextToListOfJSonObject(input), expected);
    });

    test('handles extra fields', () {
      const String input = 'name,age\nJohn,30,extra';
      final List<Map<String, String>> expected = <Map<String, String>>[
        <String, String>{'name': 'John', 'age': '30'},
      ];
      expect(convertFromRawCsvTextToListOfJSonObject(input), expected);
    });

    test('handles exceptions during parsing', () {
      const String input = 'name,age\nJohn,30\nInvalid';

      // Call the function that throws an exception and catch the exception
      dynamic caughtException;
      try {
        convertFromRawCsvTextToListOfJSonObject(input);
      } catch (e) {
        caughtException = e;
      }

      // Verify that the exception was caught
      expect(caughtException, isNotNull);

      // Verify the exception message
      expect(
        caughtException.toString(),
        contains(
          'RangeError (length): Invalid value: Only valid value is 0: 1',
        ),
      );
    });
  });
}
