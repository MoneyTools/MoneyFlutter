import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
import 'package:money/app/data/models/money_objects/transaction_extras/transaction_extra.dart';

// Export
export 'package:money/app/data/models/money_objects/transaction_extras/transaction_extra.dart';

class TransactionExtras extends MoneyObjects<TransactionExtra> {
  TransactionExtras() {
    collectionName = 'Transaction Extras';
  }

  @override
  List<TransactionExtra> loadFromJson(final List<MyJson> rows) {
    clear();

    for (final MyJson row in rows) {
      final TransactionExtra t = TransactionExtra(
        // id
        id: row.getInt('Id', -1),
        // Transaction Id
        transaction: row.getInt('Transaction', -1),
        // Tax Year
        taxYear: row.getInt('TaxYear'),
        // Tax Date
        taxDate: row.getDate('TaxDate'),
      );

      appendMoneyObject(t);
    }
    return iterableList().toList();
  }

  void add(final TransactionExtra transaction) {
    transaction.id.value = iterableList().length;
    appendMoneyObject(transaction);
  }
}
