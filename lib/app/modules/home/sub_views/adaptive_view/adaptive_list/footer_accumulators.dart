import 'package:money/app/core/helpers/accumulator.dart';
import 'package:money/app/core/helpers/ranges.dart';
import 'package:money/app/core/widgets/columns/footer_widgets.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/view_money_objects.dart';

class FooterAccumulators {
  final AccumulatorList<Field, String> accumaltorListOfText = AccumulatorList<Field, String>();
  final AccumulatorDateRange<Field> accumulatorDateRange = AccumulatorDateRange<Field>();
  final AccumulatorAverage<Field> accumulatorForAverage = AccumulatorAverage<Field>();
  final AccumulatorSum<Field, double> accumulatorSumAmount = AccumulatorSum<Field, double>();
  final AccumulatorSum<Field, double> accumulatorSumNumber = AccumulatorSum<Field, double>();

  /// Allowed to be overrided by derived classes
  /// to be overrident by derived class
  /// Use the field FooterType to decide how to render the bottom button of each columns
  Widget buildWidget(final Field field) {
    switch (field.footer) {
      case FooterType.range:
        if (accumulatorDateRange.containsKey(field)) {
          final DateRange value = accumulatorDateRange.getValue(field)!;
          return getFooterForDateRange(value);
        }
      case FooterType.count:
        List<String> list = [];

        if (accumaltorListOfText.containsKey(field)) {
          list = accumaltorListOfText.getList(field);
        } else {
          if (accumulatorSumNumber.containsKey(field)) {
            list = accumulatorSumNumber.getValue(field);
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
          widget = getFooterForAmount(accumulatorSumAmount.getValue(field));
        } else {
          if (accumulatorSumNumber.containsKey(field)) {
            widget = getFooterForInt(accumulatorSumNumber.getValue(field));
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
          Widget widget = field.type == FieldType.amount
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
    accumaltorListOfText.clear();
  }
}
