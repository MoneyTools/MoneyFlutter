import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/account_aliases/account_alias.dart';
import 'package:money/models/money_objects/money_objects.dart';

class AccountAliases extends MoneyObjects<AccountAlias> {
  load(final List<Json> rows) async {
    clear();
    for (final Json row in rows) {
      addEntry(AccountAlias.fromSqlite(row));
    }
  }

  loadDemoData() {
    clear();
  }

  static onAllDataLoaded() {}
}
