import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/account_aliases/account_alias.dart';
import 'package:money/models/money_objects/money_objects.dart';

class AccountAliases extends MoneyObjects<AccountAlias> {
  AccountAliases() {
    collectionName = 'Account Aliases';
  }

  @override
  AccountAlias instanceFromSqlite(final MyJson row) {
    return AccountAlias.fromJson(row);
  }
}
