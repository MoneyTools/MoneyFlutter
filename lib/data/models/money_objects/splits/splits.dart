import 'package:money/data/models/money_objects/splits/money_split.dart';
import 'package:money/data/models/money_objects/transactions/transaction.dart';
import 'package:money/data/storage/data/data.dart';

// Exports
export 'package:money/data/models/money_objects/splits/money_split.dart';

class Splits extends MoneyObjects<MoneySplit> {
  Splits() {
    collectionName = 'Splits';
  }

  @override
  void appendMoneyObject(final MoneyObject moneyObject) {
    super.appendMoneyObject(moneyObject);

    // Attach the split back to the their  container Transaction
    final MoneySplit splitAdded = (moneyObject as MoneySplit);
    final Transaction? containerTransaction = Data().transactions.get(splitAdded.fieldTransactionId.value);
    if (containerTransaction != null) {
      containerTransaction.splits.add(moneyObject);
    }
  }

  @override
  List<MoneySplit> loadFromJson(final List<MyJson> rows) {
    clear();
    for (final MyJson row in rows) {
      appendMoneyObject(
        MoneySplit(
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
