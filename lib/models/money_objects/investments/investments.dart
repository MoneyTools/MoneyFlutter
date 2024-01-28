import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/investments/investment.dart';
import 'package:money/models/money_objects/money_objects.dart';

// Exports
export 'package:money/models/money_objects/investments/investment.dart';

class Investments extends MoneyObjects<Investment> {
  @override
  void loadFromJson(final List<MyJson> rows) {
    clear();
    for (final MyJson row in rows) {
      addEntry(Investment.fromJson(row));
    }
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      getListSortedById(),
    );
  }
}
