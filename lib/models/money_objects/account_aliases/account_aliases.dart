import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/account_aliases/account_alias.dart';
import 'package:money/models/money_objects/money_objects.dart';

class AccountAliases extends MoneyObjects<AccountAlias> {
  @override
  String sqlQuery() {
    return 'SELECT * FROM AccountAliases';
  }

  @override
  AccountAlias instanceFromSqlite(final Json row) {
    return AccountAlias.fromSqlite(row);
  }
}
