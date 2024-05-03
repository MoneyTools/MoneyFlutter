class RecurringPayment {
  int payeeId;
  double averageAmount;
  int frequency;
  List<int> categoryIds = [];
  List<double> categorySums = [];

  RecurringPayment(this.payeeId, this.averageAmount, this.frequency, this.categoryIds, this.categorySums);
}

class PayeeCumulate {
  int payeeId = -1;
  int numberOfInstances = 0;
  List<Map<int, double>> amountByCategories = [];
}
