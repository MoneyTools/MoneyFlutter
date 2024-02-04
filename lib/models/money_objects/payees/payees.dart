import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/payees/payee.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';

class Payees extends MoneyObjects<Payee> {
  String getNameFromId(final int id) {
    final Payee? payee = get(id);
    if (payee == null) {
      return '';
    }
    return payee.name.value;
  }

  Payee? getByName(final String name) {
    return iterableList().firstWhereOrNull((final Payee payee) => payee.name.value == name);
  }

  /// Attempts to find payee wih the given name
  /// if not found create a new payee and return that instance
  Payee findOrAddPayee(final String name) {
    // find or add account of given name
    Payee? payee = getByName(name);

    // if not found add new payee
    payee ??= Payee()
      ..id.value = iterableList().length
      ..name.value = name;
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
      addEntry(Payee()
        ..id.value = id
        ..name.value = name);
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
      addEntry(Payee()
        ..id.value = i
        ..name.value = names[i]);
    }
  }

  @override
  void onAllDataLoaded() {
    for (final Payee payee in iterableList()) {
      payee.count.value = 0;
      payee.balance.value = 0;
    }

    for (Transaction t in Data().transactions.iterableList()) {
      final Payee? item = get(t.payeeId.value);
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
