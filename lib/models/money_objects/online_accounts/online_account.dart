import 'package:money/helpers/json_helper.dart';
import 'package:money/models/money_objects/money_objects.dart';

/*
  0    Id                 INT             0                    1
  1    Name               nvarchar(80)    1                    0
  2    Institution        nvarchar(80)    0                    0
  3    OFX                nvarchar(255)   0                    0
  4    OfxVersion         nchar(10)       0                    0
  5    FID                nvarchar(50)    0                    0
  6    UserId             nchar(20)       0                    0
  7    Password           nvarchar(50)    0                    0
  8    UserCred1          nvarchar(200)   0                    0
  9    UserCred2          nvarchar(200)   0                    0
  10   AuthToken          nvarchar(200)   0                    0
  11   BankId             nvarchar(50)    0                    0
  12   BranchId           nvarchar(50)    0                    0
  13   BrokerId           nvarchar(50)    0                    0
  14   LogoUrl            nvarchar(1000)  0                    0
  15   AppId              nchar(10)       0                    0
  16   AppVersion         nchar(10)       0                    0
  17   ClientUid          nchar(36)       0                    0
  18   AccessKey          nchar(36)       0                    0
  19   UserKey            nvarchar(64)    0                    0
  20   UserKeyExpireDate  datetime        0                    0
 */

class OnlineAccount extends MoneyObject<OnlineAccount> {
  @override
  int get uniqueId => id.value;

  // 0
  Field<OnlineAccount, int> id = Field<OnlineAccount, int>(
    importance: 0,
    serializeName: 'Id',
    defaultValue: -1,
    useAsColumn: false,
    valueForSerialization: (final OnlineAccount instance) => instance.id.value,
  );

  // 1
  final String name;

  // 2
  final String institution;

  // 3
  final String ofx;

  // 4
  final String ofxVersion;

  // 5
  final String fdic;

  // 6
  final String userId;

  // 7
  final String password;

  // 8
  final String userCred1;

  // 9
  final String userCred2;

  // 10
  final String authToken;

  // 11
  final String bankId;

  // 12
  final String branchId;

  OnlineAccount({
    required this.name,
    required this.institution,
    required this.ofx,
    required this.ofxVersion,
    required this.fdic,
    required this.userId,
    required this.password,
    required this.userCred1,
    required this.userCred2,
    required this.authToken,
    required this.bankId,
    required this.branchId,
  });

  /// Constructor from a SQLite row
  factory OnlineAccount.fromSqlite(final Json row) {
    return OnlineAccount(
      // 1
      name: jsonGetString(row, 'Name'),
      // 2
      institution: jsonGetString(row, 'Institution'),
      // 3
      ofx: jsonGetString(row, 'Ofx'),
      // 4
      ofxVersion: jsonGetString(row, 'OfxVersion'),
      // 5
      fdic: jsonGetString(row, 'Fdic'),
      // 6
      userId: jsonGetString(row, 'UserId'),
      // 7
      password: jsonGetString(row, 'Password'),
      // 8
      userCred1: jsonGetString(row, 'UserCred1'),
      // 9
      userCred2: jsonGetString(row, 'UserCred2'),
      // 10
      authToken: jsonGetString(row, 'AuthToken'),
      // 11
      bankId: jsonGetString(row, 'BankId'),
      // 12
      branchId: jsonGetString(row, 'BranchId'),
    )..id.value = jsonGetInt(row, 'Id');
  }
}
