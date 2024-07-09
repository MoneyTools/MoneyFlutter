import 'package:get/get.dart';

class SelectionController extends GetxController {
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

  // Function to check if an item is selected
  bool isSelected(int id) {
    return selectedItems.contains(id);
  }
}
