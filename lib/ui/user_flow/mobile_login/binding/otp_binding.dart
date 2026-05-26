import 'package:get/get.dart';
import '../controller/mobile_login_controller.dart';
import '../controller/otp_controller.dart';

class OtpBinding extends Bindings {
  @override
  void dependencies() {
    // Keep MobileLoginController alive so Resend can call onSendOtp()
    Get.lazyPut<MobileLoginController>(
          () => MobileLoginController(),
      fenix: true, // recreate if GC'd
    );
    Get.lazyPut<OtpController>(() => OtpController());
  }
}