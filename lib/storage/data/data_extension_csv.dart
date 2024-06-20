part of 'data.dart';

const String mainFileName = 'mymoney.mmcsv';
const String subFolderName = 'mymoney_csv_files';

extension DataFromCsv on Data {
  Future<void> loadFromCsv(String filePathToLoad) async {
    File file = File(filePathToLoad);
    List<int> bytes = await file.readAsBytes();

    // Decode the ZIP file
    Archive archive = ZipDecoder().decodeBytes(bytes);

    // Extract the files and read the content
    for (ArchiveFile file in archive) {
      if (file.isFile) {
        String fileContent = getZipSingleFileContent(file);

        debugLog(file.name);
        final String fileNameInLowercase = MyFileSystems.getFileName(file.name).toLowerCase();
        debugLog(fileNameInLowercase);

        debugLog(fileContent);
        switch (fileNameInLowercase) {
          case 'account_aliases.csv':
            accountAliases.loadFromJson(rawCsvStringToListOfJsonObjects(fileContent));
          case 'accounts.csv':
            accounts.loadFromJson(rawCsvStringToListOfJsonObjects(fileContent));
          case 'aliases.csv':
            aliases.loadFromJson(rawCsvStringToListOfJsonObjects(fileContent));
          case 'categories.csv':
            categories.loadFromJson(rawCsvStringToListOfJsonObjects(fileContent));
          case 'investments.csv':
            investments.loadFromJson(rawCsvStringToListOfJsonObjects(fileContent));
          case 'loan_payments.csv':
            loanPayments.loadFromJson(rawCsvStringToListOfJsonObjects(fileContent));
          case 'online_accounts.csv':
            onlineAccounts.loadFromJson(rawCsvStringToListOfJsonObjects(fileContent));
          case 'payees.csv':
            payees.loadFromJson(rawCsvStringToListOfJsonObjects(fileContent));
          case 'rent_buildings.csv':
            rentBuildings.loadFromJson(rawCsvStringToListOfJsonObjects(fileContent));
          case 'rent_units.csv':
            rentUnits.loadFromJson(rawCsvStringToListOfJsonObjects(fileContent));
          case 'securities.csv':
            securities.loadFromJson(rawCsvStringToListOfJsonObjects(fileContent));
          case 'splits.csv':
            splits.loadFromJson(rawCsvStringToListOfJsonObjects(fileContent));
          case 'stock_splits.csv':
            stockSplits.loadFromJson(rawCsvStringToListOfJsonObjects(fileContent));
          case 'transactions.csv':
            transactions.loadFromJson(rawCsvStringToListOfJsonObjects(fileContent));
          case 'transaction_extras.csv':
            transactionExtras.loadFromJson(rawCsvStringToListOfJsonObjects(fileContent));
        }
      }
    }

    // Settings().fileManager.rememberWhereTheDataCameFrom(filePathToLoad);
  }

  String getZipSingleFileContent(ArchiveFile file) {
    try {
      List<int> fileBytes = file.content as List<int>;
      String fileContent = utf8.decode(fileBytes, allowMalformed: true);
      // Remove UTF-8 BOM if present
      fileContent = removeUtf8Bom(fileContent);
      return fileContent;
    } catch (_) {
      return '';
    }
  }

  List<MyJson> rawCsvStringToListOfJsonObjects(String fileContent) {
    List<MyJson> rows = [];
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

    // Create the ZIP archive
    Archive archive = Archive();

    // Add files to the archive
    writeEachFiles(archive);

    // Encode the archive to a byte array
    List<int> zipBytes = ZipEncoder().encode(archive)!;

    // Define the path to the ZIP file
    final String zipFileName = MyFileSystems.append(destinationFolder, mainFileName);
    File zipFile = File(zipFileName);

    // Write the ZIP file
    await zipFile.writeAsBytes(zipBytes);
    return zipFileName;
  }

  void writeEachFiles(Archive archive) {
    addCsvToArchive(archive, 'account_aliases.csv', accountAliases.toCSV());
    addCsvToArchive(archive, 'accounts.csv', accounts.toCSV());
    addCsvToArchive(archive, 'aliases.csv', aliases.toCSV());
    addCsvToArchive(archive, 'categories.csv', categories.toCSV());
    addCsvToArchive(archive, 'currencies.csv', currencies.toCSV());
    addCsvToArchive(archive, 'investments.csv', investments.toCSV());
    addCsvToArchive(archive, 'loan_payments.csv', loanPayments.toCSV());
    addCsvToArchive(archive, 'online_accounts.csv', onlineAccounts.toCSV());
    addCsvToArchive(archive, 'payees.csv', payees.toCSV());
    addCsvToArchive(archive, 'securities.csv', securities.toCSV());
    addCsvToArchive(archive, 'splits.csv', splits.toCSV());
    addCsvToArchive(archive, 'stock_splits.csv', stockSplits.toCSV());
    addCsvToArchive(archive, 'rent_units.csv', rentUnits.toCSV());
    addCsvToArchive(archive, 'rent_buildings.csv', rentBuildings.toCSV());
    addCsvToArchive(archive, 'rent_units.csv', rentUnits.toCSV());
    addCsvToArchive(archive, 'transaction_extras.csv', transactionExtras.toCSV());
    addCsvToArchive(archive, 'transactions.csv', transactions.toCSV());
  }

  addCsvToArchive(final Archive archive, final String filename, final textContent) {
    List<int> bytes = utf8.encode(textContent);
    archive.addFile(ArchiveFile(filename, bytes.length, bytes));
  }
}
