import 'package:money/models/money_entity.dart';

class Split extends MoneyEntity {
  int transactionId;
  int categoryId;
  double amount;
  int payeeId;
  String memo;

  Split(final int id, this.transactionId, this.categoryId, this.amount, this.payeeId, this.memo) : super(id, '');
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
      final int payeeId = int.parse(row['Payee'].toString());
      final String memo = row['Memo'].toString();

      list.add(Split(id, transactionId, categoryId, amount, payeeId, memo));
    }
    return list;
  }

  loadDemoData() {
    clear();
  }
}
