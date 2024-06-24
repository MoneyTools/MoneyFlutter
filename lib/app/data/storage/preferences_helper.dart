import 'dart:convert';

import 'package:money/app/core/helpers/json_helper.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/modules/home/home_data_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:get/get.dart';
import 'package:money/app/data/models/constants.dart';

class PreferenceController extends GetxController {
  final RxBool isReady = false.obs;

  SharedPreferences? _preferences;

  RxList<String> mru = <String>[].obs;

  String get getUniqueState =>
      'isReadry:${isReady.value} Rental:$includeRentalManagement IncludeClosedAccounts:$includeClosedAccounts';

  // User choices

  // Show or Hide Account that are marked as Closed
  /// Hide/Show Closed Accounts
  final RxBool _includeClosedAccounts = false.obs;

  bool get includeClosedAccounts => _includeClosedAccounts.value;

  set includeClosedAccounts(bool value) {
    _includeClosedAccounts.value = value;
    setBool(settingKeyRentalsSupport, value);
  }

  // Incude Rental feature
  final RxBool _includeRentalManagement = false.obs;

  bool get includeRentalManagement => _includeRentalManagement.value;

  set includeRentalManagement(bool value) {
    _includeRentalManagement.value = value;
    setBool(settingKeyRentalsSupport, value);
  }

  @override
  void onInit() async {
    debugLog('PrefereceContoller.onInit()');
    super.onInit();
    await initPrefs();
  }

  Future<void> initPrefs() async {
    _preferences = await SharedPreferences.getInstance();

    await loadDefaults();

    isReady.value = true;

    if (mru.isNotEmpty) {
      debugLog('PrefereceContoller.loadLastFile');
      DataController dataController = Get.find();
      dataController.loadLastFileSaved();
    } else {
      // queue changing screen after app loaded
      Future.delayed(const Duration(milliseconds: 100), () {
        debugLog('PrefereceContoller.routeWelcomePage');
        Get.offNamed(Constants.routeWelcomePage);
      });
    }
  }

  Future<void> loadDefaults() async {
    mru.value = _preferences!.getStringList(settingKeyMRU) ?? [];
    _includeClosedAccounts.value = getBool(settingKeyIncludeClosedAccounts, false);
    _includeRentalManagement.value = getBool(settingKeyRentalsSupport, false);
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
  Future<void> setString(String key, String value, [bool removeIfEmpty = false]) async {
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
        final Map<String, MyJson> resultMap =
            parsedMap.map((final String key, final dynamic value) => MapEntry<String, MyJson>(key, value as MyJson));

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
