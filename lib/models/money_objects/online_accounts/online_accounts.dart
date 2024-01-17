import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/online_accounts/online_account.dart';

class OnlineAccounts extends MoneyObjects<OnlineAccount> {
  load(final List<Json> rows) async {
    clear();
    for (final Json row in rows) {
      addEntry(OnlineAccount.fromSqlite(row));
    }
  }

  loadDemoData() {
    clear();
  }

  static onAllDataLoaded() {}

  @override
  String toCSV() {
    return super.getCsvFromList(
      OnlineAccount.getFieldDefinitions(),
      getListSortedById(),
    );
  }
}
