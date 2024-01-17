import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/splits/split.dart';

// Exports
export 'package:money/models/money_objects/splits/split.dart';

class Splits extends MoneyObjects<Split> {
  List<Split> getListFromTransactionId(final num transactionId) {
    return getList().where((final Split item) => item.transactionId == transactionId).toList();
  }

  @override
  loadFromJson(final List<Json> rows) {
    clear();
    for (final Json row in rows) {
      getList().add(Split(
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
    return getList();
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      Split.getFieldDefinitions(),
      getListSortedById(),
    );
  }
}
