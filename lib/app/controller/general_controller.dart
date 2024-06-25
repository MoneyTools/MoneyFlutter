// ignore_for_file: unnecessary_this

import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:money/app/controller/data_controller.dart';
import 'package:money/app/core/helpers/file_systems.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/fields/field_filter.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/controller/preferences_controller.dart';
import 'package:money/app/core/widgets/snack_bar.dart';

export 'package:money/app/controller/preferences_controller.dart';

class GeneralController extends GetxController {
  static GeneralController get to => Get.find();

  static final GeneralController _singleton = GeneralController._internal();

  factory GeneralController() {
    return _singleton;
  }

  GeneralController._internal();

  String get getUniqueState => '${Data().version}';

  PreferenceController get ctlPref => Get.find();
  DataController get ctlData => Get.find();

  /// State for Preferences
  bool _isPreferenceLoaded = false;

  bool get isPreferenceLoaded => _isPreferenceLoaded;

  set isPreferenceLoaded(bool value) {
    _isPreferenceLoaded = value;
    update();
  }

  CashflowViewAs cashflowViewAs = CashflowViewAs.sankey;
  int cashflowRecurringOccurrences = 12;
  String apiKeyForStocks = '';

  Future<bool> preferrenceLoad() async {
    cashflowViewAs = CashflowViewAs.values[
        intValueOrDefault(ctlPref.getInt(settingKeyCashflowView), defaultValueIfNull: CashflowViewAs.sankey.index)];
    cashflowRecurringOccurrences = ctlPref.getInt(settingKeyCashflowRecurringOccurrences, 12);
    apiKeyForStocks = ctlPref.getString(settingKeyStockApiKey, '');

    isPreferenceLoaded = true;
    return true;
  }

  void preferrenceSave() {
    ctlPref.setInt(settingKeyCashflowView, cashflowViewAs.index);
    ctlPref.setInt(settingKeyCashflowRecurringOccurrences, cashflowRecurringOccurrences);
    ctlPref.setString(settingKeyStockApiKey, apiKeyForStocks);
  }

  void closeFile([bool rebuild = true]) {
    Data().close();
    ctlData.dataFileIsClosed();
    this.ctlData.trackMutations.reset();
  }

  void onFileNew() async {
    GeneralController().closeFile();

    Data().accounts.addNewAccount('New Bank Account');
    ctlPref.setView(ViewId.viewAccounts);
  }

  Future<void> loadFileFromPath(final DataSource dataSource) async {
    final DataController dataController = Get.find();
    dataController.loadFile(dataSource);
  }

  void onShowFileLocation() async {
    String path = await ctlData.generateNextFolderToSaveTo();
    showLocalFolder(path);
  }

  void onSaveToCsv() async {
    final String fullPathToFileName = await Data().saveToCsv();

    ctlPref.addToMRU(fullPathToFileName);

    Data().assessMutationsCountOfAllModels();
  }

  void onSaveToSql() async {
    String fileNameAndPath = ctlData.currentLoadedFileName.value;

    if (fileNameAndPath.isEmpty) {
      // this happens if the user started with a new file and click save to SQL
      fileNameAndPath = await ctlData.defaultFolderToSaveTo('mymoney.mmdb');
    }

    Data().saveToSql(
        filePathToLoad: fileNameAndPath,
        callbackWhenLoaded: (final bool success, final String message) {
          if (success) {
            Data().assessMutationsCountOfAllModels();
          } else {
            SnackBarService.displayError(autoDismiss: false, message: message);
          }
        });

    ctlPref.addToMRU(fileNameAndPath);
  }

  Future<bool> onFileOpen() async {
    FilePickerResult? pickerResult;

    const supportedFileTypes = <String>[
      'mmdb',
      'mmcsv',
      'sdf',
      'qfx',
      'ofx',
      'json',
    ];

    try {
      // WEB
      if (kIsWeb) {
        pickerResult = await FilePicker.platform.pickFiles(
          type: FileType.any,
        );
      } else
      // Mobile
      if (Platform.isAndroid || Platform.isIOS) {
        // See https://github.com/miguelpruivo/flutter_file_picker/issues/729
        pickerResult = await FilePicker.platform.pickFiles(type: FileType.any);
      } else
      // Desktop
      {
        pickerResult = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: supportedFileTypes,
        );
      }
    } catch (e) {
      debugLog(e.toString());
      SnackBarService.displayError(message: e.toString());
      return false;
    }

    if (pickerResult != null && pickerResult.files.isNotEmpty) {
      try {
        final String? fileExtension = pickerResult.files.single.extension;

        if (fileExtension == 'mmdb' || fileExtension == 'mmcsv') {
          DataSource dataSource = DataSource();
          if (kIsWeb) {
            PlatformFile file = pickerResult.files.first;
            dataSource.filePath = file.name;
            dataSource.fileBytes = file.bytes!;
          } else {
            dataSource.filePath = pickerResult.files.single.path ?? '';
          }
          final DataController dataController = Get.find();
          dataController.loadFile(dataSource);
          return true;
        }
      } catch (e) {
        debugLog(e.toString());
        SnackBarService.displayError(message: e.toString());
      }
    }
    return false;
  }
}

/// Navigation helpers

void switchViewTransacionnForPayee(final String payeeName) {
  FieldFilters fieldFilters = FieldFilters();
  fieldFilters.add(
      FieldFilter(fieldName: Constants.viewTransactionFieldnamePayee, filterTextInLowerCase: payeeName.toLowerCase()));

  PreferenceController.to.setStringList(
    ViewId.viewTransactions.getViewPreferenceId(settingKeyFilterColumnsText),
    fieldFilters.toStringList(),
  );

  // Switch view
  PreferenceController.to.setView(ViewId.viewTransactions);
}

enum CashflowViewAs {
  sankey,
  recurringIncomes,
  recurringExpenses,
}
