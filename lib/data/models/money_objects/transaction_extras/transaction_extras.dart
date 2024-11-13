import 'package:money/core/helpers/json_helper.dart';
import 'package:money/data/models/money_objects/money_objects.dart';
import 'package:money/data/models/money_objects/transaction_extras/transaction_extra.dart';

// Export
export 'package:money/data/models/money_objects/transaction_extras/transaction_extra.dart';

class TransactionExtras extends MoneyObjects<TransactionExtra> {
  TransactionExtras() {
    collectionName = 'TransactionExtras';
  }

  @override
  TransactionExtra instanceFromJson(final MyJson json) {
    return TransactionExtra.fromJson(json);
  }
}
