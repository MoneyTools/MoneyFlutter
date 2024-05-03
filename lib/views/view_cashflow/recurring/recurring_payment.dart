// ignore_for_file: unnecessary_this

import 'package:money/helpers/list_helper.dart';

class RecurringPayment {
  int payeeId;
  double averageAmount;
  int frequency;
  List<int> categoryIds = [];
  List<double> categorySums = [];

  RecurringPayment(this.payeeId, this.averageAmount, this.frequency, this.categoryIds, this.categorySums);

  List<Pair<int, double>> getListOfCategoryIdAndSum() {
    List<Pair<int, double>> list = [];
    for (int i = 0; i < this.categoryIds.length; i++) {
      list.add(Pair<int, double>(
        this.categoryIds[i],
        this.categorySums[i],
      ));
    }
    return list;
  }
}
