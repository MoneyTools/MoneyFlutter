part of 'data.dart';

extension DataFromSql on Data {
  Future<void> loadFromSql({
    required final String? filePathToLoad,
    required final Function callbackWhenLoaded,
  }) async {
    rememberWhereTheDataCameFrom(null);

    if (filePathToLoad == null) {
      return callbackWhenLoaded(false);
    }

    if (filePathToLoad == Constants.demoData) {
      // Generate a data set to demo the application
      for (final MoneyObjects<dynamic> moneyObjects in _listOfTables) {
        moneyObjects.loadDemoData();
      }

      rememberWhereTheDataCameFrom(Constants.demoData);
    } else {
      // Load from SQLite
      try {
        final String? pathToDatabaseFile = await validateDataBasePathIsValidAndExist(filePathToLoad);

        if (pathToDatabaseFile != null) {
          // Open or create the database
          final MyDatabase db = MyDatabase(pathToDatabaseFile);

          // Account_Aliases
          accountAliases.loadFromSql(db);

          // Accounts
          accounts.loadFromSql(db);

          // Aliases
          aliases.loadFromSql(db);

          // Categories
          categories.loadFromSql(db);

          // Currencies
          currencies.loadFromSql(db, 'SELECT * FROM Currencies');

          // Investments
          investments.loadFromSql(db, 'SELECT * FROM Investments');

          // Loan Payments
          loanPayments.loadFromSql(db, 'SELECT * FROM LoanPayments');

          // Online Accounts
          onlineAccounts.loadFromSql(db, 'SELECT * FROM OnlineAccounts');

          // Payees
          payees.loadFromSql(db, 'SELECT * FROM Payees');

          // Rent Buildings
          rentBuildings.loadFromSql(db, 'SELECT * FROM RentBuildings');

          // Rent Units
          rentUnits.loadFromSql(db, 'SELECT * FROM RentUnits');

          // Securities
          securities.loadFromSql(db, 'SELECT * FROM Securities');

          // Splits
          splits.loadFromSql(db, 'SELECT * FROM Splits');

          // Stock Splits
          stockSplits.loadFromSql(db, 'SELECT * FROM StockSplits');

          // Transactions
          transactions.loadFromSql(db, 'SELECT * FROM Transactions');

          // Transaction Extras{
          transactionExtras.loadFromSql(db, 'SELECT * FROM TransactionExtras');

          // Close the database when done
          db.dispose();
        }
        rememberWhereTheDataCameFrom(pathToDatabaseFile);
      } catch (e) {
        debugLog(e.toString());
        rememberWhereTheDataCameFrom(null);
        callbackWhenLoaded(false);
        return;
      }
    }

    // All individual table were loaded, now let the cross reference money object create linked to other tables
    for (final MoneyObjects<dynamic> moneyObjects in _listOfTables) {
      moneyObjects.onAllDataLoaded();
    }

    // Notify that loading is completed
    callbackWhenLoaded(true);
  }

  Future<bool> saveToSql({
    required final String? filePathToLoad,
    required final Function callbackWhenLoaded,
  }) async {
    try {
      final String? pathToDatabaseFile = await validateDataBasePathIsValidAndExist(filePathToLoad);

      if (pathToDatabaseFile != null) {
        final MyDatabase db = MyDatabase(pathToDatabaseFile);

        accounts.saveSql(db);

        // this.UpdateOnlineAccounts(money.OnlineAccounts);
        // this.UpdateAccounts(money.Accounts);
        // this.UpdatePayees(money.Payees);
        // this.UpdateAliases(money.Aliases);
        // this.UpdateAccountAliases(money.AccountAliases);
        // this.UpdateCategories(money.Categories);
        // this.UpdateCurrencies(money.Currencies);
        transactions.saveSql(db);
        // this.UpdateSecurities(money.Securities);
        // this.UpdateStockSplits(money.StockSplits);
        // this.UpdateBuildings(money.Buildings);
        // this.UpdateLoanPayments(money.LoanPayments);
        // this.UpdateTransactionExtras(money.TransactionExtras);
      }
    } catch (e) {
      debugLog(e.toString());
      rememberWhereTheDataCameFrom(null);
      callbackWhenLoaded(false);
    }

    return true;
  }
}
