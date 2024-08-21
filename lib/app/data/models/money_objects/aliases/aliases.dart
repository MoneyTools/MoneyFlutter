import 'package:money/app/data/models/money_objects/aliases/alias.dart';
import 'package:money/app/data/models/money_objects/payees/payee.dart';
import 'package:money/app/data/storage/data/data.dart';

class Aliases extends MoneyObjects<Alias> {
  Aliases() {
    collectionName = 'Aliases';
  }

  @override
  Alias instanceFromSqlite(final MyJson row) {
    return Alias.fromJson(row);
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }

  Payee? findByMatch(final String text) {
    final Alias? aliasFound = iterableList().firstWhereOrNull((final Alias item) => item.isMatch(text));
    return aliasFound?.payeeInstance;
  }

  Payee? findOrCreateNewPayee(
    final String text, {
    bool fireNotification = true,
  }) {
    Payee? payee = findByMatch(text);
    payee ??= Data().payees.getOrCreate(text, fireNotification: fireNotification);
    return payee;
  }
}
