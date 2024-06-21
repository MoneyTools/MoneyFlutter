// ignore_for_file: unnecessary_this

import 'package:money/helpers/date_helper.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/date_range.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/money_objects.dart';
import 'package:money/models/money_objects/rental_unit/rental_unit.dart';
import 'package:money/models/money_objects/transactions/transaction.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/views/view_rentals/rental_pnl.dart';
import 'package:money/views/adaptive_view/adaptive_list/list_item_card.dart';
import 'package:money/app/core/widgets/money_widget.dart';

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
  static final _fields = Fields<RentBuilding>();

  static get fields {
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

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  /// ID
  // 0    Id                      INT            0                    1
  FieldId id = FieldId(
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).uniqueId,
  );

  /// Name
  // 1    Name                    nvarchar(255)  1                    0
  FieldString name = FieldString(
    importance: 1,
    name: 'Name',
    serializeName: 'Name',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).name.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).name.value,
  );

  /// Address
  // 2    Address                 nvarchar(255)  0                    0
  FieldString address = FieldString(
    importance: 2,
    name: 'Address',
    serializeName: 'Address',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).address.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).address.value,
  );

  /// PurchasedDate
  // 3    PurchasedDate           datetime       0                    0
  FieldDate purchasedDate = FieldDate(
    importance: 2,
    name: 'Purchased Date',
    serializeName: 'PurchasedDate',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) =>
        dateToIso8601OrDefaultString((instance as RentBuilding).purchasedDate.value),
    getValueForSerialization: (final MoneyObject instance) =>
        dateToIso8601OrDefaultString((instance as RentBuilding).purchasedDate.value),
  );

  /// PurchasedPrice
  // 4    PurchasedPrice          money
  FieldMoney purchasedPrice = FieldMoney(
    importance: 2,
    name: 'Purchased Price',
    serializeName: 'PurchasedPrice',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).purchasedPrice.value,
    getValueForSerialization: (final MoneyObject instance) =>
        (instance as RentBuilding).purchasedPrice.value.toDouble(),
  );

  /// LandValue
  // 5    LandValue          money
  FieldMoney landValue = FieldMoney(
    importance: 2,
    name: 'LandValue',
    serializeName: 'LandValue',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).landValue.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).landValue.value.toDouble(),
    setValue: (final MoneyObject instance, final dynamic value) =>
        (instance as RentBuilding).landValue.setAmount(value),
  );

  /// EstimatedValue
  // 6    EstimatedValue          money
  FieldMoney estimatedValue = FieldMoney(
    importance: 2,
    name: 'EstimatedValue',
    serializeName: 'EstimatedValue',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).estimatedValue.value,
    getValueForSerialization: (final MoneyObject instance) =>
        (instance as RentBuilding).estimatedValue.value.toDouble(),
    setValue: (final MoneyObject instance, final dynamic value) =>
        (instance as RentBuilding).estimatedValue.setAmount(value),
  );

  /// OwnershipName1
  // 7    OwnershipName1          money
  FieldString ownershipName1 = FieldString(
    importance: 2,
    name: 'OwnershipName1',
    serializeName: 'OwnershipName1',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).ownershipName1.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).ownershipName1.value,
  );

  /// OwnershipName2
  // 8    OwnershipName2          money
  FieldString ownershipName2 = FieldString(
    importance: 2,
    name: 'OwnershipName2',
    serializeName: 'OwnershipName2',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).ownershipName2.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).ownershipName2.value,
  );

  /// OwnershipPercentage1
  // 9    OwnershipPercentage1          money
  FieldDouble ownershipPercentage1 = FieldDouble(
    importance: 2,
    name: 'OwnershipPercentage1',
    serializeName: 'OwnershipPercentage1',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).ownershipPercentage1.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).ownershipPercentage1.value,
  );

  /// OwnershipPercentage2
  // 10    OwnershipPercentage2          money
  FieldDouble ownershipPercentage2 = FieldDouble(
    importance: 2,
    name: 'OwnershipPercentage2',
    serializeName: 'OwnershipPercentage2',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).ownershipPercentage2.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).ownershipPercentage2.value,
  );

  /// Note
  // 11    Note          money
  FieldString note = FieldString(
    importance: 2,
    name: 'Note',
    serializeName: 'Note',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).note.value,
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).note.value,
  );

  /// CategoryForTaxes
  // 12    CategoryForTaxes          money
  FieldInt categoryForTaxes = FieldInt(
    importance: 2,
    name: 'CategoryForTaxes',
    serializeName: 'CategoryForTaxes',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) =>
        (instance as RentBuilding).getCategoryName(instance.categoryForTaxes.value),
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).categoryForTaxes.value,
  );

  /// CategoryForIncome
  // 13    CategoryForIncome          money
  FieldInt categoryForIncome = FieldInt(
    importance: 2,
    name: 'CategoryForIncome',
    serializeName: 'CategoryForIncome',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) =>
        (instance as RentBuilding).getCategoryName(instance.categoryForIncome.value),
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).categoryForIncome.value,
  );

  /// CategoryForInterest
  // 14    CategoryForInterest          money
  FieldInt categoryForInterest = FieldInt(
    importance: 2,
    name: 'CategoryForInterest',
    serializeName: 'CategoryForInterest',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) =>
        (instance as RentBuilding).getCategoryName(instance.categoryForInterest.value),
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).categoryForInterest.value,
  );

  /// CategoryForRepairs
  // 15    CategoryForRepairs          money
  FieldInt categoryForRepairs = FieldInt(
    importance: 2,
    name: 'CategoryForRepairs',
    serializeName: 'CategoryForRepairs',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) =>
        (instance as RentBuilding).getCategoryName(instance.categoryForRepairs.value),
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).categoryForRepairs.value,
  );

  /// CategoryForMaintenance
  // 16    CategoryForMaintenance          money
  FieldInt categoryForMaintenance = FieldInt(
    importance: 2,
    name: 'CategoryForMaintenance',
    serializeName: 'CategoryForMaintenance',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) =>
        (instance as RentBuilding).getCategoryName(instance.categoryForMaintenance.value),
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).categoryForMaintenance.value,
  );

  /// CategoryForManagement
  // 17    CategoryForManagement          money
  FieldInt categoryForManagement = FieldInt(
    importance: 2,
    name: 'CategoryForManagement',
    serializeName: 'CategoryForManagement',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) =>
        (instance as RentBuilding).getCategoryName(instance.categoryForManagement.value),
    getValueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).categoryForManagement.value,
  );

  String getCategoryName(final int id) {
    return Data().categories.getNameFromId(id);
  }

  FieldQuantity transactionsForIncomes = FieldQuantity(
    name: 'I#',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).transactionsForIncomes.value,
  );

  FieldQuantity transactionsForExpenses = FieldQuantity(
    name: 'E#',
    getValueForDisplay: (final MoneyObject instance) => (instance as RentBuilding).transactionsForExpenses.value,
  );

  /// Currency
  Field<String> currency = Field<String>(
    importance: 5,
    name: 'Currency',
    type: FieldType.widget,
    align: TextAlign.center,
    columnWidth: ColumnWidth.nano,
    defaultValue: '',
    getValueForDisplay: (final MoneyObject instance) =>
        Currency.buildCurrencyWidget((instance as RentBuilding).getCurrencyOfAssociatedAccount()),
  );

  String getCurrencyOfAssociatedAccount() {
    if (this.account == null) {
      return Constants.defaultCurrency;
    } else {
      return account!.currency.value;
    }
  }

  /// Revenue
  FieldMoney revenue = FieldMoney(
    importance: 20,
    name: 'Revenue',
    getValueForDisplay: (final MoneyObject instance) =>
        MoneyModel(amount: (instance as RentBuilding).lifeTimePnL.income),
  );

  /// Expenses
  FieldMoney expense = FieldMoney(
    importance: 21,
    name: 'Expenses',
    getValueForDisplay: (final MoneyObject instance) =>
        MoneyModel(amount: (instance as RentBuilding).lifeTimePnL.expenses),
  );

  /// Expenses-Interest
  FieldMoney lifeTimeExpenseInterest = FieldMoney(
    importance: 21,
    name: '  Expense-Interest',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) =>
        MoneyModel(amount: (instance as RentBuilding).lifeTimePnL.expenseInterest),
  );

  /// Expenses-Maintenance
  FieldMoney lifeTimeExpenseMaintenance = FieldMoney(
    importance: 21,
    name: '  Expense-Maintenance',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) =>
        MoneyModel(amount: (instance as RentBuilding).lifeTimePnL.expenseMaintenance),
  );

  /// Expenses-Management
  FieldMoney lifeTimeExpenseManagement = FieldMoney(
    importance: 21,
    name: '  Expense-Management',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) =>
        MoneyModel(amount: (instance as RentBuilding).lifeTimePnL.expenseManagement),
  );

  /// Expenses-Repair
  FieldMoney lifeTimeExpenseRepair = FieldMoney(
    importance: 21,
    name: '  Expense-Repair',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) =>
        MoneyModel(amount: (instance as RentBuilding).lifeTimePnL.expenseRepairs),
  );

  /// Expenses-Taxes
  FieldMoney lifeTimeExpenseTaxes = FieldMoney(
    importance: 21,
    name: '  Expense-Taxes',
    useAsColumn: false,
    getValueForDisplay: (final MoneyObject instance) =>
        MoneyModel(amount: (instance as RentBuilding).lifeTimePnL.expenseTaxes),
  );

  /// Profit
  FieldMoney profit = FieldMoney(
    importance: 22,
    name: 'Profit',
    getValueForDisplay: (final MoneyObject instance) =>
        MoneyModel(amount: (instance as RentBuilding).lifeTimePnL.profit),
  );

  Account? account;

  List<int> categoryForIncomeTreeIds = <int>[];
  List<int> categoryForTaxesTreeIds = <int>[];
  List<int> categoryForInterestTreeIds = <int>[];
  List<int> categoryForRepairsTreeIds = <int>[];
  List<int> categoryForMaintenanceTreeIds = <int>[];
  List<int> categoryForManagementTreeIds = <int>[];

  List<int> listOfCategoryIdsExpenses = <int>[];

  List<RentUnit> units = <RentUnit>[];

  DateRange dateRangeOfOperation = DateRange();

  Map<int, RentalPnL> pnlOverYears = {};

  cumulatePnL(Transaction t) {
    int transactionCategoryId = t.categoryId.value;

    if (this.isTransactionOrSplitAssociatedWithThisRental(t)) {
      int year = t.dateTime.value!.year;

      RentalPnL? pnl = pnlOverYears[year];
      if (pnl == null) {
        pnl = RentalPnL(date: t.dateTime.value!, currency: getCurrencyOfAssociatedAccount());

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
          cumulatePnLValues(pnl, split.categoryId.value, split.amount.value.toDouble());
        }
      } else {
        cumulatePnLValues(pnl, transactionCategoryId, t.amount.value.toDouble());
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

  late RentalPnL lifeTimePnL;

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

  bool isTransactionAssociatedWithThisRental(int transactionCategoryId) {
    return this.categoryForIncomeTreeIds.contains(transactionCategoryId) ||
        this.categoryForInterestTreeIds.contains(transactionCategoryId) ||
        this.categoryForRepairsTreeIds.contains(transactionCategoryId) ||
        this.categoryForMaintenanceTreeIds.contains(transactionCategoryId) ||
        this.categoryForManagementTreeIds.contains(transactionCategoryId) ||
        this.categoryForTaxesTreeIds.contains(transactionCategoryId);
  }

  RentBuilding() {
    buildFieldsAsWidgetForSmallScreen = () => MyListItemAsCard(
          leftTopAsString: name.value,
          leftBottomAsString: address.value,
          rightTopAsWidget: MoneyWidget(amountModel: MoneyModel(amount: lifeTimePnL.profit), asTile: true),
        );
  }

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

  // Fields for this instance
  @override
  FieldDefinitions get fieldDefinitions => fields.definitions;

  associateAccountToBuilding() {
    final Transaction? firstTransactionForThisBuilding = Data()
        .transactions
        .iterableList(includeDeleted: true)
        .firstWhereOrNull((t) => this.categoryForIncomeTreeIds.contains(t.categoryId.value));
    if (firstTransactionForThisBuilding != null) {
      this.account = firstTransactionForThisBuilding.accountInstance;
    }
  }
}
