import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/investments/investment_types.dart';
import 'package:money/app/data/models/money_objects/investments/security_purchase.dart';
import 'package:money/app/data/models/money_objects/securities/security.dart';

class SecurityGroup {
  List<SecurityPurchase> purchases = [];
  TaxStatus taxStatus = TaxStatus.any;

  DateTime? date;
  Account? filter;
  Security? security;
  SecurityType? type;
}

enum TaxStatus {
  taxable,
  taxDeferred,
  taxFree,
  any,
}
