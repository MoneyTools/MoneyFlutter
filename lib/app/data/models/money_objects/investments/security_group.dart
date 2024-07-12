import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/investments/investment_types.dart';
import 'package:money/app/data/models/money_objects/investments/security_purchase.dart';
import 'package:money/app/data/models/money_objects/securities/security.dart';

class SecurityGroup {
  DateTime? date;
  Account? filter;
  List<SecurityPurchase> purchases = [];
  Security? security;
  TaxStatus taxStatus = TaxStatus.any;
  SecurityType? type;
}

enum TaxStatus {
  taxable,
  taxDeferred,
  taxFree,
  any,
}
