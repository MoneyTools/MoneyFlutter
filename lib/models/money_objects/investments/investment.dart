import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';

/*
  0    Id              bigint  0                    1
  1    Security        INT     1                    0
  2    UnitPrice       money   1                    0
  3    Units           money   0                    0
  4    Commission      money   0                    0
  5    MarkUpDown      money   0                    0
  6    Taxes           money   0                    0
  7    Fees            money   0                    0
  8    Load            money   0                    0
  9    InvestmentType  INT     1                    0
  10   TradeType       INT     0                    0
  11   TaxExempt       bit     0                    0
  12   Withholding     money   0                    0
 */

class Investment extends MoneyObject<Investment> {
  @override
  int get uniqueId => id.value;

  // 0
  Declare<Investment, int> id = Declare<Investment, int>(
    importance: 0,
    serializeName: 'Id',
    defaultValue: -1,
    useAsColumn: false,
    valueForSerialization: (final Investment instance) => instance.id.value,
  );

  // 1
  final int security;

  // 2
  double unitPrice;

  // 3
  double units;

  // 4
  double commission;

  // 5
  double markUpDown;

  Investment({
    required this.security,
    required this.unitPrice,
    required this.units,
    required this.commission,
    required this.markUpDown,
  });

  /// Constructor from a SQLite row
  factory Investment.fromSqlite(final Json row) {
    return Investment(
      // 1
      security: jsonGetInt(row, 'Security'),
      // 2
      unitPrice: jsonGetDouble(row, 'UnitPrice'),
      // 3
      units: jsonGetDouble(row, 'Units'),
      // 4
      commission: jsonGetDouble(row, 'Commission'),
      // 5
      markUpDown: jsonGetDouble(row, 'MarkUpDown'),
    )..id.value = jsonGetInt(row, 'Id');
  }
}
