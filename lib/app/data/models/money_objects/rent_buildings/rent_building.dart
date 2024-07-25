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
import 'package:money/app/modules/home/sub_views/view_stocks/picker_security_type.dart';

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

    instance.id.value = row.getInt('Id', -1);
    instance.name.value = row.getString('Name');
    instance.address.value = row.getString('Address');
    instance.purchasedDate.value = row.getDate('PurchasedDate', defaultIfNotFound: DateTime.now());
    instance.purchasedPrice.value.setAmount(row.getDouble('PurchasedPrice'));
    instance.landValue.value.setAmount(row.getDouble('LandValue'));
    instance.estimatedValue.value.setAmount(row.getDouble('EstimatedValue'));
    instance.ownershipName1.value = row.getString('OwnershipName1');
    instance.ownershipName2.value = row.getString('OwnershipName2');
    instance.ownershipPercentage1.value = row.getDouble('OwnershipPercentage1');
    instance.ownershipPercentage2.value = row.getDouble('OwnershipPercentage2');

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

  /// Address
  // 2    Address                 nvarchar(255)  0                    0
  FieldString address = FieldString(
    name: 'Address',
    serializeName: 'Address',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).address.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).address.value,
  );

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

  /// Currency
  FieldString currency = FieldString(
    name: 'Currency',
    type: FieldType.widget,
    align: TextAlign.center,
    columnWidth: ColumnWidth.nano,
    getValueForReading: (final MoneyObject instance) => (instance as RentBuilding).getCurrencyOfAssociatedAccount(),
    getValueForDisplay: (final MoneyObject instance) => Currency.buildCurrencyWidget(
      (instance as RentBuilding).getCurrencyOfAssociatedAccount(),
    ),
  );

  DateRange dateRangeOfOperation = DateRange();

  /// EstimatedValue
  // 6    EstimatedValue          money
  FieldMoney estimatedValue = FieldMoney(
    name: 'EstimatedValue',
    serializeName: 'EstimatedValue',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).estimatedValue.value,
    getValueForSerialization: (final MoneyObject instance) =>
        (instance as RentBuilding).estimatedValue.value.toDouble(),
    setValue: (final MoneyObject instance, final dynamic value) =>
        (instance as RentBuilding).estimatedValue.setAmount(value),
  );

  /// Expenses
  FieldMoney expense = FieldMoney(
    name: 'Expenses',
    getValueForDisplay: (final MoneyObject instance) =>
        MoneyModel(amount: (instance as RentBuilding).lifeTimePnL.expenses),
  );

  /// ID
  // 0    Id                      INT            0                    1
  FieldId id = FieldId(
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).uniqueId,
  );

  /// LandValue
  // 5    LandValue          money
  FieldMoney landValue = FieldMoney(
    name: 'LandValue',
    serializeName: 'LandValue',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).landValue.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).landValue.value.toDouble(),
    setValue: (final MoneyObject instance, final dynamic value) =>
        (instance as RentBuilding).landValue.setAmount(value),
  );

  /// Expenses-Interest
  FieldMoney lifeTimeExpenseInterest = FieldMoney(
    name: '  Expense-Interest',
    getValueForDisplay: (final MoneyObject instance) => MoneyModel(
      amount: (instance as RentBuilding).lifeTimePnL.expenseInterest,
    ),
  );

  /// Expenses-Maintenance
  FieldMoney lifeTimeExpenseMaintenance = FieldMoney(
    name: '  Expense-Maintenance',
    getValueForDisplay: (final MoneyObject instance) => MoneyModel(
      amount: (instance as RentBuilding).lifeTimePnL.expenseMaintenance,
    ),
  );

  /// Expenses-Management
  FieldMoney lifeTimeExpenseManagement = FieldMoney(
    name: '  Expense-Management',
    getValueForDisplay: (final MoneyObject instance) => MoneyModel(
      amount: (instance as RentBuilding).lifeTimePnL.expenseManagement,
    ),
  );

  /// Expenses-Repair
  FieldMoney lifeTimeExpenseRepair = FieldMoney(
    name: '  Expense-Repair',
    getValueForDisplay: (final MoneyObject instance) => MoneyModel(
      amount: (instance as RentBuilding).lifeTimePnL.expenseRepairs,
    ),
  );

  /// Expenses-Taxes
  FieldMoney lifeTimeExpenseTaxes = FieldMoney(
    name: '  Expense-Taxes',
    getValueForDisplay: (final MoneyObject instance) =>
        MoneyModel(amount: (instance as RentBuilding).lifeTimePnL.expenseTaxes),
  );

  late RentalPnL lifeTimePnL;
  List<int> listOfCategoryIdsExpenses = <int>[];

  /// Name
  // 1    Name                    nvarchar(255)  1                    0
  FieldString name = FieldString(
    name: 'Name',
    serializeName: 'Name',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).name.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).name.value,
  );

  /// Note
  // 11    Note          money
  FieldString note = FieldString(
    name: 'Note',
    serializeName: 'Note',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).note.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).note.value,
  );

  /// OwnershipName1
  // 7    OwnershipName1          money
  FieldString ownershipName1 = FieldString(
    name: 'OwnershipName1',
    serializeName: 'OwnershipName1',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).ownershipName1.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).ownershipName1.value,
  );

  /// OwnershipName2
  // 8    OwnershipName2          money
  FieldString ownershipName2 = FieldString(
    name: 'OwnershipName2',
    serializeName: 'OwnershipName2',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).ownershipName2.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).ownershipName2.value,
  );

  /// OwnershipPercentage1
  // 9    OwnershipPercentage1          money
  FieldDouble ownershipPercentage1 = FieldDouble(
    name: 'OwnershipPercentage1',
    serializeName: 'OwnershipPercentage1',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).ownershipPercentage1.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).ownershipPercentage1.value,
  );

  /// OwnershipPercentage2
  // 10    OwnershipPercentage2          money
  FieldDouble ownershipPercentage2 = FieldDouble(
    name: 'OwnershipPercentage2',
    serializeName: 'OwnershipPercentage2',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).ownershipPercentage2.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).ownershipPercentage2.value,
  );

  Map<int, RentalPnL> pnlOverYears = {};

  /// Profit
  FieldMoney profit = FieldMoney(
    name: 'Profit',
    getValueForDisplay: (final MoneyObject instance) =>
        MoneyModel(amount: (instance as RentBuilding).lifeTimePnL.profit),
  );

  /// PurchasedDate
  // 3    PurchasedDate           datetime       0                    0
  FieldDate purchasedDate = FieldDate(
    name: 'Purchased Date',
    serializeName: 'PurchasedDate',
    getValueForDisplay: (final MoneyObject instance) => dateToIso8601OrDefaultString(
      (instance as RentBuilding).purchasedDate.value,
    ),
    getValueForSerialization: (final MoneyObject instance) => dateToIso8601OrDefaultString(
      (instance as RentBuilding).purchasedDate.value,
    ),
  );

  /// PurchasedPrice
  // 4    PurchasedPrice          money
  FieldMoney purchasedPrice = FieldMoney(
    name: 'Purchased Price',
    serializeName: 'PurchasedPrice',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).purchasedPrice.value,
    getValueForSerialization: (final MoneyObject instance) =>
        (instance as RentBuilding).purchasedPrice.value.toDouble(),
  );

  /// Revenue
  FieldMoney revenue = FieldMoney(
    name: 'Revenue',
    getValueForDisplay: (final MoneyObject instance) =>
        MoneyModel(amount: (instance as RentBuilding).lifeTimePnL.income),
  );

  FieldInt transactionsForExpenses = FieldInt(
    name: 'E#',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).transactionsForExpenses.value,
  );

  FieldInt transactionsForIncomes = FieldInt(
    name: 'I#',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).transactionsForIncomes.value,
  );

  List<RentUnit> units = <RentUnit>[];

  Account? account;

  @override
  Widget buildFieldsAsWidgetForSmallScreen() {
    return MyListItemAsCard(
      leftTopAsString: name.value,
      leftBottomAsString: address.value,
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
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  static final _fields = Fields<RentBuilding>();

  void associateAccountToBuilding() {
    final Transaction? firstTransactionForThisBuilding =
        Data().transactions.iterableList(includeDeleted: true).firstWhereOrNull(
              (t) => this.categoryForIncomeTreeIds.contains(t.categoryId.value),
            );
    if (firstTransactionForThisBuilding != null) {
      this.account = firstTransactionForThisBuilding.accountInstance;
    }
  }

  void cumulatePnL(Transaction t) {
    int transactionCategoryId = t.categoryId.value;

    if (this.isTransactionOrSplitAssociatedWithThisRental(t)) {
      int year = t.dateTime.value!.year;

      RentalPnL? pnl = pnlOverYears[year];
      if (pnl == null) {
        pnl = RentalPnL(
          date: t.dateTime.value!,
          currency: getCurrencyOfAssociatedAccount(),
        );

        if (this.ownershipName1.value.isNotEmpty) {
          String name = '${this.ownershipName1.value} (${ownershipPercentage1.value}%)';
          pnl.distributions[name] = this.ownershipPercentage1.value;
        }

        if (this.ownershipName2.value.isNotEmpty) {
          String name = '${this.ownershipName2.value} (${ownershipPercentage2.value}%)';
          pnl.distributions[name] = this.ownershipPercentage2.value;
        }

        pnlOverYears[year] = pnl;
      }

      if (t.isSplit) {
        for (final split in t.splits) {
          cumulatePnLValues(
            pnl,
            split.categoryId.value,
            split.amount.value.toDouble(),
          );
        }
      } else {
        cumulatePnLValues(
          pnl,
          transactionCategoryId,
          t.amount.value.toDouble(),
        );
      }
    }

    lifeTimePnL = getLifeTimePnL();
  }

  void cumulatePnLValues(RentalPnL pnl, int categoryId, double amount) {
    if (this.categoryForIncomeTreeIds.contains(categoryId)) {
      transactionsForIncomes.value++;
      pnl.income += amount;
    }

    if (this.categoryForInterestTreeIds.contains(categoryId)) {
      transactionsForExpenses.value++;
      pnl.expenseInterest += amount;
    }
    if (this.categoryForRepairsTreeIds.contains(categoryId)) {
      transactionsForExpenses.value++;
      pnl.expenseRepairs += amount;
    }
    if (this.categoryForMaintenanceTreeIds.contains(categoryId)) {
      transactionsForExpenses.value++;
      pnl.expenseMaintenance += amount;
    }
    if (this.categoryForManagementTreeIds.contains(categoryId)) {
      transactionsForExpenses.value++;
      pnl.expenseManagement += amount;
    }
    if (this.categoryForTaxesTreeIds.contains(categoryId)) {
      transactionsForExpenses.value++;
      pnl.expenseTaxes += amount;
    }
  }

  static Fields<RentBuilding> get fields {
    if (_fields.isEmpty) {
      final tmp = RentBuilding.fromJson({});
      _fields.setDefinitions([
        tmp.id,
        tmp.name,
        tmp.address,
        tmp.currency,
        tmp.purchasedDate,
        tmp.purchasedPrice,
        tmp.landValue,
        tmp.estimatedValue,
        tmp.ownershipName1,
        tmp.ownershipPercentage1,
        tmp.ownershipName2,
        tmp.ownershipPercentage2,
        tmp.categoryForIncome,
        tmp.categoryForInterest,
        tmp.categoryForManagement,
        tmp.categoryForMaintenance,
        tmp.categoryForRepairs,
        tmp.categoryForTaxes,
        tmp.transactionsForIncomes,
        tmp.revenue,
        tmp.transactionsForExpenses,
        tmp.expense,
        tmp.lifeTimeExpenseInterest,
        tmp.lifeTimeExpenseMaintenance,
        tmp.lifeTimeExpenseManagement,
        tmp.lifeTimeExpenseRepair,
        tmp.lifeTimeExpenseTaxes,
        tmp.profit,
      ]);
    }
    return _fields;
  }

  static Fields<RentBuilding> get fieldsForColumnView {
    final tmp = RentBuilding.fromJson({});
    return Fields<RentBuilding>()
      ..setDefinitions([
        tmp.name,
        tmp.address,
        tmp.currency,
        tmp.landValue,
        tmp.estimatedValue,
        tmp.transactionsForIncomes,
        tmp.revenue,
        tmp.transactionsForExpenses,
        tmp.expense,
        tmp.lifeTimeExpenseInterest,
        tmp.lifeTimeExpenseMaintenance,
        tmp.lifeTimeExpenseManagement,
        tmp.lifeTimeExpenseRepair,
        tmp.lifeTimeExpenseTaxes,
        tmp.profit,
      ]);
  }

  String getCategoryName(final int id) {
    return Data().categories.getNameFromId(id);
  }

  String getCurrencyOfAssociatedAccount() {
    if (this.account == null) {
      return Constants.defaultCurrency;
    } else {
      return account!.currency.value;
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
    final int transactionCategoryId = t.categoryId.value;
    if (t.isSplit) {
      for (final split in t.splits) {
        if (isTransactionAssociatedWithThisRental(split.categoryId.value)) {
          return true;
        }
      }
      return false;
    } else {
      return isTransactionAssociatedWithThisRental(transactionCategoryId);
    }
  }
}
