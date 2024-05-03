// ignore_for_file: unnecessary_this

import 'package:money/helpers/list_helper.dart';

class RecurringPayment {
  int payeeId;
  double total;
  int numberOfYears;
  int frequency;
  List<Pair<int, double>> categoryIdsAndSums = [];

  RecurringPayment(this.payeeId, this.numberOfYears, this.total, this.frequency, this.categoryIdsAndSums);

  List<Pair<int, double>> getListOfCategoryIdAndSum() {
    return categoryIdsAndSums;
  }
}
