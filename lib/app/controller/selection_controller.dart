import 'package:get/get.dart';
export 'package:get/get.dart';

class SelectionController extends GetxController {
  static SelectionController get to => Get.find();
  // List to store the selected item IDs
  var selectedItems = <int>{}.obs;

  // Function to toggle selection
  void toggleSelection(int id) {
    if (selectedItems.contains(id)) {
      selectedItems.remove(id);
    } else {
      selectedItems.add(id);
    }
  }

  void select(int id) {
    selectedItems.clear();
    selectedItems.add(id);
  }

  // Function to check if an item is selected
  bool isSelected(int id) {
    return selectedItems.contains(id);
  }

  int firstSelectedId() {
    if (selectedItems.isEmpty) {
      return -1;
    }
    return selectedItems.first;
  }
}
