// ignore_for_file: unnecessary_this

import 'package:money/app/core/helpers/date_helper.dart';
import 'package:money/app/core/helpers/ranges.dart';
import 'package:money/app/core/widgets/money_widget.dart';

import 'package:money/app/data/models/money_objects/currencies/currency.dart';
import 'package:money/app/data/models/money_objects/rental_unit/rental_unit.dart';
import 'package:money/app/data/models/money_objects/transactions/transaction.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/modules/home/sub_views/adaptive_view/adaptive_list/list_item_card.dart';
import 'package:money/app/modules/home/sub_views/view_rentals/rental_pnl.dart';

import '../accounts/account.dart';

/*
    SQLite table definition

     0|Id|INT|0||1
     1|Name|nvarchar(255)|1||0
     2|Address|nvarchar(255)|0||0
     3|PurchasedDate|datetime|0||0
     4|PurchasedPrice|money|0||0
     5|LandValue|money|0||0
     6|EstimatedValue|money|0||0
     7|OwnershipName1|nvarchar(255)|0||0
     8|OwnershipName2|nvarchar(255)|0||0
     9|OwnershipPercentage1|money|0||0
    10|OwnershipPercentage2|money|0||0
    11|Note|nvarchar(255)|0||0
    12|CategoryForTaxes|INT|0||0
    13|CategoryForIncome|INT|0||0
    14|CategoryForInterest|INT|0||0
    15|CategoryForRepairs|INT|0||0
    16|CategoryForMaintenance|INT|0||0
    17|CategoryForManagement|INT|0||0
   */
class RentBuilding extends MoneyObject {
  RentBuilding();

  factory RentBuilding.fromJson(final MyJson row) {
    final RentBuilding instance = RentBuilding();

    instance.fieldId.value = row.getInt('Id', -1);
    instance.fieldName.value = row.getString('Name');
    instance.fieldAddress.value = row.getString('Address');
    instance.fieldPurchasedDate.value = row.getDate('PurchasedDate', defaultIfNotFound: DateTime.now());
    instance.fieldPurchasedPrice.value.setAmount(row.getDouble('PurchasedPrice'));
    instance.fieldLandValue.value.setAmount(row.getDouble('LandValue'));
    instance.fieldEstimatedValue.value.setAmount(row.getDouble('EstimatedValue'));
    instance.fieldOwnershipName1.value = row.getString('OwnershipName1');
    instance.fieldOwnershipName2.value = row.getString('OwnershipName2');
    instance.fieldOwnershipPercentage1.value = row.getDouble('OwnershipPercentage1');
    instance.fieldOwnershipPercentage2.value = row.getDouble('OwnershipPercentage2');

    instance.categoryForIncome.value = row.getInt('CategoryForIncome', -1);
    instance.categoryForIncomeTreeIds = Data().categories.getTreeIds(instance.categoryForIncome.value);

    instance.categoryForTaxes.value = row.getInt('CategoryForTaxes', -1);
    instance.categoryForTaxesTreeIds = Data().categories.getTreeIds(instance.categoryForTaxes.value);

    instance.categoryForInterest.value = row.getInt('CategoryForInterest', -1);
    instance.categoryForInterestTreeIds = Data().categories.getTreeIds(instance.categoryForInterest.value);

    instance.categoryForRepairs.value = row.getInt('CategoryForRepairs', -1);
    instance.categoryForRepairsTreeIds = Data().categories.getTreeIds(instance.categoryForRepairs.value);

    instance.categoryForMaintenance.value = row.getInt('CategoryForMaintenance', -1);
    instance.categoryForMaintenanceTreeIds = Data().categories.getTreeIds(instance.categoryForMaintenance.value);

    instance.categoryForManagement.value = row.getInt('CategoryForManagement', -1);
    instance.categoryForManagementTreeIds = Data().categories.getTreeIds(instance.categoryForManagement.value);

    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForTaxesTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForMaintenanceTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForManagementTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForRepairsTreeIds);
    instance.listOfCategoryIdsExpenses.addAll(instance.categoryForInterestTreeIds);

    instance.note.value = row.getString('Note');

    return instance;
  }

  /// CategoryForIncome
  // 13    CategoryForIncome          money
  FieldInt categoryForIncome = FieldInt(
    name: 'CategoryForIncome',
    serializeName: 'CategoryForIncome',
    getValueForDisplay: (final MoneyObject instance) =>
        (instance as RentBuilding).getCategoryName(instance.categoryForIncome.value),
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).categoryForIncome.value,
  );

  List<int> categoryForIncomeTreeIds = <int>[];

  /// CategoryForInterest
  // 14    CategoryForInterest          money
  FieldInt categoryForInterest = FieldInt(
    name: 'CategoryForInterest',
    serializeName: 'CategoryForInterest',
    getValueForDisplay: (final MoneyObject instance) =>
        (instance as RentBuilding).getCategoryName(instance.categoryForInterest.value),
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).categoryForInterest.value,
  );

  List<int> categoryForInterestTreeIds = <int>[];

  /// CategoryForMaintenance
  // 16    CategoryForMaintenance          money
  FieldInt categoryForMaintenance = FieldInt(
    name: 'CategoryForMaintenance',
    serializeName: 'CategoryForMaintenance',
    getValueForDisplay: (final MoneyObject instance) =>
        (instance as RentBuilding).getCategoryName(instance.categoryForMaintenance.value),
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).categoryForMaintenance.value,
  );

  List<int> categoryForMaintenanceTreeIds = <int>[];

  /// CategoryForManagement
  // 17    CategoryForManagement          money
  FieldInt categoryForManagement = FieldInt(
    name: 'CategoryForManagement',
    serializeName: 'CategoryForManagement',
    getValueForDisplay: (final MoneyObject instance) =>
        (instance as RentBuilding).getCategoryName(instance.categoryForManagement.value),
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).categoryForManagement.value,
  );

  List<int> categoryForManagementTreeIds = <int>[];

  /// CategoryForRepairs
  // 15    CategoryForRepairs          money
  FieldInt categoryForRepairs = FieldInt(
    name: 'CategoryForRepairs',
    serializeName: 'CategoryForRepairs',
    getValueForDisplay: (final MoneyObject instance) =>
        (instance as RentBuilding).getCategoryName(instance.categoryForRepairs.value),
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).categoryForRepairs.value,
  );

  List<int> categoryForRepairsTreeIds = <int>[];

  /// CategoryForTaxes
  // 12    CategoryForTaxes          money
  FieldInt categoryForTaxes = FieldInt(
    name: 'CategoryForTaxes',
    serializeName: 'CategoryForTaxes',
    getValueForDisplay: (final MoneyObject instance) =>
        (instance as RentBuilding).getCategoryName(instance.categoryForTaxes.value),
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).categoryForTaxes.value,
  );

  List<int> categoryForTaxesTreeIds = <int>[];
  DateRange dateRangeOfOperation = DateRange();

  /// Address
  // 2    Address                 nvarchar(255)  0                    0
  FieldString fieldAddress = FieldString(
    name: 'Address',
    serializeName: 'Address',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).fieldAddress.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).fieldAddress.value,
  );

  /// Currency
  FieldString fieldCurrency = FieldString(
    name: 'Currency',
    type: FieldType.widget,
    align: TextAlign.center,
    columnWidth: ColumnWidth.nano,
    getValueForReading: (final MoneyObject instance) => (instance as RentBuilding).getCurrencyOfAssociatedAccount(),
    getValueForDisplay: (final MoneyObject instance) => Currency.buildCurrencyWidget(
      (instance as RentBuilding).getCurrencyOfAssociatedAccount(),
    ),
  );

  /// EstimatedValue
  // 6    EstimatedValue          money
  FieldMoney fieldEstimatedValue = FieldMoney(
    name: 'EstimatedValue',
    serializeName: 'EstimatedValue',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).fieldEstimatedValue.value,
    getValueForSerialization: (final MoneyObject instance) =>
        (instance as RentBuilding).fieldEstimatedValue.value.toDouble(),
    setValue: (final MoneyObject instance, final dynamic value) =>
        (instance as RentBuilding).fieldEstimatedValue.setAmount(value),
  );

  /// Expenses
  FieldMoney fieldExpense = FieldMoney(
    name: 'Expenses',
    getValueForDisplay: (final MoneyObject instance) =>
        MoneyModel(amount: (instance as RentBuilding).lifeTimePnL.expenses),
  );

  /// ID
  // 0    Id                      INT            0                    1
  FieldId fieldId = FieldId(
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).uniqueId,
  );

  /// LandValue
  // 5    LandValue          money
  FieldMoney fieldLandValue = FieldMoney(
    name: 'LandValue',
    serializeName: 'LandValue',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).fieldLandValue.value,
    getValueForSerialization: (final MoneyObject instance) =>
        (instance as RentBuilding).fieldLandValue.value.toDouble(),
    setValue: (final MoneyObject instance, final dynamic value) =>
        (instance as RentBuilding).fieldLandValue.setAmount(value),
  );

  /// Expenses-Interest
  FieldMoney fieldLifeTimeExpenseInterest = FieldMoney(
    name: '  Expense-Interest',
    getValueForDisplay: (final MoneyObject instance) => MoneyModel(
      amount: (instance as RentBuilding).lifeTimePnL.expenseInterest,
    ),
  );

  /// Expenses-Maintenance
  FieldMoney fieldLifeTimeExpenseMaintenance = FieldMoney(
    name: '  Expense-Maintenance',
    getValueForDisplay: (final MoneyObject instance) => MoneyModel(
      amount: (instance as RentBuilding).lifeTimePnL.expenseMaintenance,
    ),
  );

  /// Expenses-Management
  FieldMoney fieldLifeTimeExpenseManagement = FieldMoney(
    name: '  Expense-Management',
    getValueForDisplay: (final MoneyObject instance) => MoneyModel(
      amount: (instance as RentBuilding).lifeTimePnL.expenseManagement,
    ),
  );

  /// Expenses-Repair
  FieldMoney fieldLifeTimeExpenseRepair = FieldMoney(
    name: '  Expense-Repair',
    getValueForDisplay: (final MoneyObject instance) => MoneyModel(
      amount: (instance as RentBuilding).lifeTimePnL.expenseRepairs,
    ),
  );

  /// Expenses-Taxes
  FieldMoney fieldLifeTimeExpenseTaxes = FieldMoney(
    name: '  Expense-Taxes',
    getValueForDisplay: (final MoneyObject instance) =>
        MoneyModel(amount: (instance as RentBuilding).lifeTimePnL.expenseTaxes),
  );

  /// Name
  // 1    Name                    nvarchar(255)  1                    0
  FieldString fieldName = FieldString(
    name: 'Name',
    serializeName: 'Name',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).fieldName.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).fieldName.value,
  );

  /// OwnershipName1
  // 7    OwnershipName1          money
  FieldString fieldOwnershipName1 = FieldString(
    name: 'OwnershipName1',
    serializeName: 'OwnershipName1',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).fieldOwnershipName1.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).fieldOwnershipName1.value,
  );

  /// OwnershipName2
  // 8    OwnershipName2          money
  FieldString fieldOwnershipName2 = FieldString(
    name: 'OwnershipName2',
    serializeName: 'OwnershipName2',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).fieldOwnershipName2.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).fieldOwnershipName2.value,
  );

  /// OwnershipPercentage1
  // 9    OwnershipPercentage1          money
  FieldDouble fieldOwnershipPercentage1 = FieldDouble(
    name: 'OwnershipPercentage1',
    serializeName: 'OwnershipPercentage1',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).fieldOwnershipPercentage1.value,
    getValueForSerialization: (final MoneyObject instance) =>
        (instance as RentBuilding).fieldOwnershipPercentage1.value,
  );

  /// OwnershipPercentage2
  // 10    OwnershipPercentage2          money
  FieldDouble fieldOwnershipPercentage2 = FieldDouble(
    name: 'OwnershipPercentage2',
    serializeName: 'OwnershipPercentage2',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).fieldOwnershipPercentage2.value,
    getValueForSerialization: (final MoneyObject instance) =>
        (instance as RentBuilding).fieldOwnershipPercentage2.value,
  );

  /// Profit
  FieldMoney fieldProfit = FieldMoney(
    name: 'Profit',
    getValueForDisplay: (final MoneyObject instance) =>
        MoneyModel(amount: (instance as RentBuilding).lifeTimePnL.profit),
  );

  /// PurchasedDate
  // 3    PurchasedDate           datetime       0                    0
  FieldDate fieldPurchasedDate = FieldDate(
    name: 'Purchased Date',
    serializeName: 'PurchasedDate',
    getValueForDisplay: (final MoneyObject instance) => dateToIso8601OrDefaultString(
      (instance as RentBuilding).fieldPurchasedDate.value,
    ),
    getValueForSerialization: (final MoneyObject instance) => dateToIso8601OrDefaultString(
      (instance as RentBuilding).fieldPurchasedDate.value,
    ),
  );

  /// PurchasedPrice
  // 4    PurchasedPrice          money
  FieldMoney fieldPurchasedPrice = FieldMoney(
    name: 'Purchased Price',
    serializeName: 'PurchasedPrice',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).fieldPurchasedPrice.value,
    getValueForSerialization: (final MoneyObject instance) =>
        (instance as RentBuilding).fieldPurchasedPrice.value.toDouble(),
  );

  /// Revenue
  FieldMoney fieldRevenue = FieldMoney(
    name: 'Revenue',
    getValueForDisplay: (final MoneyObject instance) =>
        MoneyModel(amount: (instance as RentBuilding).lifeTimePnL.income),
  );

  FieldInt fieldTransactionsForExpenses = FieldInt(
    name: 'E#',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).fieldTransactionsForExpenses.value,
  );

  FieldInt fieldTransactionsForIncomes = FieldInt(
    name: 'I#',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).fieldTransactionsForIncomes.value,
  );

  late RentalPnL lifeTimePnL;
  List<int> listOfCategoryIdsExpenses = <int>[];

  /// Note
  // 11    Note          money
  FieldString note = FieldString(
    name: 'Note',
    serializeName: 'Note',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).note.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).note.value,
  );

  Map<int, RentalPnL> pnlOverYears = {};
  List<RentUnit> units = <RentUnit>[];

  Account? account;

  @override
  Widget buildFieldsAsWidgetForSmallScreen() {
    return MyListItemAsCard(
      leftTopAsString: fieldName.value,
      leftBottomAsString: fieldAddress.value,
      rightTopAsWidget: MoneyWidget(
        amountModel: MoneyModel(amount: lifeTimePnL.profit),
        asTile: true,
      ),
    );
  }

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  @override
  int get uniqueId => fieldId.value;

  @override
  set uniqueId(value) => fieldId.value = value;

  static final _fields = Fields<RentBuilding>();

  void associateAccountToBuilding() {
    final Transaction? firstTransactionForThisBuilding =
        Data().transactions.iterableList(includeDeleted: true).firstWhereOrNull(
              (t) => this.categoryForIncomeTreeIds.contains(t.fieldCategoryId.value),
            );
    if (firstTransactionForThisBuilding != null) {
      this.account = firstTransactionForThisBuilding.accountInstance;
    }
  }

  void cumulatePnL(Transaction t) {
    int transactionCategoryId = t.fieldCategoryId.value;

    if (this.isTransactionOrSplitAssociatedWithThisRental(t)) {
      int year = t.fieldDateTime.value!.year;

      RentalPnL? pnl = pnlOverYears[year];
      if (pnl == null) {
        pnl = RentalPnL(
          date: t.fieldDateTime.value!,
          currency: getCurrencyOfAssociatedAccount(),
        );

        if (this.fieldOwnershipName1.value.isNotEmpty) {
          String name = '${this.fieldOwnershipName1.value} (${fieldOwnershipPercentage1.value}%)';
          pnl.distributions[name] = this.fieldOwnershipPercentage1.value;
        }

        if (this.fieldOwnershipName2.value.isNotEmpty) {
          String name = '${this.fieldOwnershipName2.value} (${fieldOwnershipPercentage2.value}%)';
          pnl.distributions[name] = this.fieldOwnershipPercentage2.value;
        }

        pnlOverYears[year] = pnl;
      }

      if (t.isSplit) {
        for (final split in t.splits) {
          cumulatePnLValues(
            pnl,
            split.fieldCategoryId.value,
            split.fieldAmount.value.toDouble(),
          );
        }
      } else {
        cumulatePnLValues(
          pnl,
          transactionCategoryId,
          t.fieldAmount.value.toDouble(),
        );
      }
    }

    lifeTimePnL = getLifeTimePnL();
  }

  void cumulatePnLValues(RentalPnL pnl, int categoryId, double amount) {
    if (this.categoryForIncomeTreeIds.contains(categoryId)) {
      fieldTransactionsForIncomes.value++;
      pnl.income += amount;
    }

    if (this.categoryForInterestTreeIds.contains(categoryId)) {
      fieldTransactionsForExpenses.value++;
      pnl.expenseInterest += amount;
    }
    if (this.categoryForRepairsTreeIds.contains(categoryId)) {
      fieldTransactionsForExpenses.value++;
      pnl.expenseRepairs += amount;
    }
    if (this.categoryForMaintenanceTreeIds.contains(categoryId)) {
      fieldTransactionsForExpenses.value++;
      pnl.expenseMaintenance += amount;
    }
    if (this.categoryForManagementTreeIds.contains(categoryId)) {
      fieldTransactionsForExpenses.value++;
      pnl.expenseManagement += amount;
    }
    if (this.categoryForTaxesTreeIds.contains(categoryId)) {
      fieldTransactionsForExpenses.value++;
      pnl.expenseTaxes += amount;
    }
  }

  static Fields<RentBuilding> get fields {
    if (_fields.isEmpty) {
      final tmp = RentBuilding.fromJson({});
      _fields.setDefinitions([
        tmp.fieldId,
        tmp.fieldName,
        tmp.fieldAddress,
        tmp.fieldCurrency,
        tmp.fieldPurchasedDate,
        tmp.fieldPurchasedPrice,
        tmp.fieldLandValue,
        tmp.fieldEstimatedValue,
        tmp.fieldOwnershipName1,
        tmp.fieldOwnershipPercentage1,
        tmp.fieldOwnershipName2,
        tmp.fieldOwnershipPercentage2,
        tmp.categoryForIncome,
        tmp.categoryForInterest,
        tmp.categoryForManagement,
        tmp.categoryForMaintenance,
        tmp.categoryForRepairs,
        tmp.categoryForTaxes,
        tmp.fieldTransactionsForIncomes,
        tmp.fieldRevenue,
        tmp.fieldTransactionsForExpenses,
        tmp.fieldExpense,
        tmp.fieldLifeTimeExpenseInterest,
        tmp.fieldLifeTimeExpenseMaintenance,
        tmp.fieldLifeTimeExpenseManagement,
        tmp.fieldLifeTimeExpenseRepair,
        tmp.fieldLifeTimeExpenseTaxes,
        tmp.fieldProfit,
      ]);
    }
    return _fields;
  }

  static Fields<RentBuilding> get fieldsForColumnView {
    final tmp = RentBuilding.fromJson({});
    return Fields<RentBuilding>()
      ..setDefinitions([
        tmp.fieldName,
        tmp.fieldAddress,
        tmp.fieldCurrency,
        tmp.fieldLandValue,
        tmp.fieldEstimatedValue,
        tmp.fieldTransactionsForIncomes,
        tmp.fieldRevenue,
        tmp.fieldTransactionsForExpenses,
        tmp.fieldExpense,
        tmp.fieldLifeTimeExpenseInterest,
        tmp.fieldLifeTimeExpenseMaintenance,
        tmp.fieldLifeTimeExpenseManagement,
        tmp.fieldLifeTimeExpenseRepair,
        tmp.fieldLifeTimeExpenseTaxes,
        tmp.fieldProfit,
      ]);
  }

  String getCategoryName(final int id) {
    return Data().categories.getNameFromId(id);
  }

  String getCurrencyOfAssociatedAccount() {
    if (this.account == null) {
      return Constants.defaultCurrency;
    } else {
      return account!.fieldCurrency.value;
    }
  }

  RentalPnL getLifeTimePnL() {
    RentalPnL lifeTimePnL = RentalPnL(date: DateTime.now());
    pnlOverYears.forEach((year, pnl) {
      dateRangeOfOperation.inflate(pnl.date);
      lifeTimePnL.income += pnl.income;
      lifeTimePnL.expenseInterest += pnl.expenseInterest;
      lifeTimePnL.expenseManagement += pnl.expenseManagement;
      lifeTimePnL.expenseMaintenance += pnl.expenseMaintenance;
      lifeTimePnL.expenseRepairs += pnl.expenseRepairs;
      lifeTimePnL.expenseTaxes += pnl.expenseTaxes;
      lifeTimePnL.currency = pnl.currency;
      lifeTimePnL.distributions = pnl.distributions;
    });
    return lifeTimePnL;
  }

  bool isTransactionAssociatedWithThisRental(int transactionCategoryId) {
    return this.categoryForIncomeTreeIds.contains(transactionCategoryId) ||
        this.categoryForInterestTreeIds.contains(transactionCategoryId) ||
        this.categoryForRepairsTreeIds.contains(transactionCategoryId) ||
        this.categoryForMaintenanceTreeIds.contains(transactionCategoryId) ||
        this.categoryForManagementTreeIds.contains(transactionCategoryId) ||
        this.categoryForTaxesTreeIds.contains(transactionCategoryId);
  }

  bool isTransactionOrSplitAssociatedWithThisRental(Transaction t) {
    final int transactionCategoryId = t.fieldCategoryId.value;
    if (t.isSplit) {
      for (final split in t.splits) {
        if (isTransactionAssociatedWithThisRental(split.fieldCategoryId.value)) {
          return true;
        }
      }
      return false;
    } else {
      return isTransactionAssociatedWithThisRental(transactionCategoryId);
    }
  }
}
