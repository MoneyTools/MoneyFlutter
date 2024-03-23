import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transaction_extras/transaction_extra.dart';

// Export
export 'package:money/models/money_objects/transaction_extras/transaction_extra.dart';

class TransactionExtras extends MoneyObjects<TransactionExtra> {
  double runningBalance = 0.00;

  void add(final TransactionExtra transaction) {
    transaction.id.value = iterableList().length;
    appendMoneyObject(transaction);
  }

  @override
  List<TransactionExtra> loadFromJson(final List<MyJson> rows) {
    clear();

    runningBalance = 0.00;

    for (final MyJson row in rows) {
      final TransactionExtra t = TransactionExtra(
        // id
        // Account Id
        transaction: row.getInt('Transaction'),
        // Tax Year
        taxYear: row.getInt('TaxYear'),
        // Tax Date
        taxDate: row.getInt('TaxDate'),
      )..id.value = row.getInt('Id');

      appendMoneyObject(t);
    }
    return iterableList().toList();
  }
}
