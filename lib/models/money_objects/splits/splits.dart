import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/splits/split.dart';
import 'package:money/storage/data/data.dart';

// Exports
export 'package:money/models/money_objects/splits/split.dart';

class Splits extends MoneyObjects<Split> {
  Splits() {
    collectionName = 'Splits';
  }

  @override
  void appendMoneyObject(final MoneyObject moneyObject) {
    super.appendMoneyObject(moneyObject);

    // Attach the split back to the their  container Transaction
    final splitAdded = (moneyObject as Split);
    final containerTransaction = Data().transactions.get(splitAdded.transactionId.value);
    if (containerTransaction != null) {
      containerTransaction.splits.add(moneyObject);
    }
  }

  @override
  List<Split> loadFromJson(final List<MyJson> rows) {
    clear();
    for (final MyJson row in rows) {
      appendMoneyObject(
        Split(
          // 0
          transactionId: row.getInt('Transaction', -1),
          // 1
          id: row.getInt('Id', -1),
          // 2
          categoryId: row.getInt('Category', -1),
          // 3
          payeeId: row.getInt('Payee', -1),
          // 4
          amount: row.getDouble('Amount'),
          // 5
          transferId: row.getInt('Transfer', -1),
          // 6
          memo: row.getString('Memo'),
          // 7
          flags: row.getInt('Flags'),
          // 8
          budgetBalanceDate: row.getDate('BudgetBalanceDate'),
        ),
      );
    }
    return iterableList().toList();
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }
}
