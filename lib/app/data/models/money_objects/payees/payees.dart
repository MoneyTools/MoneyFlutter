import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/data/models/money_objects/payees/payee.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';

class Payees extends MoneyObjects<Payee> {
  Payees() {
    collectionName = 'Payees';
  }

  @override
  void loadFromJson(final List<MyJson> rows) {
    clear();
    /*
     */
    for (final MyJson row in rows) {
      final int id = int.parse(row['Id'].toString());
      final String name = row['Name'].toString();
      appendMoneyObject(
        Payee()
          ..fieldId.value = id
          ..fieldName.value = name,
      );
    }
  }

  @override
  void onAllDataLoaded() {
    for (final Payee payee in iterableList()) {
      payee.fieldCount.value = 0;
      payee.fieldSum.value.setAmount(0);
    }

    for (Transaction t in Data().transactions.iterableList()) {
      final Payee? item = get(t.fieldPayee.value);
      if (item != null) {
        item.fieldCount.value++;
        item.fieldSum.value += t.fieldAmount.value;
        final categoryName = Data().categories.getNameFromId(t.fieldCategoryId.value).trim();
        if (categoryName.isNotEmpty) {
          item.categories.add(Data().categories.getNameFromId(t.fieldCategoryId.value));
        }
      }
    }
  }

  @override
  String toCSV() {
    return MoneyObjects.getCsvFromList(
      getListSortedById(),
    );
  }

  Payee? getByName(final String name) {
    if (name.isEmpty) {
      return null;
    }
    return iterableList().firstWhereOrNull((final Payee payee) => payee.fieldName.value == name);
  }

  List<Payee> getListSorted() {
    final list = iterableList().toList();
    list.sort((a, b) => sortByString(a.fieldName.value, b.fieldName.value, true));
    return list;
  }

  String getNameFromId(final int id) {
    if (id == -1) {
      return '';
    }

    final Payee? payee = get(id);

    if (payee == null) {
      return '<unkown payee $id>';
    }
    return payee.fieldName.value;
  }

  /// Attempts to find payee wih the given name
  /// if not found create a new payee and return that instance
  Payee getOrCreate(final String name, {bool fireNotification = true}) {
    // find or add account of given name
    Payee? payee = getByName(name);

    // if not found add new payee
    if (payee == null) {
      payee = Payee();
      payee.fieldId.value = -1;
      payee.fieldName.value = name;
      Data().payees.appendNewMoneyObject(payee, fireNotification: fireNotification);
    }
    return payee;
  }

  /// if not found returns -1
  int getPayeeIdFromName(final String name) {
    final Payee? payee = getByName(name);
    if (payee == null) {
      return -1;
    }
    return payee.uniqueId;
  }

  static void removePayeesThatHaveNoTransactions(List<int> payeeIds) {
    for (final payeeId in payeeIds) {
      final Payee? payeeToCheck = Data().payees.get(payeeId);
      if (payeeToCheck != null) {
        if (Data().transactions.iterableList().firstWhereOrNull(
                  (element) => element.fieldPayee.value == payeeToCheck.uniqueId,
                ) ==
            null) {
          // No transactions for this payee, we can delete it
          Data().payees.deleteItem(payeeToCheck);
        }
      }
    }
  }
}
