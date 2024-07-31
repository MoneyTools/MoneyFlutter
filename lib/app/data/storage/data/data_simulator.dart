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
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';

class DataSimulator {
  int idAccountForLoan = 9;
  int idStockApple = 0;
  int idStockFord = 1;

  late final Account _accountBankOfAmerica;
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
  late final Category _categorySalaryBonus;
  late final Category _categorySalaryPaycheck;
  late final Category _categoryTransport;
  final double _monthlyMortgage = -2000;
  final double _monthlyRent = -600;
  final int _numberOFYearInThePast = 20;
  final double _startingYearlySalaryFirstJob = 15000.00;
  final double _startingYearlySalarySecondJob = 50000.00;
  final double _yearlyInflation = 3.00;

  late DateTime _dateOfFirstBigJob;

  Account addNewAccount(int id, name, accountId, type, currency) {
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

  static Transaction addTransactionAccountDatePayeeCategory({
    required Account account,
    required DateTime date,
    int payeeId = -1,
    int categoryId = -1,
    double amount = 0.00,
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
    };

    final Transaction t = Transaction.fromJSon(demoJson, 0);

    Data().transactions.appendNewMoneyObject(t, fireNotification: false);
    return t;
  }

  static void createTransferTransaction({
    required final Account accountSource,
    required final Account accountDestination,
    required final DateTime dateOfPayment,
    required final double paymentAmount,
    required final String memo,
  }) {
    final Transaction source = addTransactionAccountDatePayeeCategory(
      account: accountSource,
      date: dateOfPayment,
      amount: paymentAmount,
    );
    source.fieldMemo.value = memo;

    Data().makeTransferLinkage(source, accountDestination);
  }

  void generateAccounts() {
    _accountBankOfAmerica = addNewAccount(
      -1,
      'Bank Of America',
      '0001',
      AccountType.checking.index,
      'USD',
    );

    _accountCreditCardUSD = addNewAccount(
      -1,
      'VisaCard',
      '0002',
      AccountType.credit.index,
      'USD',
    );

    _accountForInvestments = addNewAccount(
      -1,
      'Fidelity',
      '0003',
      AccountType.investment.index,
      'USD',
    );
    _accountStartupLoan = addNewAccount(
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
        Data().categories.getOrCreate('Loans:Interest:Startup', CategoryType.expense).uniqueId;
    _accountStartupLoan.fieldCategoryIdForInterest.value =
        Data().categories.getOrCreate('Loans:Principal:Startup', CategoryType.expense).uniqueId;
  }

  void generateAliases() {
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

  void generateCategories() {
    // Expenses
    _categoryBills = Category(
      id: -1,
      name: 'Bills',
      description: '',
      type: CategoryType.expense,
      color: '#FFFF0000',
    );
    Data().categories.appendNewMoneyObject(_categoryBills);

    _categoryBillsElectricity = Category(
      id: -1,
      parentId: _categoryBills.uniqueId,
      name: 'Bills:Electricity',
      description: '',
      type: CategoryType.expense,
    );
    Data().categories.appendNewMoneyObject(_categoryBillsElectricity);

    _categoryBillsPhone = Category(
      id: -1,
      parentId: _categoryBills.uniqueId,
      name: 'Bills:Phone',
      description: '',
      type: CategoryType.expense,
    );
    Data().categories.appendNewMoneyObject(_categoryBillsPhone);

    _categoryBillsTV = Category(
      id: -1,
      parentId: _categoryBills.uniqueId,
      name: 'Bills:TV',
      description: '',
      type: CategoryType.expense,
    );
    Data().categories.appendNewMoneyObject(_categoryBillsTV);

    _categoryBillsInternet = Category(
      id: -1,
      parentId: _categoryBills.uniqueId,
      name: 'Bills:Internet',
      description: '',
      type: CategoryType.expense,
    );
    Data().categories.appendNewMoneyObject(_categoryBillsInternet);

    _categoryTransport = Category(
      id: -1,
      name: 'Transportaion',
      description: '',
      type: CategoryType.expense,
      color: '#FFFF88FF',
    );
    Data().categories.appendNewMoneyObject(_categoryTransport);

    _categoryFood = Category(
      id: -1,
      name: 'Food',
      description: '',
      type: CategoryType.expense,
      color: '#FFFF22FF',
    );
    Data().categories.appendNewMoneyObject(_categoryFood);

    _categoryFoodGrocery = Category(
      id: -1,
      parentId: _categoryFood.uniqueId,
      name: 'Food:Grocery',
      description: '',
      type: CategoryType.expense,
    );
    Data().categories.appendNewMoneyObject(_categoryFoodGrocery);

    _categoryFoodRestaurant = Category(
      id: -1,
      parentId: _categoryFood.uniqueId,
      name: 'Food:Restaurant',
      description: '',
      type: CategoryType.expense,
    );
    Data().categories.appendNewMoneyObject(_categoryFoodRestaurant);

    // Salary
    Data().categories.appendNewMoneyObject(
          Category(
            id: -1,
            name: 'Salary',
            description: 'Main income',
            type: CategoryType.income,
            color: '#FF00FF00',
          ),
        );

    _categorySalaryPaycheck = Category(
      id: -1,
      parentId: Data().categories.getByName('Salary')!.uniqueId,
      name: 'Salary:Paycheck',
      description: '',
      type: CategoryType.income,
    );

    Data().categories.appendNewMoneyObject(_categorySalaryPaycheck);

    _categorySalaryBonus = Category(
      id: -1,
      parentId: Data().categories.getByName('Salary')!.uniqueId,
      name: 'Salary:Bonus',
      description: '',
      type: CategoryType.income,
    );

    Data().categories.appendNewMoneyObject(_categorySalaryBonus);

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

  void generateCurrencies() {
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

  void generateData() {
    final today = DateTime.now();

    Data().clearExistingData();
    generateCurrencies();
    generateAccounts();
    generateAliases();
    generateCategories();
    generateInvestments();
    generateLoans();
    generateRentals();
    generateTransactionsSalary();
    generateTransfersToRentAndMortgage();

    generateSubscriptionsOnCheckingAccount(today);
    generateSubscriptionsOnCreditCard(today);

    // generateTransactionsForCreditCard();
    generateTransfersToCreditCardPayment();
  }

  void generateInvestments() {
    generateStocks();

    // Buy Apple
    _addInvestment(_accountForInvestments, '2015-06-20', idStockApple, InvestmentType.buy, 100, 199.99);

    // Buy Ford
    _addInvestment(_accountForInvestments, '2012-07-26', idStockFord, InvestmentType.buy, 1000, 8.86);

    // Sell Ford
    _addInvestment(_accountForInvestments, '2013-01-15', idStockFord, InvestmentType.sell, 1000, 14.14);
  }

  void generateLoans() {
    final dates = generateListOfDates(yearInThePast: 5, howManyPerYear: 12, dayOfTheMonth: 9);

    for (final date in dates) {
      Data().loanPayments.appendNewMoneyObject(
            LoanPayment(
              id: -1,
              accountId: _accountStartupLoan.uniqueId,
              date: date,
              principal: 100,
              interest: 10,
              memo: '',
            ),
          );
    }
  }

  // ignore: unused_element
  List<DateTime> generateRandomDates(int count) {
    final now = DateTime.now();
    final tenYearsAgo = now.subtract(
      Duration(days: 365 * _numberOFYearInThePast),
    ); // Adjust for leap years if needed

    final random = Random();
    final dates = List<DateTime>.generate(count, (index) {
      final randomDaysSinceTenYearsAgo = random.nextInt(365 * _numberOFYearInThePast);
      return tenYearsAgo.add(Duration(days: randomDaysSinceTenYearsAgo));
    });
    return dates;
  }

  void generateRentals() {
    final RentBuilding instance = RentBuilding();
    instance.fieldId.value = 0;
    instance.fieldName.value = 'AirBnB';
    instance.fieldAddress.value = 'One Washington DC';
    Data().rentBuildings.appendMoneyObject(instance);
  }

  void generateStocks() {
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
  void generateSubscriptionsOnCheckingAccount(DateTime today) {
    final startDate = today.subtract(Duration(days: (365.25 * _numberOFYearInThePast).toInt()));

    // Electricity
    generateTransactionsMontlyExpenses(
      account: _accountBankOfAmerica,
      payeeName: 'ElectricCity',
      category: _categoryBillsElectricity,
      amount: -getAmount(40, 100), //
      yearMin: startDate.year,
      yearMax: today.year,
      dayOfTheMonth: 11,
    );

    // Phone
    generateTransactionsMontlyExpenses(
      account: _accountBankOfAmerica,
      payeeName: 'TMobile',
      category: _categoryBillsPhone,
      amount: -getAmount(40, 55), //
      yearMin: startDate.year,
      yearMax: today.year,
      dayOfTheMonth: 12,
    );

    // Internet
    generateTransactionsMontlyExpenses(
      account: _accountBankOfAmerica,
      payeeName: 'FastISP',
      category: _categoryBillsInternet,
      amount: -40,
      yearMin: startDate.year,
      yearMax: today.year,
      dayOfTheMonth: 13,
    );

    // TV
    generateTransactionsMontlyExpenses(
      account: _accountBankOfAmerica,
      payeeName: 'Comcast',
      category: _categoryBillsTV,
      amount: -80,
      yearMin: startDate.year,
      yearMax: today.year,
      dayOfTheMonth: 13,
    );
  }

  /// 4 years of GYM and Netflix
  void generateSubscriptionsOnCreditCard(DateTime today) {
    final dateForGym = DateTime.now().subtract(const Duration(days: 365 * 8));
    generateTransactionsMontlyExpenses(
      account: _accountCreditCardUSD,
      payeeName: 'Gold Gym',
      category: Data().categories.getOrCreate('Gym', CategoryType.expense),
      amount: -50,
      yearMin: dateForGym.year,
      yearMax: dateForGym.add(const Duration(days: 365 * 4)).year,
      dayOfTheMonth: 23,
    );

    // 5 years of netflix
    final dateForNetflix = DateTime.now().subtract(const Duration(days: 365 * 5));
    generateTransactionsMontlyExpenses(
      account: _accountCreditCardUSD,
      payeeName: 'Netflix',
      category: Data().categories.getOrCreate('Streaming Subscription', CategoryType.expense),
      amount: -8.99,
      yearMin: dateForNetflix.year,
      yearMax: today.year,
      dayOfTheMonth: 19,
    );
  }

  void generateTransactionsForCreditCard() {
    final dates = generateListOfDatesRandom(year: _numberOFYearInThePast, howManyPerMonths: 4);

    for (final date in dates) {
      final selectedCategory = [
        [
          _categoryTransport,
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

      final Transaction source = addTransactionAccountDatePayeeCategory(
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
        addTransactionAccountDatePayeeCategory(
          account: account,
          date: DateTime(year, month, dayOfTheMonth),
          payeeId: payee.uniqueId,
          categoryId: category.uniqueId,
          amount: amount,
        );
      }
    }
  }

  void generateTransactionsSalary() {
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
        addTransactionAccountDatePayeeCategory(
          account: _accountBankOfAmerica,
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
          addTransactionAccountDatePayeeCategory(
            account: _accountBankOfAmerica,
            date: date,
            payeeId: employer2.uniqueId,
            categoryId: _categorySalaryBonus.uniqueId,
            amount: 20000,
          ).fieldMemo.value = 'Singing Bonnus';
        }
        // Add Paycheck for NASA
        addTransactionAccountDatePayeeCategory(
          account: _accountBankOfAmerica,
          date: date,
          payeeId: employer2.uniqueId,
          categoryId: _categorySalaryPaycheck.uniqueId,
          amount: yearlySalary / 12,
        );

        // special holiday bonus to all employees
        if (date.month == 12) {
          addTransactionAccountDatePayeeCategory(
            account: _accountBankOfAmerica,
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
  void generateTransfersToCreditCardPayment() {
    double rollingBalance = 0.00;

    final list = _accountCreditCardUSD.getTransaction();

    list.sort((Transaction a, b) => sortByDate(a.fieldDateTime.value, b.fieldDateTime.value, true));
    int lastMonth = list.first.fieldDateTime.value!.month;

    for (final t in list) {
      if (t.fieldDateTime.value!.month != lastMonth && rollingBalance != 0) {
        createTransferTransaction(
          accountSource: _accountBankOfAmerica,
          accountDestination: _accountCreditCardUSD,
          dateOfPayment: getLastDayOfPreviousMonth(t.fieldDateTime.value!),
          paymentAmount: rollingBalance,
          memo: 'PAY CREDIT CARD',
        );
        rollingBalance = 0;
        lastMonth = t.fieldDateTime.value!.month;
      }
      rollingBalance += t.fieldAmount.value.toDouble();
    }
  }

  /// The demo data tries to demonstrat a person that had a rent for the first part of their jouney and a house on the second half
  void generateTransfersToRentAndMortgage() {
    final payeeLandLord = Data().payees.getOrCreate('TheLandlord');
    final payeeForMortgage = Data().payees.getOrCreate('HomeLoanBank');
    // Iterate over the last 'n' years of loan paid each month
    final dates = generateListOfDates(yearInThePast: _numberOFYearInThePast, howManyPerYear: 12, dayOfTheMonth: 10);
    final midPointInTime = dates[dates.length ~/ 2];

    for (final date in dates) {
      if (date.isBefore(midPointInTime)) {
        addTransactionAccountDatePayeeCategory(
          account: _accountBankOfAmerica,
          date: date,
          payeeId: payeeLandLord.uniqueId,
          categoryId: Data().categories.getOrCreate('Rent', CategoryType.expense).uniqueId,
          amount: _monthlyRent,
        ).fieldMemo.value = 'Pay Rent';
      } else {
        final Transaction source = addTransactionAccountDatePayeeCategory(
          account: _accountBankOfAmerica,
          date: date,
          payeeId: payeeForMortgage.uniqueId,
          categoryId: Data().categories.getByName('Mortgage')!.uniqueId,
          amount: _monthlyMortgage,
        );
        source.fieldMemo.value = 'PAY LOAN';
        // Data().makeTransferLinkage(source, accountDestination!);
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
    final category = Data().categories.getOrCreate('Trades', CategoryType.investment);

    var t = addTransactionAccountDatePayeeCategory(
      account: account,
      date: date,
      amount: transactionAmount,
      payeeId: payee.uniqueId,
      categoryId: category.uniqueId,
    );
    t.fieldMemo.value =
        'You $action ${formatDoubleTrimZeros(quantity)} shares of "${stock!.fieldName.value} (${stock.fieldSymbol.value})"';

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

int getYearInThePast(int numberOfYearFromToday) {
  final today = DateTime.now();
  return DateTime(today.year - numberOfYearFromToday, today.month, today.day).year;
}
