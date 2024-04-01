// ignore_for_file: unnecessary_this

import 'package:money/helpers/date_helper.dart';
import 'package:money/models/fields/fields.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/models/money_objects/currencies/currency.dart';
import 'package:money/models/money_objects/rental_unit/rental_unit.dart';
import 'package:money/models/date_range.dart';
import 'package:money/models/money_objects/money_object.dart';
import 'package:money/widgets/list_view/list_item_card.dart';

class RentBuilding extends MoneyObject {
  static Fields<RentBuilding>? fields;

  @override
  int get uniqueId => id.value;

  @override
  set uniqueId(value) => id.value = value;

  /// ID
  // 0    Id                      INT            0                    1
  FieldId id = FieldId(
    valueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).uniqueId,
  );

  /// Name
  // 1    Name                    nvarchar(255)  1                    0
  FieldString name = FieldString(
    importance: 1,
    name: 'Name',
    serializeName: 'Name',
    valueFromInstance: (final MoneyObject instance) => (instance as RentBuilding).name.value,
    valueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).name.value,
  );

  /// Address
  // 2    Address                 nvarchar(255)  0                    0
  FieldString address = FieldString(
    importance: 2,
    name: 'Address',
    serializeName: 'Address',
    valueFromInstance: (final MoneyObject instance) => (instance as RentBuilding).address.value,
    valueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).address.value,
  );

  /// PurchasedDate
  // 3    PurchasedDate           datetime       0                    0
  FieldDate purchasedDate = FieldDate(
    importance: 2,
    name: 'Purchased Date',
    serializeName: 'PurchasedDate',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) =>
        dateAsIso8601OrDefault((instance as RentBuilding).purchasedDate.value),
    valueForSerialization: (final MoneyObject instance) =>
        dateAsIso8601OrDefault((instance as RentBuilding).purchasedDate.value),
  );

  /// PurchasedPrice
  // 4    PurchasedPrice          money          0                    0
  FieldAmount purchasedPrice = FieldAmount(
    importance: 2,
    name: 'Purchased Price',
    serializeName: 'PurchasedPrice',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as RentBuilding).purchasedPrice.value,
    valueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).purchasedPrice.value,
  );

  /// LandValue
  // 5    LandValue          money          0                    0
  FieldAmount landValue = FieldAmount(
    importance: 2,
    name: 'LandValue',
    serializeName: 'LandValue',
    valueFromInstance: (final MoneyObject instance) => (instance as RentBuilding).landValue.value,
    valueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).landValue.value,
  );

  /// EstimatedValue
  // 6    EstimatedValue          money          0                    0
  FieldAmount estimatedValue = FieldAmount(
    importance: 2,
    name: 'EstimatedValue',
    serializeName: 'EstimatedValue',
    valueFromInstance: (final MoneyObject instance) => (instance as RentBuilding).estimatedValue.value,
    valueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).estimatedValue.value,
  );

  /// OwnershipName1
  // 7    OwnershipName1          money          0                    0
  FieldString ownershipName1 = FieldString(
    importance: 2,
    name: 'OwnershipName1',
    serializeName: 'OwnershipName1',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as RentBuilding).ownershipName1.value,
    valueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).ownershipName1.value,
  );

  /// OwnershipName2
  // 8    OwnershipName2          money          0                    0
  FieldString ownershipName2 = FieldString(
    importance: 2,
    name: 'OwnershipName2',
    serializeName: 'OwnershipName2',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as RentBuilding).ownershipName2.value,
    valueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).ownershipName2.value,
  );

  /// OwnershipPercentage1
  // 9    OwnershipPercentage1          money          0                    0
  FieldDouble ownershipPercentage1 = FieldDouble(
    importance: 2,
    name: 'OwnershipPercentage1',
    serializeName: 'OwnershipPercentage1',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as RentBuilding).ownershipPercentage1.value,
    valueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).ownershipPercentage1.value,
  );

  /// OwnershipPercentage2
  // 10    OwnershipPercentage2          money          0                    0
  FieldDouble ownershipPercentage2 = FieldDouble(
    importance: 2,
    name: 'OwnershipPercentage2',
    serializeName: 'OwnershipPercentage2',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as RentBuilding).ownershipPercentage2.value,
    valueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).ownershipPercentage2.value,
  );

  /// Note
  // 11    Note          money          0                    0
  FieldString note = FieldString(
    importance: 2,
    name: 'Note',
    serializeName: 'Note',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as RentBuilding).note.value,
    valueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).note.value,
  );

  /// CategoryForTaxes
  // 12    CategoryForTaxes          money          0                    0
  FieldInt categoryForTaxes = FieldInt(
    importance: 2,
    name: 'CategoryForTaxes',
    serializeName: 'CategoryForTaxes',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as RentBuilding).categoryForTaxes.value,
    valueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).categoryForTaxes.value,
  );

  /// CategoryForIncome
  // 13    CategoryForIncome          money          0                    0
  FieldInt categoryForIncome = FieldInt(
    importance: 2,
    name: 'CategoryForIncome',
    serializeName: 'CategoryForIncome',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as RentBuilding).categoryForIncome.value,
    valueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).categoryForIncome.value,
  );

  /// CategoryForInterest
  // 14    CategoryForInterest          money          0                    0
  FieldInt categoryForInterest = FieldInt(
    importance: 2,
    name: 'CategoryForInterest',
    serializeName: 'CategoryForInterest',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as RentBuilding).categoryForInterest.value,
    valueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).categoryForInterest.value,
  );

  /// CategoryForRepairs
  // 15    CategoryForRepairs          money          0                    0
  FieldInt categoryForRepairs = FieldInt(
    importance: 2,
    name: 'CategoryForRepairs',
    serializeName: 'CategoryForRepairs',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as RentBuilding).categoryForRepairs.value,
    valueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).categoryForRepairs.value,
  );

  /// CategoryForMaintenance
  // 16    CategoryForMaintenance          money          0                    0
  FieldInt categoryForMaintenance = FieldInt(
    importance: 2,
    name: 'CategoryForMaintenance',
    serializeName: 'CategoryForMaintenance',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as RentBuilding).categoryForMaintenance.value,
    valueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).categoryForMaintenance.value,
  );

  /// CategoryForManagement
  // 17    CategoryForManagement          money          0                    0
  FieldInt categoryForManagement = FieldInt(
    importance: 2,
    name: 'CategoryForManagement',
    serializeName: 'CategoryForManagement',
    useAsColumn: false,
    valueFromInstance: (final MoneyObject instance) => (instance as RentBuilding).categoryForManagement.value,
    valueForSerialization: (final MoneyObject instance) => (instance as RentBuilding).categoryForManagement.value,
  );

  int count = 0;

  /// Revenue
  FieldAmount revenue = FieldAmount(
    importance: 20,
    name: 'Revenue',
    valueFromInstance: (final MoneyObject instance) => (instance as RentBuilding).revenue.value,
  );

  /// Expenses
  FieldAmount expense = FieldAmount(
    importance: 21,
    name: 'Expenses',
    valueFromInstance: (final MoneyObject instance) => (instance as RentBuilding).expense.value,
  );

  /// Profit
  FieldAmount profit = FieldAmount(
    importance: 22,
    name: 'Profit',
    valueFromInstance: (final MoneyObject instance) => (instance as RentBuilding).profit.value,
  );

  List<int> categoryForIncomeTreeIds = <int>[];
  List<int> categoryForTaxesTreeIds = <int>[];
  List<int> categoryForInterestTreeIds = <int>[];
  List<int> categoryForRepairsTreeIds = <int>[];
  List<int> categoryForMaintenanceTreeIds = <int>[];
  List<int> categoryForManagementTreeIds = <int>[];

  List<int> listOfCategoryIdsExpenses = <int>[];

  List<RentUnit> units = <RentUnit>[];

  DateRange dateRange = DateRange();

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
  RentBuilding() {
    fields ??= Fields<RentBuilding>(definitions: [
      this.id,
      this.name,
      this.address,
      this.purchasedDate,
      this.purchasedPrice,
      this.landValue,
      this.estimatedValue,
      this.ownershipName1,
      this.ownershipName2,
      this.ownershipPercentage1,
      this.ownershipPercentage2,
      this.categoryForTaxes,
      this.categoryForIncome,
      this.categoryForInterest,
      this.categoryForRepairs,
      this.categoryForMaintenance,
      this.categoryForManagement,
    ]);
    // Also stash the definition in the instance for fast retrieval later
    fieldDefinitions = fields!.definitions;

    buildFieldsAsWidgetForSmallScreen = () => MyListItemAsCard(
          leftTopAsString: name.value,
          leftBottomAsString: address.value,
          rightTopAsString: Currency.getAmountAsStringUsingCurrency(profit.value),
        );
  }

  factory RentBuilding.fromJson(final MyJson row) {
    final RentBuilding instance = RentBuilding();

    instance.id.value = row.getInt('Id', -1);
    instance.name.value = row.getString('Name');
    instance.address.value = row.getString('Address');
    instance.purchasedDate.value = row.getDate('PurchasedDate', DateTime.now());
    instance.purchasedPrice.value = row.getDouble('PurchasedPrice');
    instance.landValue.value = row.getDouble('LandValue');
    instance.estimatedValue.value = row.getDouble('EstimatedValue');
    instance.ownershipName1.value = row.getString('OwnershipName1');
    instance.ownershipName2.value = row.getString('OwnershipName2');
    instance.ownershipPercentage1.value = row.getDouble('ownershipPercentage1');
    instance.ownershipPercentage2.value = row.getDouble('ownershipPercentage1');

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
}
