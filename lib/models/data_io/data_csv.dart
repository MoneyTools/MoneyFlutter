part of 'data.dart';

extension DataFromCsv on Data {
  void saveToCsv() {
    if (fullPathToNextDataSave == null) {
      throw Exception('No container folder give for saving');
    }

    final TimeLapse timeLapse = TimeLapse();
    final String folder = fullPathToNextDataSave!;

    MyFileSystems.ensureFolderExist(folder).then((final _) {
      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'account_aliases.csv'),
        accountAliases.toCSV(),
      );
      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'accounts.csv'),
        accounts.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'aliases.csv'),
        Data().aliases.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'categories.csv'),
        Data().categories.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'currencies.csv'),
        currencies.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'investments.csv'),
        Data().investments.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'loan_payments.csv'),
        Data().loanPayments.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'online_accounts.csv'),
        Data().onlineAccounts.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'payees.csv'),
        Data().payees.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'securities.csv'),
        Data().securities.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'splits.csv'),
        Data().splits.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'stock_splits.csv'),
        Data().stockSplits.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'rent_units.csv'),
        Data().rentUnits.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'rent_buildings.csv'),
        Data().rentBuildings.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'rent_units.csv'),
        Data().rentUnits.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'transaction_extras.csv'),
        Data().transactionExtras.toCSV(),
      );

      MyFileSystems.writeToFile(
        MyFileSystems.append(folder, 'transactions.csv'),
        Data().transactions.toCSV(),
      );

      timeLapse.endAndPrint();
    });
  }
}
