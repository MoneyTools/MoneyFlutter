import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/online_accounts/online_account.dart';

class OnlineAccounts extends MoneyObjects<OnlineAccount> {
  @override
  String sqlQuery() {
    return 'SELECT * FROM AccountAliases';
  }

  @override
  void loadFromJson(final List<MyJson> rows) {
    clear();
    for (final MyJson row in rows) {
      addEntry(OnlineAccount.fromJson(row));
    }
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      getListSortedById(),
    );
  }
}
