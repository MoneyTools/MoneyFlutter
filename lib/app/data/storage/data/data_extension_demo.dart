part of 'data.dart';

extension DataFromDemo on Data {
  void loadFromDemoData() {
    DataSimulator().generateData();
    recalculateBalances();
  }
}
