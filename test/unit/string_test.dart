import 'package:flutter_test/flutter_test.dart';
import 'package:money/helpers/helpers.dart';

void main() {
  group('String Comparison:', () {
    test('Case-Insensitive String Comparison', () {
      expect(sortByStringIgnoreCase('Hello', 'hello'), 0);
      expect(sortByStringIgnoreCase2('Hello', 'hello'), 0);

      expect(sortByStringIgnoreCase('world', ''), 1);
      expect(sortByStringIgnoreCase2('world', ''), 1);

      expect(sortByStringIgnoreCase('', 'world'), -1);
      expect(sortByStringIgnoreCase2('', 'world'), -1);

      // Test case where strings are different
      expect(sortByStringIgnoreCase('abc', 'abcD'), -1);
      expect(sortByStringIgnoreCase2('abc', 'abcD'), -1);

      expect(sortByStringIgnoreCase('abcD', 'abc'), 1);
      expect(sortByStringIgnoreCase2('abcD', 'abc'), 1);
    });
  });

  group('String Comparison Perf:', () {
    test('Case-Insensitive A', () {
      final Stopwatch stopwatch = Stopwatch()..start(); // Start the stopwatch

      for (int i = 0; i < 200000; i++) {
        expect(sortByStringIgnoreCase('world', 'WORLD'), 0);
        expect(sortByStringIgnoreCase('banana', ''), 1);
        expect(sortByStringIgnoreCase('', 'banana'), -1);
        expect(
            sortByStringIgnoreCase('a very long string that is different right from the start',
                'The very long string that is different right from the start'),
            -1);
      }

      stopwatch.stop(); // Stop the stopwatch after the operation
      debugLog('Elapsed time to lower   : ${stopwatch.elapsedMilliseconds} milliseconds');
    });

    test('Case-Insensitive B', () {
      final Stopwatch stopwatch = Stopwatch()..start(); // Start the stopwatch

      for (int i = 0; i < 200000; i++) {
        expect(sortByStringIgnoreCase2('world', 'WORLD'), 0);
        expect(sortByStringIgnoreCase2('banana', ''), 1);
        expect(sortByStringIgnoreCase2('', 'banana'), -1);
        expect(
            sortByStringIgnoreCase2('a very long string that is different right from the start',
                'The very long string that is different right from the start'),
            -1);
      }
      stopwatch.stop(); // Stop the stopwatch after the operation
      debugLog('Elapsed time incremental: ${stopwatch.elapsedMilliseconds} milliseconds');
    });
  });

  group('String getStringBetweenTwoTokens:', () {
    test('getStringBetweenTwoTokens', () {
      expect(
        getStringDelimitedStartEndTokens(
          'hello Sun in the Sky tonight',
          'Sun',
          'Sky',
        ),
        'Sun in the Sky',
      );
    });
  });
}
