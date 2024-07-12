import 'package:get/get.dart';
import 'package:money/app/core/helpers/misc_helpers.dart';

class HomeController extends GetxController {
  @override
  void onClose() {
    super.onClose();
    debugLog('Closed!');
  }

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
}
