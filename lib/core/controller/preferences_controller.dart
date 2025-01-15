import 'package:get/get.dart';
import 'package:money/core/controller/data_controller.dart';
import 'package:money/core/helpers/json_helper.dart';
import 'package:money/data/models/constants.dart';
import 'package:money/data/models/fields/field_filter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller for managing application preferences and settings.
/// Handles:
/// - MRU (Most Recently Used) files
/// - View settings and filters
/// - Display options
/// - Feature flags
/// - Theme preferences
/// - Window state
/// - Font scaling
/// Uses SharedPreferences for persistence.
class PreferenceController extends GetxController {
  final RxBool isReady = false.obs;
  final RxBool useYahooStock = true.obs;

  Rx<BudgetViewAs> budgetViewAsForExpenses = BudgetViewAs.list.obs;
  Rx<BudgetViewAs> budgetViewAsForIncomes = BudgetViewAs.list.obs;
  RxInt cashflowRecurringOccurrences = 12.obs;
  Rx<CashflowViewAs> cashflowViewAs = CashflowViewAs.sankey.obs;

  ///---------------------------------
  /// Observable enum
  Rx<ViewId> currentView = ViewId.viewCashFlow.obs;

  RxList<String> mru = <String>[].obs;
  RxInt netWorthEventThreshold = 5.obs;
  Rx<bool> trendIncludeAssetAccounts = false.obs;

  final RxString _apiKeyForStocks = ''.obs;
  final RxBool _includeClosedAccounts = false.obs;

  ///---------------------------------
  /// Include Rental feature
  final RxBool _includeRentalManagement = false.obs;

  ///---------------------------------
  /// Hide/Show Info panel
  final RxBool _isDetailsPanelExpanded = false.obs;

  //////////////////////////////////////////////////////
  // Persistable user preference

  ///---------------------------------
  /// Text Font Size/Scale
  final RxDouble _textScale = 1.0.obs;

  SharedPreferences? _preferences;

  @override
  void onInit() async {
    super.onInit();
    await init();
    if (mru.isNotEmpty) {
      DataController dataController = Get.find();
      dataController.loadLastFileSaved();
    } else {
      // queue changing screen after app loaded
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.offNamed(Constants.routeWelcomePage);
      });
    }
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

  ///---------------------------------
  /// Stock quote API Key
  String get apiKeyForStocks => _apiKeyForStocks.value;

  ///---------------------------------
  set apiKeyForStocks(final String value) {
    _apiKeyForStocks.value = value;
    setString(settingKeyStockApiKey, value);
  }

  // Clear all values from preferences
  Future<void> clear() async {
    await _preferences?.clear();
  }

  // Retrieve a boolean value from preferences
  bool getBool(String key, [bool defaultValueIfNotFound = false]) {
    return _preferences?.getBool(key) ?? defaultValueIfNotFound;
  }

  // Retrieve a double value from preferences
  double getDouble(String key, [double defaultValueIfNotFound = 0.0]) {
    return _preferences?.getDouble(key) ?? defaultValueIfNotFound;
  }

  // Retrieve an integer value from preferences
  int getInt(String key, [int defaultValueIfNotFound = 0]) {
    return _preferences?.getInt(key) ?? defaultValueIfNotFound;
  }

  // Retrieve a string value from preferences
  String getString(String key, [String defaultValueIfNotFound = '']) {
    return _preferences?.getString(key) ?? defaultValueIfNotFound;
  }

  // Retrieve a list of strings from preferences
  Future<List<String>> getStringList(String key) async {
    return _preferences?.getStringList(key) ?? [];
  }

  String get getUniqueState =>
      'isReady:${isReady.value} Rental:$includeRentalManagement IncludeClosedAccounts:$includeClosedAccounts TextScale:$textScale';

  ///---------------------------------
  /// Show or Hide Account that are marked as Closed
  /// Hide/Show Closed Accounts
  bool get includeClosedAccounts => _includeClosedAccounts.value;

  set includeClosedAccounts(bool value) {
    _includeClosedAccounts.value = value;
    setBool(settingKeyIncludeClosedAccounts, value);
  }

  ///--------------------------------
  /// Rental
  bool get includeRentalManagement => _includeRentalManagement.value;

  set includeRentalManagement(final bool value) {
    _includeRentalManagement.value = value;
    setBool(settingKeyRentalsSupport, value);
  }

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    await loadDefaults();
    isReady.value = true;
  }

  RxBool get isDetailsPanelExpanded => _isDetailsPanelExpanded;

  set isDetailsPanelExpanded(value) {
    _isDetailsPanelExpanded.value = value;
    setBool(settingKeyDetailsPanelExpanded, value);
  }

  void jumpToView({
    required final ViewId viewId,
    required final int selectedId,
    final List<String> columnFilter = const [],
    final String textFilter = '',
  }) async {
    // First set all filters on the destination view
    await setString(viewId.getViewPreferenceId(settingKeyFilterText), textFilter);
    await setStringList(viewId.getViewPreferenceId(settingKeyFilterColumnsText), columnFilter);

    // Set the last selected item, in order to have it selected when the view changes
    if (selectedId != -1) {
      await setInt(viewId.getViewPreferenceId(settingKeySelectedListItemId), selectedId);
    }

    // Change to the requested view
    setView(viewId);
  }

  Future<void> loadDefaults() async {
    mru.value = _preferences!.getStringList(settingKeyMRU) ?? [];
    _isDetailsPanelExpanded.value = getBool(settingKeyDetailsPanelExpanded, false);
    _includeClosedAccounts.value = getBool(settingKeyIncludeClosedAccounts, false);
    _includeRentalManagement.value = getBool(settingKeyRentalsSupport, false);
    _apiKeyForStocks.value = getString(settingKeyStockApiKey, '');

    cashflowViewAs.value = CashflowViewAs.values[getInt(settingKeyCashflowView, CashflowViewAs.sankey.index)];
    budgetViewAsForIncomes.value = BudgetViewAs.values[getInt(settingKeyBudgetViewAsIncomes, BudgetViewAs.list.index)];
    budgetViewAsForExpenses.value =
        BudgetViewAs.values[getInt(settingKeyBudgetViewAsExpenses, BudgetViewAs.list.index)];
    cashflowRecurringOccurrences.value = getInt(settingKeyCashflowRecurringOccurrences, 12);
  }

  // Remove a value from preferences
  Future<void> remove(String key) async {
    await _preferences?.remove(key);
  }

  // Set a boolean value to preferences
  Future<void> setBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  // Set a double value to preferences
  Future<void> setDouble(String key, double value) async {
    await _preferences?.setDouble(key, value);
  }

  // Set an integer value to preferences
  Future<void> setInt(String key, int value) async {
    await _preferences?.setInt(key, value);
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

  // Set a list of strings to preferences
  Future<void> setStringList(String key, List<String> value) async {
    if (value.isEmpty) {
      remove(key);
    } else {
      await _preferences?.setStringList(key, value);
    }
  }

  // Methods to update the current view
  void setView(ViewId view) {
    currentView.value = view;
  }

  double get textScale => _textScale.value;

  set textScale(double value) {
    _textScale.value = value;
    setDouble(settingKeyTextScale, textScale);
  }

  static PreferenceController get to => Get.find();
}

/// Navigation helpers

void switchViewTransactionForPayee(final String payeeName) {
  FieldFilters fieldFilters = FieldFilters();
  fieldFilters.add(
    FieldFilter(
      fieldName: Constants.viewTransactionFieldNamePayee,
      strings: [payeeName],
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
  budget,
  trend,
}

enum BudgetViewAs {
  list,
  chart,
  recurrences,
  suggestions,
}
