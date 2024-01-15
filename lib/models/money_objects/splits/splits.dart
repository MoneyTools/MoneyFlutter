import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/splits/split.dart';

// Exports
export 'package:money/models/money_objects/splits/split.dart';

class Splits {
  /// List of split
  List<Split> list = <Split>[];

  List<Split> get(final num transactionId) {
    return list.where((final Split item) => item.transactionId == transactionId).toList();
  }

  clear() {
    list.clear();
  }

  load(final List<Map<String, Object?>> rows) async {
    clear();
    for (final Map<String, Object?> row in rows) {
      list.add(Split(
        // 0
        transactionId: jsonGetInt(row, 'Transaction'),
        // 1
        id: jsonGetInt(row, 'Id'),
        // 2
        categoryId: jsonGetInt(row, 'Category'),
        // 3
        payeeId: jsonGetInt(row, 'Payee'),
        // 4
        amount: jsonGetDouble(row, 'Amount'),
        // 5
        transferId: jsonGetInt(row, 'Transfer'),
        // 6
        memo: jsonGetString(row, 'Memo'),
        // 7
        flags: jsonGetInt(row, 'Flags'),
        // 8
        budgetBalanceDate: jsonGetDate(row, 'BudgetBalanceDate'),
      ));
    }
    return list;
  }

  loadDemoData() {
    clear();
  }
}
