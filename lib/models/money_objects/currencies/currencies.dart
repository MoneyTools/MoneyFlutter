import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/Currencies/Currency.dart';
import 'package:money/models/money_objects/money_objects.dart';

class Currencies extends MoneyObjects<Currency> {
  @override
  String sqlQuery() {
    return 'SELECT * FROM Currencies';
  }

  @override
  Currency instanceFromSqlite(final Json row) {
    return Currency.fromSqlite(row);
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      Currency.getFieldDefinitions(),
      getListSortedById(),
    );
  }
}
