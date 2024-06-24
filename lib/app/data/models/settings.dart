// ignore_for_file: unnecessary_this

import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:money/app/routes/home_data_controller.dart';
import 'package:money/app/core/helpers/file_systems.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/fields/field_filter.dart';
import 'package:money/app/data/storage/data/data.dart';
import 'package:money/app/data/storage/data/data_mutations.dart';
import 'package:money/app/data/storage/file_manager.dart';
import 'package:money/app/data/storage/preferences_helper.dart';
import 'package:money/app/core/widgets/snack_bar.dart';

export 'package:money/app/data/storage/preferences_helper.dart';

class Settings extends GetxController {
  static final Settings _singleton = Settings._internal();

  factory Settings() {
    return _singleton;
  }

  Settings._internal();

  String get getUniqueState => '${Data().version}';

  PreferenceController getPref() {
    final PreferenceController preferenceController = Get.find();
    return preferenceController;
  }

  void rebuild() {
    update();
  }

  /// State for Preferences
  bool _isPreferenceLoaded = false;

  bool get isPreferenceLoaded => _isPreferenceLoaded;

  set isPreferenceLoaded(bool value) {
    _isPreferenceLoaded = value;
    rebuild();
  }

  bool isSmallScreen = true;

  /// What screen is selected
  ViewId _selectedScreen = ViewId.viewCashFlow;

  ViewId get selectedView => _selectedScreen;

  set selectedView(ViewId value) {
    _selectedScreen = value;
    rebuild();
    debugLog('selectedView $value');
  }

  FileManager fileManager = FileManager();

  /// Hide/Show Info panel
  bool _isDetailsPanelExpanded = false;

  bool get isDetailsPanelExpanded => _isDetailsPanelExpanded;

  set isDetailsPanelExpanded(bool value) {
    _isDetailsPanelExpanded = value;
    rebuild();
  }

  CashflowViewAs cashflowViewAs = CashflowViewAs.sankey;
  int cashflowRecurringOccurrences = 12;
  String apiKeyForStocks = '';

  //--------------------------------------------------------
  // Font scaling

  void fontScaleDecrease() {
    fontScaleDelta(-0.10);
  }

  void fontScaleIncrease() {
    fontScaleDelta(0.10);
  }

  void fontScaleMultiplyBy(final double factor) {
    setFontScaleTo(textScale * factor);
  }

  void fontScaleDelta(final double addOrSubtract) {
    setFontScaleTo(textScale + addOrSubtract);
  }

  bool setFontScaleTo(final double newScale) {
    final int cleanValue = (newScale * 100).round();
    if (isBetweenOrEqual(cleanValue, 40, 400)) {
      textScale = cleanValue / 100.0;
      preferrenceSave();
      rebuild();
      return true;
    }
    return false;
  }

  double textScale = 1.0;

  // Tracking changes
  final DataMutations trackMutations = DataMutations();

  Future<bool> preferrenceLoad() async {
    // await getPref().initPublic();
    textScale = getPref().getDouble(settingKeyTextScale, 1.0);

    cashflowViewAs = CashflowViewAs.values[
        intValueOrDefault(getPref().getInt(settingKeyCashflowView), defaultValueIfNull: CashflowViewAs.sankey.index)];
    cashflowRecurringOccurrences = getPref().getInt(settingKeyCashflowRecurringOccurrences, 12);
    apiKeyForStocks = getPref().getString(settingKeyStockApiKey, '');
    isDetailsPanelExpanded = getPref().getBool(settingKeyDetailsPanelExpanded) == true;
    fileManager.fullPathToLastOpenedFile = getPref().getString(settingKeyLastLoadedPathToDatabase);

    isPreferenceLoaded = true;
    return true;
  }

  void preferrenceSave() {
    getPref().setDouble(settingKeyTextScale, textScale);
    getPref().setInt(settingKeyCashflowView, cashflowViewAs.index);
    getPref().setInt(settingKeyCashflowRecurringOccurrences, cashflowRecurringOccurrences);
    getPref().setString(settingKeyStockApiKey, apiKeyForStocks);

    // last path to the source of data
    getPref().setString(settingKeyLastLoadedPathToDatabase, fileManager.fullPathToLastOpenedFile, true);
  }

  void closeFile([bool rebuild = true]) {
    this.fileManager.fullPathToLastOpenedFile = '';
    this.preferrenceSave();
    Data().close();
    this.trackMutations.reset();
  }

  void onFileNew() async {
    Settings().closeFile();

    Settings().fileManager.fileName = Constants.newDataFile;
    Settings().preferrenceSave();

    Data().accounts.addNewAccount('New Bank Account');
    Settings().selectedView = ViewId.viewAccounts;
    Settings().rebuild();
  }

  Future<void> loadFileFromPath(final DataSource dataSource) async {
    final DataController dataController = Get.find();
    dataController.loadFile(dataSource);
  }

  Future<void> onOpenDemoData() async {
    Settings().fileManager.fullPathToLastOpenedFile = '';
    Settings().preferrenceSave();
    final DataController dataController = Get.find();
    dataController.loadDemoData();
  }

  void onShowFileLocation() async {
    String path = await Settings().fileManager.generateNextFolderToSaveTo();
    openFolder(path);
  }

  void onSaveToCsv() async {
    final String fullPathToFileName = await Data().saveToCsv();
    Settings().fileManager.rememberWhereTheDataCameFrom(fullPathToFileName);
    Data().assessMutationsCountOfAllModels();
  }

  void onSaveToSql() async {
    if (Settings().fileManager.fullPathToLastOpenedFile.isEmpty) {
      // this happens if the user started with a new file and click save to SQL
      Settings().fileManager.fullPathToLastOpenedFile =
          await Settings().fileManager.defaultFolderToSaveTo('mymoney.mmdb');
    }

    Data().saveToSql(
        filePathToLoad: Settings().fileManager.fullPathToLastOpenedFile,
        callbackWhenLoaded: (final bool success, final String message) {
          if (success) {
            Data().assessMutationsCountOfAllModels();
          } else {
            SnackBarService.display(autoDismiss: false, message: message);
          }
        });

    Settings().fileManager.rememberWhereTheDataCameFrom(Settings().fileManager.fullPathToLastOpenedFile);
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

  Settings().getPref().setStringList(
        ViewId.viewTransactions.getViewPreferenceId(settingKeyFilterColumnsText),
        fieldFilters.toStringList(),
      );

  // Switch view
  Settings().selectedView = ViewId.viewTransactions;
}

enum CashflowViewAs {
  sankey,
  recurringIncomes,
  recurringExpenses,
}
