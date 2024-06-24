import 'package:get/get.dart';
import 'package:money/app/modules/policies/policy_controller.dart';

class PolicyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PolicyController>(
      () => PolicyController(),
    );
  }
}
