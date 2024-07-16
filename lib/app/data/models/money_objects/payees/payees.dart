import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
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
          ..id.value = id
          ..name.value = name,
      );
    }
  }

  @override
  void onAllDataLoaded() {
    for (final Payee payee in iterableList()) {
      payee.count.value = 0;
      payee.sum.value.setAmount(0);
    }

    for (Transaction t in Data().transactions.iterableList()) {
      final Payee? item = get(t.payee.value);
      if (item != null) {
        item.count.value++;
        item.sum.value += t.amount.value;
        final categoryName = Data().categories.getNameFromId(t.categoryId.value).trim();
        if (categoryName.isNotEmpty) {
          item.categories.add(Data().categories.getNameFromId(t.categoryId.value));
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

  /// Attempts to find payee wih the given name
  /// if not found create a new payee and return that instance
  Payee findOrAddPayee(final String name, {bool fireNotification = true}) {
    // find or add account of given name
    Payee? payee = getByName(name);

    // if not found add new payee
    if (payee == null) {
      payee = Payee();
      payee.id.value = -1;
      payee.name.value = name;
      Data().payees.appendNewMoneyObject(payee, fireNotification: fireNotification);
    }
    return payee;
  }

  Payee? getByName(final String name) {
    if (name.isEmpty) {
      return null;
    }
    return iterableList().firstWhereOrNull((final Payee payee) => payee.name.value == name);
  }

  List<Payee> getListSorted() {
    final list = iterableList().toList();
    list.sort((a, b) => sortByString(a.name.value, b.name.value, true));
    return list;
  }

  String getNameFromId(final int id) {
    final Payee? payee = get(id);
    if (payee == null) {
      return '<no name> $id';
    }
    return payee.name.value;
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
                  (element) => element.payee.value == payeeToCheck.uniqueId,
                ) ==
            null) {
          // No transactions for this payee, we can delete it
          Data().payees.deleteItem(payeeToCheck);
        }
      }
    }
  }
}
