class MoneyEntity {
  num id = -1;
  String name = "";

  MoneyEntity(this.id, this.name) {
    //
  }
}

class MoneyObjects {
  final List<MoneyEntity> _list = [];
  final Map<num, MoneyEntity> _map = {};

  MoneyObjects() {
//
  }

  getAsList() {
    return _list;
  }

  addEntry(MoneyEntity entry) {
    _list.add(entry);
    _map[entry.id] = entry;
  }

  MoneyEntity? get(id) {
    return _map[id];
  }

  String getNameFromId(num id) {
    var item = get(id);
    if (item == null) {
      return id.toString();
    }
    return item.name;
  }
}
