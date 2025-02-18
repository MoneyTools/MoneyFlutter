import 'package:money/core/helpers/accumulator.dart';
import 'package:money/core/helpers/ranges.dart';
import 'package:money/core/widgets/columns/footer_widgets.dart';
import 'package:money/data/models/fields/field.dart';
import 'package:money/views/home/sub_views/adaptive_view/view_money_objects.dart';

class FooterAccumulators {
  final AccumulatorDateRange<Field<dynamic>> accumulatorDateRange = AccumulatorDateRange<Field<dynamic>>();
  final AccumulatorAverage<Field<dynamic>> accumulatorForAverage = AccumulatorAverage<Field<dynamic>>();
  final AccumulatorList<Field<dynamic>, String> accumulatorListOfText = AccumulatorList<Field<dynamic>, String>();
  final AccumulatorSum<Field<dynamic>, double> accumulatorSumAmount = AccumulatorSum<Field<dynamic>, double>();
  final AccumulatorSum<Field<dynamic>, double> accumulatorSumNumber = AccumulatorSum<Field<dynamic>, double>();

  /// Allowed to be override by derived classes
  /// to be overridden by derived class
  /// Use the field FooterType to decide how to render the bottom button of each columns
  Widget buildWidget(final Field<dynamic> field) {
    switch (field.footer) {
      case FooterType.range:
        if (accumulatorDateRange.containsKey(field)) {
          final DateRange value = accumulatorDateRange.getValue(field)!;
          return getFooterForDateRange(value);
        }
      case FooterType.count:
        List<String> list = [];

        if (accumulatorListOfText.containsKey(field)) {
          list = accumulatorListOfText.getList(field);
        } else {
          if (accumulatorSumNumber.containsKey(field)) {
            list = accumulatorSumNumber.getValue(field) as List<String>;
          }
        }

        final int count = list.length;
        if (count > 0) {
          String samples = '';
          if (count > 10) {
            samples = '${list.take(10).join('\n')}\n...';
          } else {
            samples = list.join('\n');
          }
          return Tooltip(
            message: '$count items\n$samples',
            child: getFooterForInt(count, applyColorBasedOnValue: false),
          );
        }

      case FooterType.sum:
        Widget? widget;
        if (accumulatorSumAmount.containsKey(field)) {
          widget = getFooterForAmount(accumulatorSumAmount.getValue(field) as double);
        } else {
          if (accumulatorSumNumber.containsKey(field)) {
            widget = getFooterForInt(accumulatorSumNumber.getValue(field) as num);
          }
        }
        return Tooltip(
          message: 'Sum.',
          child: widget,
        );

      case FooterType.average:
        if (accumulatorForAverage.containsKey(field)) {
          final RunningAverage range = accumulatorForAverage.getValue(field)!;
          final double value = range.getAverage();
          final Widget widget = field.type == FieldType.amount
              ? getFooterForAmount(value, prefix: 'Av ')
              : getFooterForInt(value, prefix: 'Av ');
          return Tooltip(
            message: field.type == FieldType.amount ? range.descriptionAsMoney : range.descriptionAsInt,
            child: widget,
          );
        }

      case FooterType.none:
      default:
        return const SizedBox();
    }
    return const SizedBox();
  }

  void clear() {
    accumulatorSumAmount.clear();
    accumulatorSumNumber.clear();
    accumulatorForAverage.clear();
    accumulatorDateRange.clear();
    accumulatorListOfText.clear();
  }
}
