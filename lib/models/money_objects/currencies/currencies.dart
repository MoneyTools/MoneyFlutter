import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/money_objects.dart';

class Currencies extends MoneyObjects<Currency> {
  @override
  String sqlQuery() {
    return 'SELECT * FROM Currencies';
  }

  @override
  Currency instanceFromSqlite(final MyJson row) {
    return Currency.fromJson(row);
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      getListSortedById(),
    );
  }
}
