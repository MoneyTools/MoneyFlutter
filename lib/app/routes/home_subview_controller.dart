import 'package:get/get.dart';
import 'package:money/app/data/models/constants.dart';

class SubViewController extends GetxController {
  // Observable enum
  var currentView = ViewId.viewCashFlow.obs;

  // Methods to update the current view
  void setView(ViewId view) {
    currentView.value = view;
  }
}
