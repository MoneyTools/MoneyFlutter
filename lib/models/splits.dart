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
  double runningBalance = 0.00;

  static List<Split> list = [];

  static get(transactionId) {
    return list.where((item) => item.transactionId == transactionId);
  }

  load(rows) async {
    runningBalance = 0.00;

    for (var row in rows) {
      var id = num.parse(row["Id"].toString());
      var transactionId = num.parse(row["Transaction"].toString());
      var categoryId = num.parse(row["Category"].toString());
      var amount = double.parse(row["Amount"].toString());
      var payeeId = double.parse(row["Payee"].toString());
      var memo = row["Memo"].toString();

      list.add(Split(id, transactionId, categoryId, amount, payeeId, memo));
    }
    return list;
  }

  loadDemoData() {
    runningBalance = 0;
  }
}
