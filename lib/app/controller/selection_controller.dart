import 'package:get/get.dart';
import 'package:money/app/controller/preferences_controller.dart';
export 'package:get/get.dart';

// List the selected item IDs, optionally can be persisted and loaded in Preferrences
class SelectionController extends GetxController {
  SelectionController([this.preferenceKeyForPersitingSelections = '']) {
    if (preferenceKeyForPersitingSelections.isNotEmpty) {
      load();
    }
  }

  String preferenceKeyForPersitingSelections = '';
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
    if (preferenceKeyForPersitingSelections.isNotEmpty) {
      final lastSelectionId = PreferenceController.to.getInt(preferenceKeyForPersitingSelections, -1);
      select(lastSelectionId);
    }
  }

  void save() {
    if (preferenceKeyForPersitingSelections.isNotEmpty) {
      PreferenceController.to.setInt(preferenceKeyForPersitingSelections, firstSelectedId);
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
