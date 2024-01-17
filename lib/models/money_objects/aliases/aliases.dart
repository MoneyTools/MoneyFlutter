import 'package:money/helpers/json_helper.dart';
import 'package:money/models/data_io/data.dart';
import 'package:money/models/money_objects/aliases/alias.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/payees/payee.dart';

class Aliases extends MoneyObjects<Alias> {
  @override
  String sqlQuery() {
    return 'SELECT * FROM Aliases';
  }

  @override
  Alias instanceFromSqlite(final Json row) {
    return Alias.fromSqlite(row);
  }

  @override
  void onAllDataLoaded() {
    for (final Alias item in getList()) {
      item.payeeInstance = Data().payees.get(item.payeeId);
    }
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      Alias.getFieldDefinitions(),
      getListSortedById(),
    );
  }

  Payee? findByMatch(final String text) {
    final Alias? aliasFound = getList().firstWhereOrNull((final Alias item) => item.isMatch(text));
    if (aliasFound == null) {
      return null;
    }
    return aliasFound.payeeInstance;
  }
}
