import 'package:get/get.dart';
import 'package:money/app/controller/preferences_controller.dart';
export 'package:get/get.dart';

// List the selected item IDs, optionally can be persisted and loaded in Preferences
class SelectionController extends GetxController {
  SelectionController([this.preferenceKeyForPersistingSelections = '']) {
    if (preferenceKeyForPersistingSelections.isNotEmpty) {
      load();
    }
  }

  String preferenceKeyForPersistingSelections = '';
  RxSet<int> selectedItems = <int>{}.obs;

  int get firstSelectedId {
    if (selectedItems.isEmpty) {
      return -1;
    }
    return selectedItems.first;
  }

  // Function to check if an item is selected
  bool isSelected(int id) {
    return selectedItems.contains(id);
  }

  void load() {
    if (preferenceKeyForPersistingSelections.isNotEmpty) {
      final lastSelectionId = PreferenceController.to.getInt(preferenceKeyForPersistingSelections, -1);
      select(lastSelectionId);
    }
  }

  void save() {
    if (preferenceKeyForPersistingSelections.isNotEmpty) {
      PreferenceController.to.setInt(preferenceKeyForPersistingSelections, firstSelectedId);
    }
  }

  void select(int id) {
    selectedItems.clear();
    if (id != -1) {
      selectedItems.add(id);
    }
    save();
  }

  static SelectionController get to => Get.find();

  // Function to toggle selection
  void toggleSelection(int id) {
    if (selectedItems.contains(id)) {
      selectedItems.remove(id);
    } else {
      selectedItems.add(id);
    }
  }
}
