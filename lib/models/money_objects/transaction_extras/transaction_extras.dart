import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/transaction_extras/transaction_extra.dart';

// Export
export 'package:money/models/money_objects/transaction_extras/transaction_extra.dart';

class TransactionExtras extends MoneyObjects<TransactionExtra> {
  double runningBalance = 0.00;

  void add(final TransactionExtra transaction) {
    transaction.id.value = getList().length;
    getList().add(transaction);
  }

  @override
  loadFromJson(final List<Json> rows) {
    clear();

    runningBalance = 0.00;

    for (final Json row in rows) {
      final TransactionExtra t = TransactionExtra(
        // id
        // Account Id
        transaction: jsonGetInt(row, 'Transaction'),
        // Tax Year
        taxYear: jsonGetInt(row, 'TaxYear'),
        // Tax Date
        taxDate: jsonGetInt(row, 'TaxDate'),
      )..id.value = jsonGetInt(row, 'Id');

      getList().add(t);
    }
    return getList();
  }
}
