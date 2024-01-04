import 'package:money/models/money_entity.dart';
import 'package:money/models/payees.dart';

enum AliasType {
  none,
  regex,
}

class Alias extends MoneyEntity {
  AliasType type = AliasType.none;
  int payeeId = -1;
  RegExp regex = RegExp('');
  late final Payee payee;

  Alias(
    super.id,
    super.name, {
    this.type = AliasType.none,
    this.payeeId = -1,
  }) {
    payee = Payees.get(payeeId)!;
  }
}

class Aliases {
  static MoneyObjects<Alias> moneyObjects = MoneyObjects<Alias>();

  static Alias? get(final num id) {
    return moneyObjects.get(id);
  }

  static String getNameFromId(final num id) {
    return moneyObjects.getNameFromId(id);
  }

  clear() {
    moneyObjects.clear();
  }

  int length() {
    return moneyObjects.getAsList().length;
  }

  load(final List<Map<String, Object?>> rows) async {
    clear();
    for (final Map<String, Object?> row in rows) {
      final AliasType type = row['Flags'] == 0 ? AliasType.none : AliasType.regex;
      moneyObjects.addEntry(Alias(
        // id
        row['Id'] as int,
        // name
        row['Pattern'].toString(),
        type: type,
        payeeId: row['Payee'] as int,
      ));
    }
  }

  loadDemoData() {
    clear();

    final List<String> names = <String>[];
    for (int i = 0; i < names.length; i++) {
      moneyObjects.addEntry(Alias(i, names[i]));
    }
  }

  static onAllDataLoaded() {}
}
