import 'package:collection/collection.dart';

class Payee {
  num id=-1;
  String accountId = "";
  String name = "";
  double amount = 0.00;
  double balance = 0.00;

  Payee(this.id, this.name);
}


class Payees {
  num runningBalance = 0;

  List<Payee> list = [];

  Payee? get(id){
    return list.firstWhereOrNull((item) => item.id == id);
  }

  String getNameFromId(num id) {
    var payee = get(id);
    if (payee == null) {
      return id.toString();
    }
    return payee.name;
  }

  load(rows) async {
    runningBalance = 0;

    /*
     */
    for (var row in rows) {
      var id = num.parse(row["Id"].toString());
      // var accountId = row["AccountId"].toString();
      var name = row["Name"].toString();
      list.add(Payee(id, name));
    }
    return list;
  }

  loadScale() {
    List<String> names = ['John', 'Paul', 'George','Ringo','Jean-Pierre', 'Chris', 'Bill', 'Steve', 'Sue', 'Barbara'];
    list = List<Payee>.generate(10, (i) => Payee(i, names[i]));
  }
}
