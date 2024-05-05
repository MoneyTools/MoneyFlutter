// ignore_for_file: unnecessary_this

import 'package:money/helpers/list_helper.dart';

class RecurringPayment {
  final int payeeId;
  final double total;
  final int numberOfYears;
  final int frequency;
  final List<double> monthSums;
  final List<Pair<int, double>> categoryIdsAndSums;

  RecurringPayment({
    required this.payeeId,
    required this.numberOfYears,
    required this.total,
    required this.frequency,
    required this.monthSums,
    required this.categoryIdsAndSums,
  });

  List<Pair<int, double>> getListOfCategoryIdAndSum() {
    return categoryIdsAndSums;
  }
}
