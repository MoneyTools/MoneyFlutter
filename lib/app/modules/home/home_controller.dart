import 'package:get/get.dart';
import 'package:money/helpers/misc_helpers.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController.

  @override
  void onInit() {
    super.onInit();
    debugLog('Load Data');
  }

  @override
  void onReady() {
    super.onReady();
    debugLog('Ready!');
  }

  @override
  void onClose() {
    super.onClose();
    debugLog('Closed!');
  }
}
