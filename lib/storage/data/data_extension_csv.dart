part of 'data.dart';

const String mainFileName = 'mymoney.mmcsv';
const String subFolderName = 'mymoney_csv_files';

extension DataFromCsv on Data {
  Future<void> loadFromCsv(String filePathToLoad) async {
    final String? pathToDatabaseFile = await validateDataBasePathIsValidAndExist(filePathToLoad, Uint8List(0));

    if (pathToDatabaseFile != null) {
      final subFolder = MyFileSystems.append(MyFileSystems.getFolderFromFilePath(pathToDatabaseFile), subFolderName);
      await loadCsvFiles(subFolder);
      Settings().fileManager.rememberWhereTheDataCameFrom(pathToDatabaseFile);
    }
  }

  Future<void> loadCsvFiles(String folder) async {
    accountAliases.loadFromJson(await readCsvRowAsJsonObjects(folder, 'account_aliases.csv'));
    accounts.loadFromJson(await readCsvRowAsJsonObjects(folder, 'accounts.csv'));
    accounts.loadFromJson(await readCsvRowAsJsonObjects(folder, 'accounts.csv'));
    aliases.loadFromJson(await readCsvRowAsJsonObjects(folder, 'aliases.csv'));
    categories.loadFromJson(await readCsvRowAsJsonObjects(folder, 'categories.csv'));
    currencies.loadFromJson(await readCsvRowAsJsonObjects(folder, 'currencies.csv'));
    investments.loadFromJson(await readCsvRowAsJsonObjects(folder, 'investments.csv'));
    loanPayments.loadFromJson(await readCsvRowAsJsonObjects(folder, 'loan_payments.csv'));
    onlineAccounts.loadFromJson(await readCsvRowAsJsonObjects(folder, 'online_accounts.csv'));
    payees.loadFromJson(await readCsvRowAsJsonObjects(folder, 'payees.csv'));
    rentBuildings.loadFromJson(await readCsvRowAsJsonObjects(folder, 'rent_buildings.csv'));
    rentUnits.loadFromJson(await readCsvRowAsJsonObjects(folder, 'rent_units.csv'));
    securities.loadFromJson(await readCsvRowAsJsonObjects(folder, 'securities.csv'));
    splits.loadFromJson(await readCsvRowAsJsonObjects(folder, 'splits.csv'));
    stockSplits.loadFromJson(await readCsvRowAsJsonObjects(folder, 'stock_splits.csv'));
    transactions.loadFromJson(await readCsvRowAsJsonObjects(folder, 'transactions.csv'));
    transactionExtras.loadFromJson(await readCsvRowAsJsonObjects(folder, 'transaction_extras.csv'));
  }

  Future<List<MyJson>> readCsvRowAsJsonObjects(String subFolder, final String filename) async {
    final String fullPathToFile = MyFileSystems.append(subFolder, filename);

    List<MyJson> rows = [];
    String fileContent = await MyFileSystems.readFile(fullPathToFile);
    List<String> lines = getLinesFromTextBlob(fileContent);
    if (lines.length > 1) {
      final List<String> csvHeaderColumns = getColumnInCsvLine(lines[0]);
      for (int lineIndex = 1; lineIndex < lines.length; lineIndex++) {
        final List<String> csvRowValues = getColumnInCsvLine(lines[lineIndex]);
        final rowValues = myJsonFromKeyValuePairs(csvHeaderColumns, csvRowValues);
        rows.add(rowValues);
      }
    }
    return rows;
  }

  Future<String> saveToCsv() async {
    String destinationFolder = await Settings().fileManager.generateNextFolderToSaveTo();
    if (destinationFolder.isEmpty) {
      throw Exception('No container folder give for saving');
    }

    final String mainFilename = MyFileSystems.append(destinationFolder, mainFileName);

    MyFileSystems.ensureFolderExist(destinationFolder).then((final _) {
      MyFileSystems.writeToFile(mainFilename, DateTime.now().toString());
      final subFolder = MyFileSystems.append(destinationFolder, subFolderName);
      MyFileSystems.ensureFolderExist(subFolder).then((final _) {
        writeEachFiles(subFolder);
      });
    });
    return mainFilename;
  }

  void writeEachFiles(String folder) {
    MyFileSystems.writeFileContentIntoFolder(folder, 'account_aliases.csv', accountAliases.toCSV());
    MyFileSystems.writeFileContentIntoFolder(folder, 'accounts.csv', accounts.toCSV());
    MyFileSystems.writeFileContentIntoFolder(folder, 'aliases.csv', aliases.toCSV());
    MyFileSystems.writeFileContentIntoFolder(folder, 'categories.csv', categories.toCSV());
    MyFileSystems.writeFileContentIntoFolder(folder, 'currencies.csv', currencies.toCSV());
    MyFileSystems.writeFileContentIntoFolder(folder, 'investments.csv', investments.toCSV());
    MyFileSystems.writeFileContentIntoFolder(folder, 'loan_payments.csv', loanPayments.toCSV());
    MyFileSystems.writeFileContentIntoFolder(folder, 'online_accounts.csv', onlineAccounts.toCSV());
    MyFileSystems.writeFileContentIntoFolder(folder, 'payees.csv', payees.toCSV());
    MyFileSystems.writeFileContentIntoFolder(folder, 'securities.csv', securities.toCSV());
    MyFileSystems.writeFileContentIntoFolder(folder, 'splits.csv', splits.toCSV());
    MyFileSystems.writeFileContentIntoFolder(folder, 'stock_splits.csv', stockSplits.toCSV());
    MyFileSystems.writeFileContentIntoFolder(folder, 'rent_units.csv', rentUnits.toCSV());
    MyFileSystems.writeFileContentIntoFolder(folder, 'rent_buildings.csv', rentBuildings.toCSV());
    MyFileSystems.writeFileContentIntoFolder(folder, 'rent_units.csv', rentUnits.toCSV());
    MyFileSystems.writeFileContentIntoFolder(folder, 'transaction_extras.csv', transactionExtras.toCSV());
    MyFileSystems.writeFileContentIntoFolder(folder, 'transactions.csv', transactions.toCSV());
  }
}
