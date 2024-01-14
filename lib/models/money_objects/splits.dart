import 'package:money/models/money_objects/money_object.dart';

class Split extends MoneyObject {
  String name;
  num transactionId;
  num categoryId;
  double amount;
  num payeeId;
  String memo;

  Split({
    required super.id,
    required this.name,
    required this.transactionId,
    required this.categoryId,
    required this.amount,
    required this.payeeId,
    required this.memo,
  });
}

class Splits {
  static List<Split> list = <Split>[];

  static List<Split> get(final num transactionId) {
    return list.where((final Split item) => item.transactionId == transactionId).toList();
  }

  clear() {
    list.clear();
  }

  load(final List<Map<String, Object?>> rows) async {
    clear();
    for (final Map<String, Object?> row in rows) {
      final int id = int.parse(row['Id'].toString());
      final int transactionId = int.parse(row['Transaction'].toString());
      final int categoryId = int.parse(row['Category'].toString());
      final double amount = double.parse(row['Amount'].toString());
      final double payeeId = double.parse(row['Payee'].toString());
      final String memo = row['Memo'].toString();

      list.add(Split(
        id: id,
        name: '',
        transactionId: transactionId,
        categoryId: categoryId,
        amount: amount,
        payeeId: payeeId,
        memo: memo,
      ));
    }
    return list;
  }

  loadDemoData() {
    clear();
  }
}
