part of 'data.dart';

const String mainFileName = 'mymoney.mmcsv';
const String subFolderName = 'mymoney_csv_files';

extension DataFromCsv on Data {
  Future<void> loadFromZippedCsv(
    String filePathToLoad,
    final Uint8List fileBytes,
  ) async {
    // Decode the ZIP file
    late Archive archive;
    if (fileBytes.isNotEmpty) {
      archive = ZipDecoder().decodeBytes(fileBytes);
    } else {
      File file = File(filePathToLoad);
      List<int> bytes = await file.readAsBytes();
      archive = ZipDecoder().decodeBytes(bytes);
    }
    loadFromArchive(archive);
  }

  void loadFromArchive(final Archive archive) {
    // Extract the files and read the content
    for (ArchiveFile file in archive) {
      if (file.isFile) {
        String fileContent = getZipSingleFileContent(file);

        final String fileNameInLowercase = MyFileSystems.getFileName(file.name).toLowerCase();

        switch (fileNameInLowercase) {
          case 'account_aliases.csv':
            accountAliases.loadFromJson(
              convertFromRawCsvTextToListOfJSonObject(fileContent),
            );
          case 'accounts.csv':
            accounts.loadFromJson(
              convertFromRawCsvTextToListOfJSonObject(fileContent),
            );
          case 'aliases.csv':
            aliases.loadFromJson(
              convertFromRawCsvTextToListOfJSonObject(fileContent),
            );
          case 'categories.csv':
            categories.loadFromJson(
              convertFromRawCsvTextToListOfJSonObject(fileContent),
            );
          case 'investments.csv':
            investments.loadFromJson(
              convertFromRawCsvTextToListOfJSonObject(fileContent),
            );
          case 'loan_payments.csv':
            loanPayments.loadFromJson(
              convertFromRawCsvTextToListOfJSonObject(fileContent),
            );
          case 'online_accounts.csv':
            onlineAccounts.loadFromJson(
              convertFromRawCsvTextToListOfJSonObject(fileContent),
            );
          case 'payees.csv':
            payees.loadFromJson(
              convertFromRawCsvTextToListOfJSonObject(fileContent),
            );
          case 'rent_buildings.csv':
            rentBuildings.loadFromJson(
              convertFromRawCsvTextToListOfJSonObject(fileContent),
            );
          case 'rent_units.csv':
            rentUnits.loadFromJson(
              convertFromRawCsvTextToListOfJSonObject(fileContent),
            );
          case 'securities.csv':
            securities.loadFromJson(
              convertFromRawCsvTextToListOfJSonObject(fileContent),
            );
          case 'splits.csv':
            splits.loadFromJson(
              convertFromRawCsvTextToListOfJSonObject(fileContent),
            );
          case 'stock_splits.csv':
            stockSplits.loadFromJson(
              convertFromRawCsvTextToListOfJSonObject(fileContent),
            );
          case 'transactions.csv':
            transactions.loadFromJson(
              convertFromRawCsvTextToListOfJSonObject(fileContent),
            );
          case 'transaction_extras.csv':
            transactionExtras.loadFromJson(
              convertFromRawCsvTextToListOfJSonObject(fileContent),
            );
          case 'events.csv':
            events.loadFromJson(
              convertFromRawCsvTextToListOfJSonObject(fileContent),
            );
        }
      }
    }
  }

  String getZipSingleFileContent(ArchiveFile file) {
    try {
      List<int> fileBytes = file.content as List<int>;
      String fileContent = utf8.decode(fileBytes, allowMalformed: true);
      // Remove UTF-8 BOM if present
      fileContent = removeUtf8Bom(fileContent);
      return fileContent;
    } catch (e) {
      logger.e(e.toString());
      return '';
    }
  }

  Future<String> saveToCsv() async {
    String destinationFolder = await DataController.to.generateNextFolderToSaveTo();
    if (destinationFolder.isEmpty) {
      throw Exception('No container folder give for saving');
    }

    // Define the path to the ZIP file
    final String zipFileName = MyFileSystems.append(destinationFolder, mainFileName);
    File zipFile = File(zipFileName);

    // Create the ZIP archive
    List<int> zipBytes = getCsvZipAchieveListOfInt();
    // Write the ZIP file
    await zipFile.writeAsBytes(zipBytes);
    return zipFileName;
  }

  List<int> getCsvZipAchieveListOfInt() {
    // Create the ZIP archive
    Archive archive = Archive();

    // Add files to the archive
    writeEachFiles(archive);
    // Encode the archive to a byte array
    List<int> zipBytes = ZipEncoder().encode(archive)!;
    return zipBytes;
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
    addCsvToArchive(archive, 'events.csv', events.toCSV());
    addCsvToArchive(
      archive,
      'transaction_extras.csv',
      transactionExtras.toCSV(),
    );
    addCsvToArchive(archive, 'transactions.csv', transactions.toCSV());
  }

  void addCsvToArchive(
    final Archive archive,
    final String filename,
    final textContent,
  ) {
    List<int> bytes = utf8.encode(textContent);
    archive.addFile(ArchiveFile(filename, bytes.length, bytes));
  }
}
