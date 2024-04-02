import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/securities/security.dart';

// Exports
export 'package:money/models/money_objects/securities/security.dart';

class Securities extends MoneyObjects<Security> {
  Securities() {
    collectionName = 'Securities';
  }

  String getSymbolFromId(final int securityId) {
    final Security? security = get(securityId);
    if (security == null) {
      return '?$security?';
    }
    return security.symbol;
  }

  @override
  void loadFromJson(final List<MyJson> rows) {
    clear();
    for (final MyJson row in rows) {
      appendMoneyObject(Security.fromJson(row));
    }
  }

  @override
  String toCSV() {
    return super.getCsvFromList(
      getListSortedById(),
    );
  }
}
