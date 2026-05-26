import 'package:get/get.dart';
import '../controller/otp_controller.dart';

class MobileLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MobileLoginController>(() => MobileLoginController());
  }
}