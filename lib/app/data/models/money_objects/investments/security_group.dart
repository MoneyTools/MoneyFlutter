import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/investments/investment_types.dart';
import 'package:money/app/data/models/money_objects/investments/security_purchase.dart';
import 'package:money/app/data/models/money_objects/securities/security.dart';

class SecurityGroup {
  DateTime? date;
  Security? security;
  SecurityType? type;
  List<SecurityPurchase> purchases = [];
  TaxStatus taxStatus = TaxStatus.any;
  Account? filter;
}

enum TaxStatus {
  taxable,
  taxDeferred,
  taxFree,
  any,
}
