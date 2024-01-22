enum AccountType {
  savings, // 0
  checking, // 1
  moneyMarket, // 2
  cash, // 3
  credit, // 4
  investment, // 5
  retirement, // 6
  notUsed_7, // 7 There is a hole here from deleted type which we can fill when we invent new types, but the types 8-10 have to keep those numbers or else we mess up the existing databases.
  asset, // 8 Used for tracking Assets like "House, Car, Boat, Jewelry, this helps to make NetWorth more accurate
  categoryFund, // 9 a pseudo account for managing category budgets
  loan, // 10
  creditLine, // 11
}

enum AccountFlags {
  none, // 0
  budgeted, // 1
  closed, // 2
  taxDeferred, // 3
}

/// Convert a text into a AccountType
AccountType getAccountTypeFromText(final String text) {
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
    case 'creditLine':
      return AccountType.creditLine;
    default:
      return AccountType.notUsed_7;
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
