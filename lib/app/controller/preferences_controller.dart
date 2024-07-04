import 'dart:convert';

import 'package:get/get.dart';
import 'package:money/app/controller/data_controller.dart';
import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/data/models/constants.dart';
import 'package:money/app/data/models/fields/field_filter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceController extends GetxController {
  static PreferenceController get to => Get.find();

  final RxBool isReady = false.obs;

  SharedPreferences? _preferences;

  RxList<String> mru = <String>[].obs;

  String get getUniqueState =>
      'isReadry:${isReady.value} Rental:$includeRentalManagement IncludeClosedAccounts:$includeClosedAccounts TextScale:$textScale';

  //////////////////////////////////////////////////////
  // Persistable user preference

  ///---------------------------------
  /// Text Font Size/Scale
  final RxDouble _textScale = 1.0.obs;

  double get textScale => _textScale.value;

  set textScale(double value) {
    _textScale.value = value;
    setDouble(settingKeyTextScale, textScale);
  }

  ///---------------------------------
  /// Hide/Show Info panel
  final RxBool _isDetailsPanelExpanded = false.obs;
  RxBool get isDetailsPanelExpanded => _isDetailsPanelExpanded;
  set isDetailsPanelExpanded(value) {
    _isDetailsPanelExpanded.value = value;
    setBool(settingKeyDetailsPanelExpanded, value);
  }

  ///---------------------------------
  /// Show or Hide Account that are marked as Closed
  /// Hide/Show Closed Accounts
  final RxBool _includeClosedAccounts = false.obs;

  bool get includeClosedAccounts => _includeClosedAccounts.value;

  set includeClosedAccounts(bool value) {
    _includeClosedAccounts.value = value;
    setBool(settingKeyRentalsSupport, value);
  }

  ///---------------------------------
  /// Incude Rental feature
  final RxBool _includeRentalManagement = false.obs;

  bool get includeRentalManagement => _includeRentalManagement.value;

  set includeRentalManagement(bool value) {
    _includeRentalManagement.value = value;
    setBool(settingKeyRentalsSupport, value);
  }

  ///---------------------------------
  /// Observable enum
  Rx<ViewId> currentView = ViewId.viewCashFlow.obs;

  // Methods to update the current view
  void setView(ViewId view) {
    currentView.value = view;
  }

  void jumpToView(final ViewId viewId, final int selectedId) async {
    // First reset all filters on that view
    await setString(viewId.getViewPreferenceId(settingKeyFilterText), '');
    await setStringList(viewId.getViewPreferenceId(settingKeyFilterColumnsText), []);

    // Set the last selected item, in order to have it selected when the view changes
    await setInt(viewId.getViewPreferenceId(settingKeySelectedListItemId), selectedId);

    // Change to the requested view
    setView(viewId);
  }

  ///---------------------------------
  //
  RxString apiKeyForStocks = ''.obs;
  RxInt cashflowRecurringOccurrences = 12.obs;
  Rx<CashflowViewAs> cashflowViewAs = CashflowViewAs.sankey.obs;

  @override
  void onInit() async {
    super.onInit();
    await initPrefs();
    if (mru.isNotEmpty) {
      // debugLog('PrefereceContoller.loadLastFile');
      DataController dataController = Get.find();
      dataController.loadLastFileSaved();
    } else {
      // queue changing screen after app loaded
      Future.delayed(const Duration(milliseconds: 100), () {
        // debugLog('PrefereceContoller.routeWelcomePage');
        Get.offNamed(Constants.routeWelcomePage);
      });
    }
  }

  Future<void> initPrefs() async {
    _preferences = await SharedPreferences.getInstance();
    await loadDefaults();
    isReady.value = true;
  }

  Future<void> loadDefaults() async {
    mru.value = _preferences!.getStringList(settingKeyMRU) ?? [];
    _isDetailsPanelExpanded.value = getBool(settingKeyDetailsPanelExpanded, false);
    _includeClosedAccounts.value = getBool(settingKeyIncludeClosedAccounts, false);
    _includeRentalManagement.value = getBool(settingKeyRentalsSupport, false);

    cashflowViewAs.value = CashflowViewAs.values[getInt(settingKeyCashflowView, CashflowViewAs.sankey.index)];
    cashflowRecurringOccurrences.value = getInt(settingKeyCashflowRecurringOccurrences, 12);
    apiKeyForStocks.value = getString(settingKeyStockApiKey, '');
  }

  void addToMRU(String filePathAndName) {
    if (filePathAndName.isNotEmpty) {
      // load and place on top
      mru.remove(filePathAndName);
      mru.insert(0, filePathAndName);

      // save it
      if (_preferences != null) {
        _preferences!.setStringList(settingKeyMRU, mru);
      }
    }
  }

  // Set a string value to preferences
  Future<void> setString(
    String key,
    String value, [
    bool removeIfEmpty = false,
  ]) async {
    if (removeIfEmpty && value.isEmpty) {
      await remove(key);
    } else {
      await _preferences?.setString(key, value);
    }
  }

  // Retrieve a string value from preferences
  String getString(String key, [String defaultValueIfNotFound = '']) {
    return _preferences?.getString(key) ?? defaultValueIfNotFound;
  }

  // Set an integer value to preferences
  Future<void> setInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  // Retrieve an integer value from preferences
  int getInt(String key, [int defaultValueIfNotFound = 0]) {
    return _preferences?.getInt(key) ?? defaultValueIfNotFound;
  }

  // Set a boolean value to preferences
  Future<void> setBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  // Retrieve a boolean value from preferences
  bool getBool(String key, [bool defaultValueIfNotFound = false]) {
    return _preferences?.getBool(key) ?? defaultValueIfNotFound;
  }

  // Set a double value to preferences
  Future<void> setDouble(String key, double value) async {
    await _preferences?.setDouble(key, value);
  }

  // Retrieve a double value from preferences
  double getDouble(String key, [double defaultValueIfNotFound = 0.0]) {
    return _preferences?.getDouble(key) ?? defaultValueIfNotFound;
  }

  // Set a list of strings to preferences
  Future<void> setStringList(String key, List<String> value) async {
    if (value.isEmpty) {
      remove(key);
    } else {
      await _preferences?.setStringList(key, value);
    }
  }

  // Retrieve a list of strings from preferences
  Future<List<String>> getStringList(String key) async {
    return _preferences?.getStringList(key) ?? [];
  }

  // Retrieve a MyJson object value from preferences
  Future<Map<String, MyJson>> getMapOfMyJson(final String key) async {
    try {
      final String? serializedMap = _preferences?.getString(key);
      if (serializedMap != null) {
        // first deserialize
        final MyJson parsedMap = json.decode(serializedMap) as MyJson;

        // second to JSon map
        final Map<String, MyJson> resultMap = parsedMap.map(
          (final String key, final dynamic value) => MapEntry<String, MyJson>(key, value as MyJson),
        );

        return resultMap;
      }
    } catch (_) {
      //
    }

    return <String, MyJson>{};
  }

  Future<void> setMapOfMyJson(
    final String key,
    final Map<String, MyJson> mapOfJson,
  ) async {
    _preferences?.setString(key, json.encode(mapOfJson));
  }

  Future<void> setMyJson(
    final String key,
    final MyJson myJson,
  ) async {
    _preferences?.setString(key, json.encode(myJson));
  }

  // Remove a value from preferences
  Future<void> remove(String key) async {
    await _preferences?.remove(key);
  }

  // Clear all values from preferences
  Future<void> clear() async {
    await _preferences?.clear();
  }
}

/// Navigation helpers

void switchViewTransacionnForPayee(final String payeeName) {
  FieldFilters fieldFilters = FieldFilters();
  fieldFilters.add(
    FieldFilter(
      fieldName: Constants.viewTransactionFieldnamePayee,
      filterTextInLowerCase: payeeName.toLowerCase(),
    ),
  );

  PreferenceController.to.setStringList(
    ViewId.viewTransactions.getViewPreferenceId(settingKeyFilterColumnsText),
    fieldFilters.toStringList(),
  );

  // Switch view
  PreferenceController.to.setView(ViewId.viewTransactions);
}

enum CashflowViewAs {
  sankey,
  netWorthOverTime,
  recurringIncomes,
  recurringExpenses,
}
