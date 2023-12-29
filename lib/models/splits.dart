import 'package:money/models/money_entity.dart';

class Split extends MoneyEntity {
  num transactionId;
  num categoryId;
  double amount;
  num payeeId;
  String memo;

  Split(final num id, this.transactionId, this.categoryId, this.amount, this.payeeId, this.memo) : super(id, '');
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
      final num id = num.parse(row['Id'].toString());
      final num transactionId = num.parse(row['Transaction'].toString());
      final num categoryId = num.parse(row['Category'].toString());
      final double amount = double.parse(row['Amount'].toString());
      final double payeeId = double.parse(row['Payee'].toString());
      final String memo = row['Memo'].toString();

      list.add(Split(id, transactionId, categoryId, amount, payeeId, memo));
    }
    return list;
  }

  loadDemoData() {
    clear();
  }
}
