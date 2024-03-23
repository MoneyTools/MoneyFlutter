part of 'data.dart';

extension DataFromDemo on Data {
  void loadFromDemoData() {
    // Generate a data set to demo the application
    for (final MoneyObjects<dynamic> moneyObjects in _listOfTables) {
      moneyObjects.loadDemoData();
    }
  }
}
