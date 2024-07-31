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
  void onAllDataLoaded() {
    for (final Alias item in iterableList()) {
      item.payeeInstance = Data().payees.get(item.fieldPayeeId.value);
    }
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }

  Payee? findByMatch(final String text) {
    final Alias? aliasFound = iterableList().firstWhereOrNull((final Alias item) => item.isMatch(text));
    if (aliasFound == null) {
      return null;
    }
    return aliasFound.payeeInstance;
  }

  Payee? findOrCreateNewPayee(
    final String text, {
    bool fireNotification = true,
  }) {
    Payee? payee = findByMatch(text);
    payee ??= Data().payees.getOrCreate(text, fireNotification: fireNotification);
    return payee;
  }

  /// If no match found return -1
  int getPayeeIdFromTextMatching(final String text) {
    final Payee? payeeFound = findByMatch(text);
    if (payeeFound == null) {
      return -1;
    }
    return payeeFound.uniqueId;
  }

  /// Attempt to find a Payee match by text, if failed adds a new Payee
  int getPayeeIdFromTextMatchingOrAdd(
    final String text, {
    bool fireNotification = true,
  }) {
    int id = getPayeeIdFromTextMatching(text);
    if (id == -1) {
      id = Data().payees.getOrCreate(text, fireNotification: fireNotification).uniqueId;
    }
    return id;
  }
}
