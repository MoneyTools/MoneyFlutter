import 'package:get/get.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';
import 'package:money/app/data/models/settings.dart';
import 'package:money/app/data/storage/data/data.dart';

class DataController extends GetxController {
  // Observable variables
  RxBool isLoading = true.obs;
  RxList<String> data = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  // Async method to fetch data
  Future<void> load() async {
    try {
      isLoading.value = true;
      Settings().loadFileFromPath(Settings().fileManager.fullPathToLastOpenedFile);
      isLoading.value = false;
    } catch (e) {
      // Handle error
      debugLog("Error fetching data: $e");
      isLoading.value = false;
    }
  }

  Future<void> loadDemoData() async {
    isLoading.value = true;
    Settings().fileManager.fullPathToLastOpenedFile = '';
    Settings().preferrenceSave();
    Data().loadFromDemoData();
    isLoading.value = false;
  }
}
