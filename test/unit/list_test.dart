import 'package:flutter_test/flutter_test.dart';
import 'package:money/helpers/accumulator.dart';

void main() {
  test('AccumulatorSum: empty map', () {
    final AccumulatorSum<int, int> acc = AccumulatorSum<int, int>();
    expect(acc.values, isEmpty);
  });

  test('AccumulatorSum: one element', () {
    final AccumulatorSum<int, int> acc = AccumulatorSum<int, int>();
    acc.cumulate(1, 2);
    expect(acc.values, {1: 2});
  });

  test('AccumulatorSum: two elements', () {
    final AccumulatorSum<int, int> acc = AccumulatorSum<int, int>();
    acc.cumulate(1, 2);
    acc.cumulate(2, 3);
    expect(acc.values, {1: 2, 2: 3});
  });

  test('AccumulatorSum: two elements with same key', () {
    final AccumulatorSum<int, int> acc = AccumulatorSum<int, int>();
    acc.cumulate(1, 2);
    acc.cumulate(1, 3);
    expect(acc.values, {1: 5});
  });
}
