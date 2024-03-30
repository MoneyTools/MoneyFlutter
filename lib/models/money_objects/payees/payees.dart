import 'package:money/helpers/list_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/payees/payee.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/storage/data/data.dart';

class Payees extends MoneyObjects<Payee> {
  Payees() {
    collectionName = 'Payees';
  }

  List<Payee> getListSorted() {
    final list = iterableList().toList();
    list.sort((a, b) => sortByString(a.name.value, b.name.value, true));
    return list;
  }

  String getNameFromId(final int id) {
    final Payee? payee = get(id);
    if (payee == null) {
      return '';
    }
    return payee.name.value;
  }

  Payee? getByName(final String name) {
    if (name.isEmpty) {
      return null;
    }
    return iterableList().firstWhereOrNull((final Payee payee) => payee.name.value == name);
  }

  /// if not found returns -1
  int getPayeeIdFromName(final String name) {
    final Payee? payee = getByName(name);
    if (payee == null) {
      return -1;
    }
    return payee.uniqueId;
  }

  /// Attempts to find payee wih the given name
  /// if not found create a new payee and return that instance
  Payee findOrAddPayee(final String name, {bool fireNotification = true}) {
    // find or add account of given name
    Payee? payee = getByName(name);

    // if not found add new payee
    if (payee == null) {
      payee = Payee()
        ..id.value = -1
        ..name.value = name;
      Data().payees.appendNewMoneyObject(payee);
    }
    return payee;
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
  void loadDemoData() {
    clear();

    final List<String> names = <String>[
      'John',
      'Paul',
      'George',
      'Ringo',
      'Jean-Pierre',
      'Chris',
      'Bill',
      'Steve',
      'Sue',
      'Barbara'
    ];
    for (int i = 0; i < names.length; i++) {
      appendNewMoneyObject(
        Payee()
          ..id.value = -1
          ..name.value = names[i],
      );
    }
  }

  @override
  void onAllDataLoaded() {
    for (final Payee payee in iterableList()) {
      payee.count.value = 0;
      payee.balance.value = 0;
    }

    for (Transaction t in Data().transactions.iterableList()) {
      final Payee? item = get(t.payee.value);
      if (item != null) {
        item.count.value++;
        item.balance.value += t.amount.value;
      }
    }
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      getListSortedById(),
    );
  }
}
