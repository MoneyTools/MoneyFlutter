import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/aliases/alias.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/payees/payee.dart';

class Aliases extends MoneyObjects<Alias> {
  @override
  Alias instanceFromSqlite(final MyJson row) {
    return Alias.fromJson(row);
  }

  @override
  void onAllDataLoaded() {
    for (final Alias item in getList()) {
      item.payeeInstance = Data().payees.get(item.payeeId.value);
    }
  }

  @override
  void loadDemoData() {
    clear();
    addEntry(Alias(id: 0, payeeId: 2, pattern: 'ABC', flags: AliasType.none.index));
    addEntry(Alias(id: 1, payeeId: 2, pattern: 'abc', flags: AliasType.none.index));
    addEntry(Alias(id: 2, payeeId: 3, pattern: '.*starbucks.*', flags: AliasType.regex.index));
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
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
