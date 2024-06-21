// ignore_for_file: unnecessary_this

import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:money/app/routes/home_data_controller.dart';
import 'package:money/helpers/file_systems.dart';
import 'package:money/helpers/misc_helpers.dart';
import 'package:money/models/constants.dart';
import 'package:money/models/fields/field_filter.dart';
import 'package:money/storage/data/data.dart';
import 'package:money/storage/data/data_mutations.dart';
import 'package:money/storage/file_manager.dart';
import 'package:money/storage/preferences_helper.dart';
import 'package:money/app/core/widgets/snack_bar.dart';

class Settings extends ChangeNotifier {
  String getUniqueSate() {
    return '${Data().version} $includeClosedAccounts $includeRentalManagement';
  }

  void rebuild() {
    notifyListeners();
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

  /// Support Rental Management
  bool _rentals = false;

  bool get includeRentalManagement => _rentals;

  set includeRentalManagement(bool value) {
    _rentals = value;
    rebuild();
  }

  /// Hide/Show Closed Accounts
  bool _includeClosedAccounts = false;

  bool get includeClosedAccounts => _includeClosedAccounts;

  set includeClosedAccounts(bool value) {
    _includeClosedAccounts = value;
    Settings().preferrenceSave();
    rebuild();
  }

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

  static final Settings _singleton = Settings._internal();

  factory Settings() {
    return _singleton;
  }

  Settings._internal();

  Future<bool> preferrenceLoad() async {
    final PreferencesHelper preferences = await PreferencesHelper.init();

    textScale = doubleValueOrDefault(preferences.getDouble(settingKeyTextScale), defaultValueIfNull: 1.0);

    includeRentalManagement = preferences.getBool(settingKeyRentalsSupport) == true;
    cashflowViewAs = CashflowViewAs.values[
        intValueOrDefault(preferences.getInt(settingKeyCashflowView), defaultValueIfNull: CashflowViewAs.sankey.index)];
    cashflowRecurringOccurrences =
        intValueOrDefault(preferences.getInt(settingKeyCashflowRecurringOccurrences), defaultValueIfNull: 12);
    _includeClosedAccounts = preferences.getBool(settingKeyIncludeClosedAccounts) == true;
    apiKeyForStocks = preferences.getString(settingKeyStockApiKey) ?? '';

    isDetailsPanelExpanded = preferences.getBool(settingKeyDetailsPanelExpanded) == true;
    fileManager.fullPathToLastOpenedFile = preferences.getString(settingKeyLastLoadedPathToDatabase) ?? '';
    fileManager.mru = preferences.getStringList(settingKeyMRU) ?? [];

    isPreferenceLoaded = true;
    return true;
  }

  Future<void> preferrenceSave() async {
    final PreferencesHelper preferences = PreferencesHelper();
    await preferences.setDouble(settingKeyTextScale, textScale);
    await preferences.setInt(settingKeyCashflowView, cashflowViewAs.index);
    await preferences.setInt(settingKeyCashflowRecurringOccurrences, cashflowRecurringOccurrences);
    await preferences.setBool(settingKeyIncludeClosedAccounts, includeClosedAccounts);
    await preferences.setBool(settingKeyRentalsSupport, includeRentalManagement);
    await preferences.setString(settingKeyStockApiKey, apiKeyForStocks);

    // last path to the source of data
    await preferences.setString(settingKeyLastLoadedPathToDatabase, fileManager.fullPathToLastOpenedFile, true);
    await preferences.setStringList(settingKeyMRU, fileManager.mru);
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

  Future<void> loadFileFromPath(final String path) async {
    closeFile(false); // ensure that we closed current file and state

    Timer(const Duration(milliseconds: 200), () async {
      await Data().loadFromPath(filePathToLoad: path).then((final bool success) {
        // if (success) {

        // Settings().rebuild();
        // }
      });
      // this.rebuild();
    });
  }

  Future<void> onOpenDemoData() async {
    Settings().fileManager.fullPathToLastOpenedFile = '';
    Settings().preferrenceSave();
    final DataController dataController = Get.put(DataController());
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
    }

    if (pickerResult != null && pickerResult.files.isNotEmpty) {
      try {
        final String? fileExtension = pickerResult.files.single.extension;

        if (fileExtension == 'mmdb' || fileExtension == 'mmcsv') {
          if (kIsWeb) {
            PlatformFile file = pickerResult.files.first;

            Settings().fileManager.fullPathToLastOpenedFile = file.name;
            Settings().fileManager.fileBytes = file.bytes!;
          } else {
            Settings().fileManager.fullPathToLastOpenedFile = pickerResult.files.single.path ?? '';
          }
          if (Settings().fileManager.fullPathToLastOpenedFile.isNotEmpty) {
            Settings().preferrenceSave();
            // _loadDataFromLastKnownFilePath();
            return true;
          }
        }
      } catch (e) {
        debugLog(e.toString());
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

  PreferencesHelper().setStringList(
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
