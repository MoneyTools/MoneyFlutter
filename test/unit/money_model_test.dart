import 'package:flutter_test/flutter_test.dart';
import 'package:money/models/money_model.dart';

void main() {
  test('test_should_round_positive_decimal_value', () {
    MoneyModel mm = MoneyModel(amount: 12345.67);

    // To String
    expect(mm.toDouble(), equals(12345.67));
    expect(mm.toString(), equals('\$12,345.67'));

    // Add
    mm += 10000.00;
    expect(mm.toDouble().toStringAsFixed(2), equals('22345.67'));

    // Subtract
    mm -= 10000.00;
    expect(mm.toDouble().toStringAsFixed(2), equals('12345.67'));

    mm.setAmount(9876543.21);
    expect(mm.toDouble().toStringAsFixed(2), equals('9876543.21'));
    expect(mm.toString(), equals('\$9,876,543.21'));

    mm.setAmount('123.45');
    expect(mm.toDouble(), equals(123.45));
    expect(mm.toString(), equals('\$123.45'));
  });
}
