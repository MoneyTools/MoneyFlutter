import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transaction_extras/transaction_extra.dart';

// Export
export 'package:money/models/money_objects/transaction_extras/transaction_extra.dart';

class TransactionExtras extends MoneyObjects<TransactionExtra> {
  TransactionExtras() {
    collectionName = 'Transaction Extras';
  }

  void add(final TransactionExtra transaction) {
    transaction.id.value = iterableList().length;
    appendMoneyObject(transaction);
  }

  @override
  List<TransactionExtra> loadFromJson(final List<MyJson> rows) {
    clear();

    for (final MyJson row in rows) {
      final TransactionExtra t = TransactionExtra(
        // id
        id: row.getInt('Id'),
        // Account Id
        transaction: row.getInt('Transaction'),
        // Tax Year
        taxYear: row.getInt('TaxYear'),
        // Tax Date
        taxDate: row.getDate('TaxDate'),
      );

      appendMoneyObject(t);
    }
    return iterableList().toList();
  }
}
