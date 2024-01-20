import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/online_accounts/online_account.dart';

class OnlineAccounts extends MoneyObjects<OnlineAccount> {
  @override
  String sqlQuery() {
    return 'SELECT * FROM AccountAliases';
  }

  @override
  loadFromJson(final List<Json> rows) {
    clear();
    for (final Json row in rows) {
      addEntry(OnlineAccount.fromSqlite(row));
    }
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      getListSortedById(),
    );
  }
}
