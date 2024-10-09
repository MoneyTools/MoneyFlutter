import 'package:flutter_test/flutter_test.dart';
import 'package:money/core/helpers/ranges.dart';
import 'package:money/core/helpers/value_parser.dart';

void main() {
  group('ValueQuality', () {
    test('asAmount returns correct value', () {
      const valueQuality = ValueQuality('100.50', currency: 'USD');
      expect(valueQuality.asAmount(), 100.50);
    });

    test('asAmount handles empty string', () {
      const valueQuality = ValueQuality('');
      expect(valueQuality.asAmount(), 0.00);
    });

    test('asDate returns correct date', () {
      const valueQuality = ValueQuality('2023-05-01', dateFormat: 'yyyy-MM-dd');
      expect(valueQuality.asDate(), DateTime(2023, 5, 1));
    });

    test('asDate returns null for invalid date', () {
      const valueQuality = ValueQuality('invalid date');
      expect(valueQuality.asDate(), null);
    });
    test('attemptToExtractTriples using ;', () {
      ValuesParser parser = ValuesParser(
        dateFormat: 'yyyy-MM-dd',
        currency: 'USD',
        reverseAmountValue: false,
      );
      parser.convertInputTextToTransactionList(
        null,
        '2010-12-25;Hello;12.99',
      );

      expect(parser.isNotEmpty, true);
      expect(parser.lines[0].date.asDate(), DateTime(2010, 12, 25));
      expect(parser.lines[0].description.asString(), 'Hello');
      expect(parser.lines[0].amount.asAmount(), 12.99);
    });

    test('attemptToExtractTriples using ,', () {
      ValuesParser parser = ValuesParser(
        dateFormat: 'yyyy-MM-dd',
        currency: 'USD',
        reverseAmountValue: false,
      );
      parser.convertInputTextToTransactionList(
        null,
        '"2010-12-25" "Hello" "12.99"',
      );

      expect(parser.lines.length, 1);
      expect(parser.lines[0].date.asDate(), DateTime(2010, 12, 25));
      expect(parser.lines[0].description.asString(), 'Hello');
      expect(parser.lines[0].amount.asAmount(), 12.99);
    });
  });

  group('ValuesQuality', () {
    test('getDateRange returns correct range', () {
      final list = [
        ValuesQuality(
          date: const ValueQuality('2023-05-01', dateFormat: 'yyyy-MM-dd'),
          description: const ValueQuality(''),
          amount: const ValueQuality(''),
        ),
        ValuesQuality(
          date: const ValueQuality('2023-05-15', dateFormat: 'yyyy-MM-dd'),
          description: const ValueQuality(''),
          amount: const ValueQuality(''),
        ),
      ];
      final DateRange range = ValuesQuality.getDateRange(list);
      expect(range.min, DateTime(2023, 5, 1));
      expect(range.max, DateTime(2023, 5, 15));
    });

    test('sort sorts list correctly', () {
      final list = [
        ValuesQuality(
          date: const ValueQuality('2023-05-15', dateFormat: 'yyyy-MM-dd'),
          description: const ValueQuality('C'),
          amount: const ValueQuality('100.50'),
        ),
        ValuesQuality(
          date: const ValueQuality('2023-05-01', dateFormat: 'yyyy-MM-dd'),
          description: const ValueQuality('A'),
          amount: const ValueQuality('50.25'),
        ),
        ValuesQuality(
          date: const ValueQuality('2023-05-10', dateFormat: 'yyyy-MM-dd'),
          description: const ValueQuality('B'),
          amount: const ValueQuality('75.00'),
        ),
      ];

      ValuesQuality.sort(list, 0, true); // Sort by date ascending
      expect(
        list.map((e) => e.date.asString()).toList(),
        ['2023-05-01', '2023-05-10', '2023-05-15'],
      );

      ValuesQuality.sort(list, 1, false); // Sort by description descending
      expect(
        list.map((e) => e.description.asString()).toList(),
        ['C', 'B', 'A'],
      );

      ValuesQuality.sort(list, 2, true); // Sort by amount ascending
      expect(
        list.map((e) => e.amount.asString()).toList(),
        ['50.25', '75.00', '100.50'],
      );
    });
  });
}
