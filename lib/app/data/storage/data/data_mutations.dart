import 'package:get/get.dart';

/// Tracking changes of data
class DataMutations extends GetxController {
  static DataMutations get to => Get.find();

  RxInt added = 0.obs;
  RxInt changed = 0.obs;
  RxInt deleted = 0.obs;

  int numberOfChanges() {
    return added.value + changed.value + deleted.value;
  }

  /// Indicate of any data has changed Added or Deleted
  bool hasChanged() {
    return numberOfChanges() > 0;
  }

  void increaseNumber({
    int increaseAdded = 0,
    int increaseChanged = 0,
    int increaseDeleted = 0,
  }) {
    added += increaseAdded;
    changed += increaseChanged;
    deleted += increaseDeleted;
  }

  void reset() {
    added.value = 0;
    changed.value = 0;
    deleted.value = 0;
  }
}
