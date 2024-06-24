import 'package:money/app/data/models/money_objects/accounts/account_types_enum.dart';

enum AccountFlags {
  none, // 0
  budgeted, // 1
  closed, // 2
  taxDeferred, // 3
}

/// Convert a text into a AccountType
AccountType? getAccountTypeFromText(final String text) {
  switch (text.toLowerCase()) {
    case 'savings':
      return AccountType.savings;
    case 'checking':
      return AccountType.checking;
    case 'moneymarket':
      return AccountType.moneyMarket;
    case 'cash':
      return AccountType.cash;
    case 'credit':
    case 'creditcard': // as seen in OFX <ACCTTYPE>
      return AccountType.credit;
    case 'creditline':
      return AccountType.creditLine;
    case 'investment':
      return AccountType.investment;
    case 'retirement':
      return AccountType.retirement;
    case 'asset':
      return AccountType.asset;
    case 'categoryfund':
      return AccountType.categoryFund;
    case 'loan':
      return AccountType.loan;
    default:
      return null;
  }
}

/// Convert a AccountType into a readable/localized String
String getTypeAsText(final AccountType type) {
  switch (type) {
    case AccountType.savings:
      return 'Savings';
    case AccountType.checking:
      return 'Checking';
    case AccountType.moneyMarket:
      return 'MoneyMarket';
    case AccountType.cash:
      return 'Cash';
    case AccountType.credit:
      return 'Credit';
    case AccountType.investment:
      return 'Investment';
    case AccountType.retirement:
      return 'Retirement';
    case AccountType.asset:
      return 'Asset';
    case AccountType.categoryFund:
      return 'CategoryFund';
    case AccountType.loan:
      return 'Loan';
    case AccountType.creditLine:
      return 'CreditLine';
    default:
      break;
  }

  return 'other $type';
}

List<String> getAccountTypeAsText() {
  return [
    getTypeAsText(AccountType.checking),
    getTypeAsText(AccountType.savings),
    getTypeAsText(AccountType.retirement),
    getTypeAsText(AccountType.cash),
    getTypeAsText(AccountType.credit),
    getTypeAsText(AccountType.creditLine),
    getTypeAsText(AccountType.investment),
    getTypeAsText(AccountType.moneyMarket),
    getTypeAsText(AccountType.asset),
    getTypeAsText(AccountType.loan),
  ];
}
