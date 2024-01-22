import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/loan_payments/loan_payment.dart';
import 'package:money/models/money_objects/money_objects.dart';

// Export
export 'package:money/models/money_objects/loan_payments/loan_payment.dart';

class LoanPayments extends MoneyObjects<LoanPayment> {
  @override
  void loadFromJson(final List<MyJson> rows) {
    clear();
    for (final MyJson row in rows) {
      addEntry(LoanPayment.fromSqlite(row));
    }
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      getListSortedById(),
    );
  }
}
