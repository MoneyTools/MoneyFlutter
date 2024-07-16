import 'dart:math';

import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/accounts/account_types_enum.dart';
import 'package:money/app/data/models/money_objects/aliases/alias.dart';
import 'package:money/app/data/models/money_objects/categories/category.dart';
import 'package:money/app/data/models/money_objects/currencies/currency.dart';
import 'package:money/app/data/models/money_objects/investments/investment.dart';
import 'package:money/app/data/models/money_objects/investments/investment_types.dart';
import 'package:money/app/data/models/money_objects/loan_payments/loan_payment.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';
import 'package:money/app/data/models/money_objects/payees/payee.dart';
import 'package:money/app/data/models/money_objects/rent_buildings/rent_building.dart';
import 'package:money/app/data/models/money_objects/securities/security.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';

class DataSimulator {
  int idAccountForInvestment = 5;
  int idStockApple = 0;
  int idStockFord = 1;

  void generateData() {
    Data().clearExistingData();
    _generateCurrencies();
    _generateAccounts();
    _generatePayees();
    _generateAliases();
    _generateCategories();
    _generateInvestments();
    _generateLoans();
    _generateRentals();
    _generateTransactions();
  }

  void transactionForDemoData(final DateTime date, final Account account) {
    int categoryId = Random().nextInt(10);

    int payeeId = Random().nextInt(10);

    if (payeeId == 0 || payeeId == 1) {
      // The first tow payees are "Food related" so assign the "Food" category
      categoryId = Data().categories.getByName('Food')!.uniqueId;
    }

    // generate an amount
    // Expenses should be a negative value;
    final double amount = _getRandomAmount() * (Data().categories.isCategoryAnExpense(categoryId) ? -1 : 1);

    final MyJson demoJson = <String, dynamic>{
      'Id': -1,
      'Account': account.id.value,
      'Date': date,
      'Payee': payeeId,
      'Category': categoryId,
      'Amount': amount,
    };

    final Transaction t = Transaction.fromJSon(demoJson, 0);
    Data().transactions.appendNewMoneyObject(t, fireNotification: false);
  }

  void _addInvestment(
    final Account account,
    final dateAsString,
    final int stockId,
    final InvestmentType activity,
    final double quantity,
    final double tradePrice,
  ) {
    DateTime date = DateTime.parse(dateAsString);
    var t = _addNewTransaction(account, date);
    double transactionAmount = tradePrice * quantity;
    if (activity == InvestmentType.buy) {
      transactionAmount *= -1;
    }
    t.amount.value.setAmount(transactionAmount);

    Data().investments.appendMoneyObject(
          Investment(
            id: t.uniqueId,
            investmentType: activity.index,
            security: stockId,
            unitPrice: tradePrice,
            units: quantity,
            tradeType: InvestmentTradeType.none.index,
          ),
        );
  }

  Transaction _addNewTransaction(Account account, DateTime date) {
    Transaction t = Transaction(accountId: account.uniqueId, date: date);
    Data().transactions.appendNewMoneyObject(t);
    return t;
  }

  void _generateAccounts() {
    final List<MyJson> demoAccounts = <MyJson>[
      {
        'Id': 0,
        'AccountId': 'BankAccountIdForTesting',
        'Name': 'U.S. Bank',
        'Type': AccountType.savings.index,
        'Currency': 'USD',
      },
      {
        'Id': 1,
        'Name': 'Bank Of America',
        'AccountId': '0001',
        'Type': AccountType.checking.index,
        'Currency': 'USD',
      },
      {
        'Id': 2,
        'Name': 'KeyBank',
        'AccountId': '0002',
        'Type': AccountType.moneyMarket.index,
        'Currency': 'USD',
      },
      {
        'Id': 3,
        'Name': 'Mattress',
        'AccountId': '0003',
        'Type': AccountType.cash.index,
        'Currency': 'USD',
      },
      {
        'Id': 4,
        'Name': 'Revolut UK',
        'AccountId': '0005',
        'Type': AccountType.credit.index,
        'Currency': 'GBP',
      },
      {
        'Id': idAccountForInvestment,
        'Name': 'Fidelity',
        'AccountId': '0006',
        'Type': AccountType.investment.index,
        'Currency': 'USD',
      },
      {
        'Id': 6,
        'Name': 'Bank of Japan',
        'AccountId': '11111',
        'Type': AccountType.retirement.index,
        'Currency': 'JPY',
      },
      {
        'Id': 7,
        'Name': 'James Bonds',
        'AccountId': '007',
        'Type': AccountType.asset.index,
        'Currency': 'GBP',
      },
      {
        'Id': 8,
        'Name': 'KickStarter',
        'AccountId': 'K000',
        'Type': AccountType.loan.index,
        'CategoryIdForInterest': Data()
            .categories
            .getOrCreateCategory(
              'Loan:Interest',
              CategoryType.expense,
            )
            .uniqueId,
        'CategoryIdForPrincipal': Data()
            .categories
            .getOrCreateCategory(
              'Loan:Principal',
              CategoryType.expense,
            )
            .uniqueId,
        'Currency': 'CAD',
      },
      {
        'Id': 9,
        'Name': 'Home Remodel',
        'AccountId': 'H0001',
        'Type': AccountType.creditLine.index,
        'Currency': 'USD',
      },
    ];

    for (final MyJson demoAccount in demoAccounts) {
      Data().accounts.appendMoneyObject(Account.fromJson(demoAccount));
    }
  }

  void _generateAliases() {
    Data().aliases.appendNewMoneyObject(
          Alias(
            id: -1,
            payeeId: 2,
            pattern: 'ABC',
            flags: AliasType.none.index,
          ),
        );
    Data().aliases.appendNewMoneyObject(
          Alias(
            id: -1,
            payeeId: 2,
            pattern: 'abc',
            flags: AliasType.none.index,
          ),
        );
    Data().aliases.appendNewMoneyObject(
          Alias(
            id: -1,
            payeeId: 3,
            pattern: '.*starbucks.*',
            flags: AliasType.regex.index,
          ),
        );
  }

  void _generateCategories() {
    Data().categories.appendNewMoneyObject(
          Category(
            id: -1,
            name: 'Food',
            description: '',
            type: CategoryType.expense,
            color: '#FF1122FF',
          ),
        );
    Data().categories.appendNewMoneyObject(
          Category(
            id: -1,
            name: 'Paychecks',
            description: '',
            type: CategoryType.income,
            color: '#FFAAFFBB',
          ),
        );
    Data().categories.appendNewMoneyObject(
          Category(
            id: -1,
            name: 'Investment',
            description: '',
            type: CategoryType.investment,
            color: '#FFA1A2A3',
          ),
        );
    Data().categories.appendNewMoneyObject(
          Category(
            id: -1,
            name: 'Interests',
            description: '',
            type: CategoryType.income,
            color: '#FFFF2233',
          ),
        );
    Data().categories.appendNewMoneyObject(
          Category(
            id: -1,
            name: 'Rental',
            description: '',
            type: CategoryType.income,
            color: '#FF11FF33',
          ),
        );
    Data().categories.appendNewMoneyObject(
          Category(
            id: -1,
            name: 'Mortgage',
            description: '',
            type: CategoryType.expense,
            color: '#FFBB2233',
          ),
        );
    Data().categories.appendNewMoneyObject(
          Category(
            id: -1,
            name: 'Saving',
            description: '',
            type: CategoryType.income,
            color: '#FFBB2233',
          ),
        );
    Data().categories.appendNewMoneyObject(
          Category(
            id: -1,
            name: 'Bills',
            description: '',
            type: CategoryType.expense,
            color: '#FF11DD33',
          ),
        );
    Data().categories.appendNewMoneyObject(
          Category(
            id: -1,
            name: 'Taxes',
            description: '',
            type: CategoryType.expense,
            color: '#FF1122DD',
          ),
        );
    Data().categories.appendNewMoneyObject(
          Category(
            id: -1,
            name: 'School',
            description: '',
            type: CategoryType.expense,
          ),
        );
  }

  void _generateCurrencies() {
    final List<MyJson> demoCurrencies = <MyJson>[
      {
        'Id': -1,
        'Name': 'USA',
        'Symbol': 'USD',
        'CultureCode': 'en-US',
        'Ratio': 1.09,
        'LastRatio': 1.12,
      },
      {
        'Id': -1,
        'Name': 'Canada',
        'Symbol': 'CAD',
        'CultureCode': 'en-CA',
        'Ratio': 0.75,
        'LastRatio': 0.85,
      },
      {
        'Id': -1,
        'Name': 'Euro',
        'Symbol': 'EUR',
        'CultureCode': 'en-ES',
        'Ratio': 1.15,
        'LastRatio': 1.11,
      },
      {
        'Id': -1,
        'Name': 'UK',
        'Symbol': 'GBP',
        'CultureCode': 'en-GB',
        'Ratio': 1.25,
        'LastRatio': 1.21,
      },
      {
        'Id': -1,
        'Name': 'Japan',
        'Symbol': 'JPY',
        'CultureCode': 'en-JP',
        'Ratio': 1 / 147.72,
        'LastRatio': 0,
      },
    ];
    for (final MyJson demoCurrency in demoCurrencies) {
      Data().currencies.appendNewMoneyObject(Currency.fromJson(demoCurrency));
    }
  }

  void _generateInvestments() {
    _generateStocks();

    final account = Data().accounts.get(idAccountForInvestment)!;

    // Buy Apple
    _addInvestment(account, '2015-06-20', idStockApple, InvestmentType.buy, 100, 199.99);

    // Buy Ford
    _addInvestment(account, '2012-07-26', idStockFord, InvestmentType.buy, 1000, 8.86);

    // Sell Ford
    _addInvestment(account, '2013-01-15', idStockFord, InvestmentType.sell, 1000, 14.14);
  }

  void _generateLoans() {
    final Account? accountForLoan = Data().accounts.iterableList().firstWhereOrNull(
          (final Account element) => element.type.value == AccountType.loan,
        );
    if (accountForLoan != null) {
      for (int i = 0; i < 12 * 20; i++) {
        Data().loanPayments.appendNewMoneyObject(
              LoanPayment(
                id: -1,
                accountId: accountForLoan.id.value,
                date: DateTime.now(),
                principal: 100,
                interest: 10,
                memo: '',
              ),
            );
      }
    }
  }

  void _generatePayees() {
    final List<String> names = <String>[
      'Liberty Food',
      'Central Perk',
      'John',
      'Paul',
      'George',
      'Ringo',
      'JP Dev',
      'Chris',
      'Bill',
      'Steve',
    ];
    for (int i = 0; i < names.length; i++) {
      Data().payees.appendNewMoneyObject(
            Payee()
              ..id.value = -1
              ..name.value = names[i],
          );
    }
  }

  List<DateTime> _generateRandomDates(int count) {
    final now = DateTime.now();
    final tenYearsAgo = now.subtract(
      const Duration(days: 365 * 10),
    ); // Adjust for leap years if needed

    final random = Random();
    final dates = List<DateTime>.generate(count, (index) {
      final randomDaysSinceTenYearsAgo = random.nextInt(365 * 10); // Random days within 10 years
      return tenYearsAgo.add(Duration(days: randomDaysSinceTenYearsAgo));
    });
    return dates;
  }

  void _generateRentals() {
    final RentBuilding instance = RentBuilding();
    instance.id.value = 0;
    instance.name.value = 'AirBnB';
    instance.address.value = 'One Washington DC';
    Data().rentBuildings.appendMoneyObject(instance);
  }

  void _generateStocks() {
    Data().securities.appendMoneyObject(
          Security(
            id: 0,
            name: 'Apple Inc',
            symbol: 'AAPL',
            price: 200.0,
            lastPrice: 201.0,
            cuspid: '',
            securityType: SecurityType.equity.index,
            taxable: 0,
            priceDate: DateTime(2015, 1, 1),
          ),
        );
    Data().securities.appendMoneyObject(
          Security(
            id: 1,
            name: 'Ford',
            symbol: 'F',
            price: 7.0,
            lastPrice: 7.10,
            cuspid: '',
            securityType: SecurityType.equity.index,
            taxable: 0,
            priceDate: DateTime(2020, 1, 1),
          ),
        );
  }

  void _generateTransactions() {
    for (final Account account in Data().accounts.iterableList()) {
      final numberOfDatesNeeded = _getQuantityOfTransactionBasedOnAccountType(account.type.value);
      final dates = _generateRandomDates(numberOfDatesNeeded);
      for (final date in dates) {
        transactionForDemoData(date, account);
      }
    }
  }

  int _getQuantityOfTransactionBasedOnAccountType(final AccountType type) {
    switch (type) {
      case AccountType.savings:
        return 200;
      case AccountType.checking:
        return 900;
      case AccountType.moneyMarket:
        return 100;
      case AccountType.cash:
        return 12;
      case AccountType.credit:
        return 1000;
      case AccountType.investment:
        return 150;
      case AccountType.retirement:
        return 100;
      case AccountType.asset:
        return 10;
      case AccountType.categoryFund:
        return 10;
      case AccountType.loan:
        return 12 * 20;
      case AccountType.creditLine:
        return 50;
      default:
        return 500;
    }
  }

  double _getRandomAmount() {
    final bool isExpense = (Random().nextInt(5) < 4); // Generate more expense transaction than income once
    final double amount = Random().nextDouble() * (isExpense ? -500 : 2500);
    return roundDouble(amount, 2);
  }
}
