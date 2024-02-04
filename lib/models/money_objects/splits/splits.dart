import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/splits/split.dart';

// Exports
export 'package:money/models/money_objects/splits/split.dart';

class Splits extends MoneyObjects<Split> {
  List<Split> getListFromTransactionId(final num transactionId) {
    return iterableList().where((final Split item) => item.transactionId == transactionId).toList();
  }

  @override
  List<Split> loadFromJson(final List<MyJson> rows) {
    clear();
    for (final MyJson row in rows) {
      addEntry(
        Split(
          // 0
          transactionId: row.getInt('Transaction'),
          // 1
          // id
          // 2
          categoryId: row.getInt('Category'),
          // 3
          payeeId: row.getInt('Payee'),
          // 4
          amount: row.getDouble('Amount'),
          // 5
          transferId: row.getInt('Transfer'),
          // 6
          memo: row.getString('Memo'),
          // 7
          flags: row.getInt('Flags'),
          // 8
          budgetBalanceDate: row.getDate('BudgetBalanceDate'),
        )..id.value = row.getInt('Id'),
      );
    }
    return iterableList().toList();
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      getListSortedById(),
    );
  }
}
