import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/data/models/money_objects/money_objects.dart';

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

class OnlineAccount extends MoneyObject {

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
  factory OnlineAccount.fromJson(final MyJson row) {
    return OnlineAccount(
      // 1
      name: row.getString('Name'),
      // 2
      institution: row.getString('Institution'),
      // 3
      ofx: row.getString('Ofx'),
      // 4
      ofxVersion: row.getString('OfxVersion'),
      // 5
      fdic: row.getString('Fdic'),
      // 6
      userId: row.getString('UserId'),
      // 7
      password: row.getString('Password'),
      // 8
      userCred1: row.getString('UserCred1'),
      // 9
      userCred2: row.getString('UserCred2'),
      // 10
      authToken: row.getString('AuthToken'),
      // 11
      bankId: row.getString('BankId'),
      // 12
      branchId: row.getString('BranchId'),
    )..id.value = row.getInt('Id', -1);
  }
  @override
  int get uniqueId => id.value;
  @override
  set uniqueId(value) => id.value = value;

  // 0
  FieldId id = FieldId(
    getValueForSerialization: (final MoneyObject instance) => (instance as OnlineAccount).uniqueId,
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
}
