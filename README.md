# myMoney - Flutter edition

From the MoneyTools vTeam, we bring you the flutter edition of the MyMoney.net app

## Getting Started

### GitHub

- <https://github.com/MoneyTools/MoneyFlutter>
This is the Flutter app, you will need to install the Flutter/Dart frameWork and an IDE, we suggest VSCode.

## Install tools

- ### VSCode

  - <https://code.visualstudio.com/download>

- ### Flutter * Dart

  - <https://docs.flutter.dev/get-started/install>

### Build, Run the app and when stared tap/click "Use Demo Data"

1. Open the root folder in VSCode
  
2. Select a client, the app can builds and run on these Flutter supported platforms

   - iOS
   - Android
   - MacOS
   - Windows
   - Web
   - Linux

## Data

### SQLite Tables

#### 1 - AccountAliases

```bash
sqlite3 mydata.MyMoney.mmdb .schema
sqlite3 mydata.MyMoney.mmdb .dumb > backup.sql
```

```text
cid  name       type           notnull  dflt_value  pk
---  ---------  -------------  -------  ----------  --
0    Id         INT            0                    1 
1    Pattern    nvarchar(255)  1                    0 
2    Flags      INT            1                    0 
3    AccountId  nchar(20)      1                    0 
```

#### 2 - Accounts

```text
cid  name                    type              notnull  dflt_value  pk
---  ----------------------  ----------------  -------  ----------  --
0    Id                      INT               0                    1
1    AccountId               nchar(20)         0                    0
2    OfxAccountId            nvarchar(50)      0                    0
3    Name                    nvarchar(80)      1                    0
4    Description             nvarchar(255)     0                    0
5    Type                    INT               1                    0
6    OpeningBalance          money             0                    0
7    Currency                nchar(3)          0                    0
8    OnlineAccount           INT               0                    0
9    WebSite                 nvarchar(512)     0                    0
10   ReconcileWarning        INT               0                    0
11   LastSync                datetime          0                    0
12   SyncGuid                uniqueidentifier  0                    0
13   Flags                   INT               0                    0
14   LastBalance             datetime          0                    0
15   CategoryIdForPrincipal  INT               0                    0
16   CategoryIdForInterest   INT               0                    0
```

#### 3 - Aliases

```text
cid  name     type           notnull  dflt_value  pk
---  -------  -------------  -------  ----------  --
0    Id       INT            0                    1
1    Pattern  nvarchar(255)  1                    0
2    Flags    INT            1                    0
3    Payee    INT            1                    0
```

#### 4 - Categories

```text
cid  name         type           notnull  dflt_value  pk
---  -----------  -------------  -------  ----------  --
0    Id           INT            0                    1 
1    ParentId     INT            0                    0 
2    Name         nvarchar(80)   1                    0 
3    Description  nvarchar(255)  0                    0 
4    Type         INT            1                    0 
5    Color        nchar(10)      0                    0 
6    Budget       money          0                    0 
7    Balance      money          0                    0 
8    Frequency    INT            0                    0 
9    TaxRefNum    INT            0                    0
```

#### 5 - Currencies

```text
cid  name         type          notnull  dflt_value  pk
---  -----------  ------------  -------  ----------  --
0    Id           INT           0                    1 
1    Symbol       nchar(20)     1                    0 
2    Name         nvarchar(80)  1                    0 
3    Ratio        money         0                    0 
4    LastRatio    money         0                    0 
5    CultureCode  nvarchar(80)  0                    0 
```

#### 6 - Investments

```text
cid  name            type    notnull  dflt_value  pk
---  --------------  ------  -------  ----------  --
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
```

#### 7 - LoanPayments

```text
cid  name       type           notnull  dflt_value  pk
---  ---------  -------------  -------  ----------  --
0    Id         INT            1                    0
1    AccountId  INT            1                    0
2    Date       datetime       1                    0
3    Principal  money          0                    0
4    Interest   money          0                    0
5    Memo       nvarchar(255)  0                    0
```

#### 8 - OnlineAccounts

```text
cid  name               type            notnull  dflt_value  pk
---  -----------------  --------------  -------  ----------  --
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
```

#### 9 - Payees

```text
cid  name  type           notnull  dflt_value  pk
---  ----  -------------  -------  ----------  --
0    Id    INT            0                    1 
1    Name  nvarchar(255)  1                    0
```

#### 10 - RentBuildings

```text
cid  name                    type           notnull  dflt_value  pk
---  ----------------------  -------------  -------  ----------  --
0    Id                      INT            0                    1
1    Name                    nvarchar(255)  1                    0
2    Address                 nvarchar(255)  0                    0
3    PurchasedDate           datetime       0                    0
4    PurchasedPrice          money          0                    0
5    LandValue               money          0                    0
6    EstimatedValue          money          0                    0
7    OwnershipName1          nvarchar(255)  0                    0
8    OwnershipName2          nvarchar(255)  0                    0
9    OwnershipPercentage1    money          0                    0
10   OwnershipPercentage2    money          0                    0
11   Note                    nvarchar(255)  0                    0
12   CategoryForTaxes        INT            0                    0
13   CategoryForIncome       INT            0                    0
14   CategoryForInterest     INT            0                    0
15   CategoryForRepairs      INT            0                    0
16   CategoryForMaintenance  INT            0                    0
17   CategoryForManagement   INT            0                    0
```

#### 11 - RentUnits

```text
cid  name      type           notnull  dflt_value  pk
---  --------  -------------  -------  ----------  --
0    Id        INT            0                    1 
1    Building  INT            1                    0 
2    Name      nvarchar(255)  1                    0 
3    Renter    nvarchar(255)  0                    0 
4    Note      nvarchar(255)  0                    0 
```

#### 12 - Securities

```text
cid  name          type          notnull  dflt_value  pk
---  ------------  ------------  -------  ----------  --
0    Id            INT           0                    1
1    Name          nvarchar(80)  1                    0
2    Symbol        nchar(20)     1                    0
3    Price         money         0                    0
4    LastPrice     money         0                    0
5    CUSPID        nchar(20)     0                    0
6    SECURITYTYPE  INT           0                    0
7    TAXABLE       tinyint       0                    0
8    PriceDate     datetime      0                    0
```

#### 13 - Splits

```text
cid  name               type           notnull  dflt_value  pk
---  -----------------  -------------  -------  ----------  --
0    Transaction        bigint         1                    0 
1    Id                 INT            1                    0 
2    Category           INT            0                    0 
3    Payee              INT            0                    0 
4    Amount             money          1                    0 
5    Transfer           bigint         0                    0 
6    Memo               nvarchar(255)  0                    0 
7    Flags              INT            0                    0 
8    BudgetBalanceDate  datetime       0                    0 
```

#### 14 - StockSplits

```text
cid  name         type      notnull  dflt_value  pk
---  -----------  --------  -------  ----------  --
0    Id           bigint    0                    1 
1    Date         datetime  1                    0 
2    Security     INT       1                    0 
3    Numerator    money     1                    0 
4    Denominator  money     1                    0 
```

#### 15 - TransactionExtras

```text
cid  name         type      notnull  dflt_value  pk
---  -----------  --------  -------  ----------  --
0    Id           INT       0                    1
1    Transaction  bigint    1                    0
2    TaxYear      INT       1                    0
3    TaxDate      datetime  0                    0
```

#### 16 - Transactions

```text
cid  name               type           notnull  dflt_value  pk
---  -----------------  -------------  -------  ----------  --
0    Id                 bigint         0                    1 
1    Account            INT            1                    0 
2    Date               datetime       1                    0 
3    Status             INT            0                    0 
4    Payee              INT            0                    0 
5    OriginalPayee      nvarchar(255)  0                    0 
6    Category           INT            0                    0 
7    Memo               nvarchar(255)  0                    0 
8    Number             nchar(10)      0                    0 
9    ReconciledDate     datetime       0                    0 
10   BudgetBalanceDate  datetime       0                    0 
11   Transfer           bigint         0                    0 
12   FITID              nchar(40)      0                    0 
13   Flags              INT            1                    0 
14   Amount             money          1                    0 
15   SalesTax           money          0                    0 
16   TransferSplit      INT            0                    0 
17   MergeDate          datetime       0                    0 
```

## Code Style

Ensure your code is formatted correctly by running this CLI before committing changes

macOS

```bash
./check.sh
```

Windows

```batch
./check.cmd
```

## Main UI

![overview.svg](documentation%2Foverview.svg)

## Layer Dependency Diagram

![layers.svg](layers.svg)

## Graph Call

install

```dart pub global activate lakos```

```brew install graphviz```

run
```./graph.sh```

## Deploy

### to Web

- Install Firebase tool
  ```npm install -g firebase-tools```

- Enable firebase experiments
  ```firebase experiments:enable webframeworks```

- Deploy to your account
  ```firebase deploy```

### To Android Google Play

- Build the bundle
  
  ```flutter build appbundle```

- Google App Console
  - <https://play.google.com/console>
  - Upload the bundle
