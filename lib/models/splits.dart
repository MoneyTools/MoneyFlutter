import 'package:money/models/money_entity.dart';

class Split extends MoneyEntity {
  num transactionId;
  num categoryId;
  double amount;
  num payeeId;
  String memo;

  Split(id, this.transactionId, this.categoryId, this.amount, this.payeeId, this.memo) : super(id, '');
}

class Splits {
  static List<Split> list = [];

  static get(transactionId) {
    return list.where((item) => item.transactionId == transactionId);
  }

  clear() {
    list.clear();
  }

  load(rows) async {
    clear();
    for (var row in rows) {
      var id = num.parse(row['Id'].toString());
      var transactionId = num.parse(row['Transaction'].toString());
      var categoryId = num.parse(row['Category'].toString());
      var amount = double.parse(row['Amount'].toString());
      var payeeId = double.parse(row['Payee'].toString());
      var memo = row['Memo'].toString();

      list.add(Split(id, transactionId, categoryId, amount, payeeId, memo));
    }
    return list;
  }

  loadDemoData() {
    clear();
  }
}
