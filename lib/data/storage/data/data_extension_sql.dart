part of 'data.dart';

extension DataFromSql on Data {
  Future<bool> loadFromSql({
    required final String filePath,
    required final Uint8List fileBytes,
  }) async {
    // Load from SQLite
    final String? pathToDatabaseFile = await validateDataBasePathIsValidAndExist(filePath, fileBytes);

    if (pathToDatabaseFile != null || fileBytes.isNotEmpty) {
      // Open or create the database
      final MyDatabase db = MyDatabase();

      await db.load(filePath, fileBytes);
      // Load
      accountAliases.loadFromJson(
        await db.select('SELECT * FROM AccountAliases'),
      );
      accounts.loadFromJson(await db.select('SELECT * FROM Accounts'));
      aliases.loadFromJson(await db.select('SELECT * FROM Aliases'));
      categories.loadFromJson(await db.select('SELECT * FROM Categories'));
      currencies.loadFromJson(await db.select('SELECT * FROM Currencies'));
      investments.loadFromJson(await db.select('SELECT * FROM Investments'));
      loanPayments.loadFromJson(await db.select('SELECT * FROM LoanPayments'));
      onlineAccounts.loadFromJson(
        await db.select('SELECT * FROM OnlineAccounts'),
      );
      payees.loadFromJson(await db.select('SELECT * FROM Payees'));
      rentBuildings.loadFromJson(
        await db.select('SELECT * FROM RentBuildings'),
      );
      rentUnits.loadFromJson(await db.select('SELECT * FROM RentUnits'));
      securities.loadFromJson(await db.select('SELECT * FROM Securities'));
      stockSplits.loadFromJson(await db.select('SELECT * FROM StockSplits'));

      // Check if the Events table exists before loading it
      if (await db.tableExists('Events')) {
        events.loadFromJson(await db.select('SELECT * FROM Events'));
      }

      transactions.loadFromJson(await db.select('SELECT * FROM Transactions'));
      transactionExtras.loadFromJson(
        await db.select('SELECT * FROM TransactionExtras'),
      );
      // Must come after Transactions are loaded
      splits.loadFromJson(await db.select('SELECT * FROM Splits'));

      // Close the database when done
      db.dispose();
      return true;
    }
    return false;
  }

  Future<bool> saveToSql({
    required final String filePath,
    required final void Function(bool success, String errorMessage) onSaveCompleted,
  }) async {
    try {
      final MyDatabase db = MyDatabase();
      db.load(filePath, Uint8List(0));

      // Save transaction first
      accountAliases.saveSql(db, 'AccountAliases');
      accounts.saveSql(db, 'Accounts');
      aliases.saveSql(db, 'Aliases');
      categories.saveSql(db, 'Categories');
      currencies.saveSql(db, 'Currencies');
      investments.saveSql(db, 'Investments');
      loanPayments.saveSql(db, 'LoanPayments');
      onlineAccounts.saveSql(db, 'OnlineAccounts');
      payees.saveSql(db, 'Payees');
      rentBuildings.saveSql(db, 'RentBuildings');
      rentUnits.saveSql(db, 'RentUnits');
      securities.saveSql(db, 'Securities');
      stockSplits.saveSql(db, 'StockSplits');

      if (!await db.tableExists('Events')) {
        // Create the Events table if it doesn't exist
        db.execute('''
          CREATE TABLE [Events] (
            [Id] int PRIMARY KEY,
            [Name] nvarchar(255) NOT NULL,
            [Category] int,
            [Begin] datetime NOT NULL,
            [End] datetime NOT NULL,
            [People] nvarchar(255) NOT NULL,
            [Memo] nvarchar(255) NOT NULL
          );''');
      }
      events.saveSql(db, 'Events');

      transactions.saveSql(db, 'Transactions');
      transactionExtras.saveSql(db, 'TransactionExtras');
      splits.saveSql(db, 'Splits');

      db.dispose();
    } catch (e) {
      onSaveCompleted(false, e.toString());
      return false;
    }

    onSaveCompleted(true, '');
    return true;
  }
}
