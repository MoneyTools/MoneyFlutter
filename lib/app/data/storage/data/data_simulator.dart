import 'dart:math';
import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/list_helper.dart';
import 'package:money/app/core/helpers/string_helper.dart';
import 'package:money/app/data/models/money_objects/accounts/account.dart';
import 'package:money/app/data/models/money_objects/accounts/account_types_enum.dart';
import 'package:money/app/data/models/money_objects/aliases/alias.dart';
import 'package:money/app/data/models/money_objects/categories/category.dart';
import 'package:money/app/data/models/money_objects/currencies/currency.dart';
import 'package:money/app/data/models/money_objects/investments/investment.dart';
import 'package:money/app/data/models/money_objects/investments/investment_types.dart';
import 'package:money/app/data/models/money_objects/loan_payments/loan_payment.dart';
import 'package:money/app/data/models/money_objects/payees/payee.dart';
import 'package:money/app/data/models/money_objects/rent_buildings/rent_building.dart';
import 'package:money/app/data/models/money_objects/securities/security.dart';
import 'package:money/app/data/models/money_objects/splits/money_split.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/view_stocks/picker_security_type.dart';

class DataSimulator {
  int idAccountForLoan = 9;
  int idStockApple = 0;
  int idStockFord = 1;

  late final Account _accountBankCanada;
  late final Account _accountBankUSA;
  late final Account _accountCreditCardUSD;
  late final Account _accountForInvestments;
  late final Account _accountStartupLoan;
  late final Category _categoryBills;
  late final Category _categoryBillsElectricity;
  late final Category _categoryBillsInternet;
  late final Category _categoryBillsPhone;
  late final Category _categoryBillsTV;
  late final Category _categoryFood;
  late final Category _categoryFoodGrocery;
  late final Category _categoryFoodRestaurant;
  late final Category _categoryHomeLoanDownPayment;
  late final Category _categoryHomeLoanMorgageInterest;
  late final Category _categoryHomeLoanMorgagePrincipal;
  late final Category _categoryInvestmentTrades;
  late final Category _categorySalary;
  late final Category _categorySalaryBonus;
  late final Category _categorySalaryPaycheck;
  late final Category _categorySplit;
  late final Category _categorySubscriptionTransport;
  late final Category _categorySubsriptions;
  late final Category _categorySubsriptionsGym;
  late final Category _categorySubsriptionsStreaming;
  final double _monthlyHomeLoan = -2000;
  final double _monthlyRent = -600;
  final int _numberOFYearInThePast = 20;
  final double _startingYearlySalaryFirstJob = 15000.00;
  final double _startingYearlySalarySecondJob = 50000.00;
  final _today = DateTime.now();
  final double _yearlyInflation = 3.00;

  late DateTime _dateOfFirstBigJob;

  void generateData() {
    Data().clearExistingData();
    _generateCurrencies();
    _generateAccounts();
    _generateAliases();
    _generateCategories();
    _generateInvestments();

    _generateRentals();
    _generateTransactionsSalary();
    _generateLoans();
    _generateTransfersToRentAndHomeLoan();

    _generateSubscriptionsOnCheckingAccount();
    _generateSubscriptionsOnCreditCard();

    generateTransactionsForCreditCard();
    _generateTransfersToCreditCardPayment();
  }

  // ignore: unused_element
  List<DateTime> generateRandomDates(int count) {
    final tenYearsAgo = _today.subtract(
      Duration(days: 365 * _numberOFYearInThePast),
    ); // Adjust for leap years if needed

    final random = Random();
    final dates = List<DateTime>.generate(count, (index) {
      final randomDaysSinceTenYearsAgo = random.nextInt(365 * _numberOFYearInThePast);
      return tenYearsAgo.add(Duration(days: randomDaysSinceTenYearsAgo));
    });
    return dates;
  }

  void generateTransactionsForCreditCard() {
    final dates = generateListOfDatesRandom(year: _numberOFYearInThePast, howManyPerMonths: 4);

    for (final date in dates) {
      final selectedCategory = [
        [
          _categorySubscriptionTransport,
          [
            ['City Bus', 3],
            ['Taxi', 20],
            ['Uber', 30],
          ],
        ],
        [
          _categoryFoodGrocery,
          [
            ['TheFoodStore', 50],
            ['SafeWay', 80],
            ['WholeFood', 200],
          ],
        ],
        [
          _categoryFoodRestaurant,
          [
            ['Starbucks', 10],
            ['AppleBees', 100],
            ['PizzaHut', 20],
          ],
        ],
      ].getRandomItem();

      Category category = selectedCategory[0] as Category;

      final payeeAndMaxAmount = (selectedCategory[1] as List<dynamic>).getRandomItem();
      double maxSpendingOnCreditCard = payeeAndMaxAmount[1].toDouble();

      final Transaction source = _addTransactionAccountDatePayeeCategory(
        account: _accountCreditCardUSD,
        date: date,
        payeeId: Data().payees.getOrCreate(payeeAndMaxAmount[0]).uniqueId,
        categoryId: category.uniqueId,
      );
      if (date.isAfter(_dateOfFirstBigJob)) {
        // big job and spends more
        maxSpendingOnCreditCard = maxSpendingOnCreditCard * 3;
      }
      source.fieldAmount.setAmount(-getRandomAmount(maxSpendingOnCreditCard.toInt()));
    }
  }

  void generateTransactionsMontlyExpenses({
    required Account account,
    required String payeeName,
    required Category category,
    required double amount,
    required int yearMin,
    required int yearMax,
    required int dayOfTheMonth,
  }) {
    final payee = Data().payees.getOrCreate(payeeName);

    for (int year = yearMin; year <= yearMax; year++) {
      for (int month = 1; month <= 12; month++) {
        _addTransactionAccountDatePayeeCategory(
          account: account,
          date: DateTime(year, month, dayOfTheMonth),
          payeeId: payee.uniqueId,
          categoryId: category.uniqueId,
          amount: amount,
        );
      }
    }
  }

  double getAmount(final int minValue, final int maxValue) {
    final double amount = minValue + Random().nextDouble() * (maxValue - minValue);
    return roundDouble(amount, 2);
  }

  DateTime getLastDayOfPreviousMonth(DateTime date) {
    final previousMonth = DateTime(date.year, date.month - 1);
    final daysInPreviousMonth = DateTime(previousMonth.year, previousMonth.month + 1, 0).day;
    return DateTime(previousMonth.year, previousMonth.month, daysInPreviousMonth).endOfDay;
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
    double transactionAmount = tradePrice * quantity;
    String action = 'sold';
    final stock = Data().securities.get(stockId);

    if (activity == InvestmentType.buy) {
      action = 'bought';
      transactionAmount *= -1;
    }
    final payee = Data().payees.getOrCreate('Broker');

    var t = _addTransactionAccountDatePayeeCategory(
      account: account,
      date: date,
      amount: transactionAmount,
      payeeId: payee.uniqueId,
      categoryId: _categoryInvestmentTrades.uniqueId,
      memo:
          'You $action ${formatDoubleTrimZeros(quantity)} shares of "${stock!.fieldName.value} (${stock.fieldSymbol.value})"',
    );

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

  Account _addNewAccount(int id, name, accountId, type, currency) {
    final account = Account.fromJson({
      'Id': id,
      'Name': name,
      'AccountId': accountId,
      'Type': type,
      'Currency': currency,
    });
    if (id == -1) {
      Data().accounts.appendNewMoneyObject(account, fireNotification: false);
    } else {
      Data().accounts.appendMoneyObject(account);
    }

    return account;
  }

  void _buyHome(final Payee payeeForHomeLoan, final DateTime date) {
    final accountAssetHome = _addNewAccount(
      -1,
      'Main Home',
      'A0001',
      AccountType.asset.index,
      'USD',
    );

    _addTransactionAccountDatePayeeCategory(
      account: accountAssetHome,
      date: date,
      amount: 250000,
      categoryId:
          Data().categories.addNewCategory(name: 'Investment:PropertyValue', type: CategoryType.investment).uniqueId,
      memo: 'Purchase house valued at 250K',
    );

    _addTransactionAccountDatePayeeCategory(
      account: _accountBankUSA,
      date: date,
      payeeId: payeeForHomeLoan.uniqueId,
      categoryId: _categoryHomeLoanDownPayment.uniqueId,
      amount: -30000,
      memo: 'Down payment',
    );
  }

  void _generateAccounts() {
    _accountBankUSA = _addNewAccount(
      -1,
      'Bank Of America',
      'B0001',
      AccountType.checking.index,
      'USD',
    );

    // Canadin Bank Account
    _accountBankCanada = _addNewAccount(
      -1,
      'Bank Of Montreal',
      'B0002',
      AccountType.savings.index,
      'CAD',
    );

    // Fund that account
    _addTransactionAccountDatePayeeCategory(
      account: _accountBankCanada,
      date: getDateShiftedByYears(-21, 1, 1),
      amount: 100000,
      payeeId: Data().payees.getOrCreate('Lottery Win').uniqueId,
      categoryId: Data()
          .categories
          .addNewCategory(
            name: 'Misc Incomes',
            type: CategoryType.income,
            color: '#004400',
          )
          .uniqueId,
      memo: 'Initial openening of account',
    );

    _accountCreditCardUSD = _addNewAccount(
      -1,
      'VisaCard',
      '0002',
      AccountType.credit.index,
      'USD',
    );

    _accountForInvestments = _addNewAccount(
      -1,
      'Fidelity',
      '0003',
      AccountType.investment.index,
      'USD',
    );
    _accountStartupLoan = _addNewAccount(
      -1,
      'Startup',
      '0004',
      AccountType.loan.index,
      'CAD',
    );

    /// Setup categories for this loans
    Data().categories.appendNewMoneyObject(
          Category(
            id: -1,
            name: 'Loans',
            description: '',
            type: CategoryType.expense,
            color: '#FFAAFFAA',
          ),
        );
    _accountStartupLoan.fieldCategoryIdForInterest.value =
        Data().categories.getOrCreate('Loans:Interest:Startup', CategoryType.investment).uniqueId;
    _accountStartupLoan.fieldCategoryIdForPrincipal.value =
        Data().categories.getOrCreate('Loans:Principal:Startup', CategoryType.investment).uniqueId;
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
    // Expenses
    _categorySplit = Data().categories.addNewCategory(
          name: 'Split',
          type: CategoryType.expense,
        );

    // Bills
    {
      _categoryBills = Data().categories.addNewCategory(
            name: 'Bills',
            type: CategoryType.expense,
            color: '#FFFF0000',
          );
      _categoryBillsElectricity = Data().categories.addNewCategory(
            parentId: _categoryBills.uniqueId,
            name: 'Electricity',
            type: CategoryType.expense,
          );

      Data().categories.addNewCategory(
            parentId: _categoryBills.uniqueId,
            name: 'School',
            description: '',
            type: CategoryType.expense,
          );

      _categoryBillsPhone = Data().categories.addNewCategory(
            parentId: _categoryBills.uniqueId,
            name: 'Phone',
            type: CategoryType.expense,
          );

      _categoryBillsTV = Data().categories.addNewCategory(
            parentId: _categoryBills.uniqueId,
            name: 'TV',
            type: CategoryType.expense,
          );

      _categoryBillsInternet = Data().categories.addNewCategory(
            parentId: _categoryBills.uniqueId,
            name: 'Internet',
            type: CategoryType.expense,
          );
    }

    // Food
    {
      _categoryFood = Data().categories.addNewCategory(
            name: 'Food',
            type: CategoryType.expense,
            color: '#FFFF22FF',
          );

      _categoryFoodGrocery = Data().categories.addNewCategory(
            parentId: _categoryFood.uniqueId,
            name: 'Grocery',
            type: CategoryType.expense,
          );

      _categoryFoodRestaurant = Data().categories.addNewCategory(
            parentId: _categoryFood.uniqueId,
            name: 'Restaurant',
            type: CategoryType.expense,
          );
    }

    // Subscriptions
    {
      _categorySubsriptions = Data().categories.addNewCategory(
            name: 'Subscriptions',
            type: CategoryType.expense,
            color: '#FFFFaaaa',
          );

      _categorySubsriptionsGym = Data().categories.addNewCategory(
            parentId: _categorySubsriptions.uniqueId,
            name: 'Gym',
            type: CategoryType.expense,
          );

      _categorySubsriptionsStreaming = Data().categories.addNewCategory(
            parentId: _categorySubsriptions.uniqueId,
            name: 'Streaming',
            type: CategoryType.expense,
          );

      _categorySubscriptionTransport = Data().categories.addNewCategory(
            parentId: _categorySubsriptions.uniqueId,
            name: 'Transportaion',
            type: CategoryType.expense,
          );
    }

    // Salary
    {
      _categorySalary = Data().categories.addNewCategory(
            parentId: _categoryFood.uniqueId,
            name: 'Salary',
            type: CategoryType.income,
            color: '#FF00FF00',
            description: 'Main income',
          );

      _categorySalaryPaycheck = Data().categories.addNewCategory(
            parentId: _categorySalary.uniqueId,
            name: 'Paycheck',
          );

      _categorySalaryBonus = Data().categories.addNewCategory(
            parentId: _categorySalary.uniqueId,
            name: 'Bonus',
          );
    }

    // Investment
    {
      Data().categories.addNewCategory(
            name: 'Investment',
            description: '',
            type: CategoryType.investment,
            color: '#FF1122DD',
          );

      _categoryInvestmentTrades = Data().categories.addNewCategory(
            name: 'Investment:Trades',
          );
    }

    Data().categories.addNewCategory(
          name: 'Rental',
          description: '',
          type: CategoryType.income,
          color: '#FF11FF33',
        );

    // Loans
    {
      final homeLoan = Data().categories.addNewCategory(
            name: 'HomeLoans',
            description: '',
            type: CategoryType.expense,
            color: '#FFBB2233',
          );

      _categoryHomeLoanDownPayment = Data().categories.addNewCategory(
            parentId: homeLoan.uniqueId,
            name: 'DownPayment',
            type: CategoryType.investment,
          );

      _categoryHomeLoanMorgagePrincipal = Data().categories.addNewCategory(
            name: 'HomeLoans:Morgage:Principal',
            type: CategoryType.investment,
          );

      _categoryHomeLoanMorgageInterest = Data().categories.addNewCategory(
            name: 'HomeLoans:Morgage:Interest',
            type: CategoryType.expense,
          );
    }

    Data().categories.addNewCategory(
          name: 'Saving',
          description: '',
          type: CategoryType.income,
          color: '#FFBB2233',
        );

    {
      Data().categories.addNewCategory(
            name: 'Taxes',
            type: CategoryType.expense,
            color: '#FFA1A2A3',
          );
      Data().categories.addNewCategory(
            name: 'Taxes:IRS',
          );
      Data().categories.addNewCategory(
            name: 'Taxes:Property',
          );
      Data().categories.addNewCategory(
            name: 'Taxes:School',
          );
    }
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

    // Buy Apple
    _addInvestment(_accountForInvestments, '2015-06-20', idStockApple, InvestmentType.buy, 100, 199.99);

    // Buy Ford
    _addInvestment(_accountForInvestments, '2012-07-26', idStockFord, InvestmentType.buy, 1000, 8.86);

    // Sell Ford
    _addInvestment(_accountForInvestments, '2013-01-15', idStockFord, InvestmentType.sell, 1000, 14.14);
  }

  void _generateLoans() {
    double loanAmount = 20000; // 20K
    double loanRate = 4 / 100; // 4%
    double monthlyPayment = 500;

    //
    // First lend the initial loan of 20K
    //
    final receivingTransaction = _createTransferTransaction(
      accountSource: _accountBankCanada,
      accountDestination: _accountStartupLoan,
      date: getDateShiftedByYears(-6, 11, 11),
      amount: -loanAmount,
      memo: 'Invest in projet goto Mars',
    );

    // ensure that we have the correct category for this injection of Principale funds
    receivingTransaction.fieldCategoryId.value = _accountStartupLoan.fieldCategoryIdForPrincipal.value;

    final dates = generateListOfDates(yearInThePast: 5, howManyPerYear: 12, dayOfTheMonth: 9);

    for (final date in dates) {
      if (loanAmount < 0) {
        break; // done paying back the loan
      }

      final annuallyInterest = loanAmount * loanRate;
      var monthlyInterest = annuallyInterest / 12;
      var principaleForThisMonday = (monthlyPayment - monthlyInterest);
      if (isConsideredZero(monthlyInterest)) {
        monthlyInterest = 0;
        principaleForThisMonday = loanAmount;
        monthlyPayment = principaleForThisMonday;
        loanAmount = 0;
      }

      // reduce the remaining balance
      loanAmount -= principaleForThisMonday;

      Data().loanPayments.appendNewMoneyObject(
            LoanPayment(
              id: -1,
              accountId: _accountStartupLoan.uniqueId,
              date: date,
              principal: -principaleForThisMonday,
              interest: monthlyInterest,
              memo: '',
            ),
          );

      // Show the payment to the lender
      _addTransactionAccountDatePayeeCategory(
        account: _accountBankCanada,
        date: date,
        payeeId: Data().payees.getOrCreate('MarsProject').uniqueId,
        amount: monthlyPayment,
        memo: 'Pay back investment',
      );
    }
  }

  void _generateRentals() {
    final RentBuilding instance = RentBuilding();
    instance.fieldId.value = 0;
    instance.fieldName.value = 'AirBnB';
    instance.fieldAddress.value = 'One Washington DC';
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

  /// 4 years of GYM and Netflix
  void _generateSubscriptionsOnCheckingAccount() {
    final startDate = _today.subtract(Duration(days: (365.25 * _numberOFYearInThePast).toInt()));

    // Electricity
    generateTransactionsMontlyExpenses(
      account: _accountBankUSA,
      payeeName: 'ElectricCity',
      category: _categoryBillsElectricity,
      amount: -getAmount(40, 100), //
      yearMin: startDate.year,
      yearMax: _today.year,
      dayOfTheMonth: 11,
    );

    // Phone
    generateTransactionsMontlyExpenses(
      account: _accountBankUSA,
      payeeName: 'TMobile',
      category: _categoryBillsPhone,
      amount: -getAmount(40, 55), //
      yearMin: startDate.year,
      yearMax: _today.year,
      dayOfTheMonth: 12,
    );

    // Internet
    generateTransactionsMontlyExpenses(
      account: _accountBankUSA,
      payeeName: 'FastISP',
      category: _categoryBillsInternet,
      amount: -40,
      yearMin: startDate.year,
      yearMax: _today.year,
      dayOfTheMonth: 13,
    );

    // TV
    generateTransactionsMontlyExpenses(
      account: _accountBankUSA,
      payeeName: 'Comcast',
      category: _categoryBillsTV,
      amount: -80,
      yearMin: startDate.year,
      yearMax: _today.year,
      dayOfTheMonth: 13,
    );
  }

  /// 4 years of GYM and Netflix
  void _generateSubscriptionsOnCreditCard() {
    final dateForGym = _today.subtract(const Duration(days: 365 * 8));
    generateTransactionsMontlyExpenses(
      account: _accountCreditCardUSD,
      payeeName: 'Gold Gym',
      category: _categorySubsriptionsGym,
      amount: -50,
      yearMin: dateForGym.year,
      yearMax: dateForGym.add(const Duration(days: 365 * 4)).year,
      dayOfTheMonth: 23,
    );

    // 5 years of netflix
    final dateForNetflix = _today.subtract(const Duration(days: 365 * 5));
    generateTransactionsMontlyExpenses(
      account: _accountCreditCardUSD,
      payeeName: 'Netflix',
      category: _categorySubsriptionsStreaming,
      amount: -8.99,
      yearMin: dateForNetflix.year,
      yearMax: _today.year,
      dayOfTheMonth: 19,
    );
  }

  void _generateTransactionsSalary() {
    final dates = generateListOfDates(yearInThePast: _numberOFYearInThePast, howManyPerYear: 12, dayOfTheMonth: 5);
    _dateOfFirstBigJob = dates[dates.length ~/ 2];

    double yearlySalary = _startingYearlySalaryFirstJob;
    double increaseRatePerYear = _yearlyInflation / 100;

    int iterationYear = -1;

    Payee employer1 = Data().payees.getOrCreate('BurgerKing');
    Payee employer2 = Data().payees.getOrCreate('NASA');
    bool switchedJob = false;

    for (final date in dates) {
      if (iterationYear == -1) {
        iterationYear = date.year;
      } else {
        if (iterationYear != date.year) {
          // Increase yearly salary
          iterationYear = date.year;
          yearlySalary += yearlySalary * increaseRatePerYear;
        }
      }

      if (date.isBefore(_dateOfFirstBigJob)) {
        // Add Paycheck for BurgerKing
        _addTransactionAccountDatePayeeCategory(
          account: _accountBankUSA,
          date: date,
          payeeId: employer1.uniqueId,
          categoryId: _categorySalaryPaycheck.uniqueId,
          amount: yearlySalary / 12,
        );
      } else {
        if (switchedJob == false) {
          switchedJob = true;
          yearlySalary = _startingYearlySalarySecondJob;
          // one time signing bonus
          _addTransactionAccountDatePayeeCategory(
            account: _accountBankUSA,
            date: date,
            payeeId: employer2.uniqueId,
            categoryId: _categorySalaryBonus.uniqueId,
            amount: 20000,
          ).fieldMemo.value = 'Signing Bonnus';
        }
        // Add Paycheck for NASA
        _addTransactionAccountDatePayeeCategory(
          account: _accountBankUSA,
          date: date,
          payeeId: employer2.uniqueId,
          categoryId: _categorySalaryPaycheck.uniqueId,
          amount: yearlySalary / 12,
        );

        // special holiday bonus to all employees
        if (date.month == 12) {
          _addTransactionAccountDatePayeeCategory(
            account: _accountBankUSA,
            date: date.add(const Duration(days: 10)),
            payeeId: employer2.uniqueId,
            categoryId: _categorySalaryBonus.uniqueId,
            amount: 3500,
          ).fieldMemo.value = 'Holiday Bonnus';
        }
      }
    }
  }

  // Transfer 100 USD  Bank to CreditCard Account
  void _generateTransfersToCreditCardPayment() {
    double rollingBalance = 0.00;

    final list = _accountCreditCardUSD.getTransaction();

    list.sort((Transaction a, b) => sortByDate(a.fieldDateTime.value, b.fieldDateTime.value, true));
    int lastMonth = list.first.fieldDateTime.value!.month;

    for (final t in list) {
      if (t.fieldDateTime.value!.month != lastMonth && rollingBalance != 0) {
        _createTransferTransaction(
          accountSource: _accountBankUSA,
          accountDestination: _accountCreditCardUSD,
          date: getLastDayOfPreviousMonth(t.fieldDateTime.value!),
          amount: rollingBalance,
          memo: 'PAY CREDIT CARD',
        );
        rollingBalance = 0;
        lastMonth = t.fieldDateTime.value!.month;
      }
      rollingBalance += t.fieldAmount.value.toDouble();
    }
  }

  /// The demo data tries to demonstrat a person that had a rent for the first part of their jouney and a house on the second half
  void _generateTransfersToRentAndHomeLoan() {
    final payeeLandLord = Data().payees.getOrCreate('TheLandlord');
    final payeeForHomeLoan = Data().payees.getOrCreate('HomeLoanBank');
    // Iterate over the last 'n' years of loan paid each month
    final dates = generateListOfDates(yearInThePast: _numberOFYearInThePast, howManyPerYear: 12, dayOfTheMonth: 10);
    final midPointInTime = dates[dates.length ~/ 2];

    bool boughtHome = false;
    int numberOfRentPayement = 0;
    int numberOfMorgagePayement = 0;

    for (final date in dates) {
      if (date.isBefore(midPointInTime)) {
        _addTransactionAccountDatePayeeCategory(
          account: _accountBankUSA,
          date: date,
          payeeId: payeeLandLord.uniqueId,
          categoryId: Data().categories.getOrCreate('Bills:Rent', CategoryType.expense).uniqueId,
          amount: _monthlyRent,
        ).fieldMemo.value = 'Pay Rent #${++numberOfRentPayement}';
      } else {
        if (boughtHome == false) {
          boughtHome = true;
          _buyHome(payeeForHomeLoan, date.add(const Duration(days: 180)));
        }

        final transaction = _addTransactionAccountDatePayeeCategory(
          account: _accountBankUSA,
          date: date,
          payeeId: payeeForHomeLoan.uniqueId,
          categoryId: _categorySplit.uniqueId,
          amount: _monthlyHomeLoan,
          memo: 'Mortgage Payement #${++numberOfMorgagePayement}',
        );

        final splitMorgagePayementPrincipale = MoneySplit(
          id: -1,
          amount: _monthlyHomeLoan - 200,
          transactionId: transaction.uniqueId,
          categoryId: _categoryHomeLoanMorgagePrincipal.uniqueId,
          payeeId: payeeForHomeLoan.uniqueId,
          transferId: -1,
          memo: '',
          flags: 0,
          budgetBalanceDate: null,
        );
        Data().splits.appendNewMoneyObject(splitMorgagePayementPrincipale);

        final splitMorgagePayementInterest = MoneySplit(
          id: -1,
          amount: 200,
          transactionId: transaction.uniqueId,
          categoryId: _categoryHomeLoanMorgageInterest.uniqueId,
          payeeId: payeeForHomeLoan.uniqueId,
          transferId: -1,
          memo: '',
          flags: 0,
          budgetBalanceDate: null,
        );
        Data().splits.appendNewMoneyObject(splitMorgagePayementInterest);
      }
    }
  }
}

Transaction _addTransactionAccountDatePayeeCategory({
  required Account account,
  required DateTime date,
  int payeeId = -1,
  int categoryId = -1,
  double amount = 0.00,
  String memo = '',
}) {
  // generate an amount
  // Expenses should be a negative value and smaller range than Revenue;
  int maxValue = 2500;
  if (Data().categories.isCategoryAnExpense(categoryId)) {
    maxValue = -500;
  }

  if (amount == 0) {
    amount = getRandomAmount(maxValue);
  }

  final MyJson demoJson = <String, dynamic>{
    'Id': -1,
    'Account': account.fieldId.value,
    'Date': date,
    'Payee': payeeId,
    'Category': categoryId,
    'Amount': amount,
    'Memo': memo,
  };

  final Transaction t = Transaction.fromJSon(demoJson, 0);

  Data().transactions.appendNewMoneyObject(t, fireNotification: false);
  return t;
}

double getRandomAmount(final int maxValue) {
  final double amount = Random().nextDouble() * maxValue;
  return roundDouble(amount, 2);
}

List<DateTime> generateListOfDates({
  required int yearInThePast,
  DateTime? stopDate,
  required int howManyPerYear,
  required int dayOfTheMonth,
}) {
  List<DateTime> dates = [];

  final whenToStop = stopDate ?? DateTime.now();
  for (int i = yearInThePast * howManyPerYear; i >= 0; i--) {
    // Subtract the current month index from today's date
    DateTime date = DateTime(whenToStop.year, whenToStop.month - i, dayOfTheMonth);
    dates.add(date);
  }
  return dates;
}

List<DateTime> generateListOfDatesRandom({required int year, required int howManyPerMonths}) {
  List<DateTime> dates = [];

  final today = DateTime.now();
  for (int i = year * 12; i >= 0; i--) {
    // Subtract the current month index from today's date
    DateTime date = DateTime(today.year, today.month - i, 1);
    // Now we have a Year and Month
    // generate on rendom date of the month
    for (int event = 0; event < howManyPerMonths; event++) {
      int day = Random().nextInt(31);
      date = date.add(Duration(days: day));
      dates.add(date);
    }
  }
  return dates;
}

int getShiftedYearFromNow(int numberOfYearFromToday) {
  final today = DateTime.now();
  return DateTime(today.year + numberOfYearFromToday, today.month, today.day).year;
}

DateTime getDateShiftedByYears(int yearsToShift, int month, int day) {
  int yearShifted = getShiftedYearFromNow(yearsToShift);
  return DateTime(yearShifted, month, day);
}

Transaction _createTransferTransaction({
  required final Account accountSource,
  required final Account accountDestination,
  required final DateTime date,
  required final double amount,
  required final String memo,
}) {
  final Transaction source = _addTransactionAccountDatePayeeCategory(
    account: accountSource,
    date: date,
    amount: amount,
  );
  source.fieldMemo.value = memo;

  return Data().makeTransferLinkage(source, accountDestination);
}
