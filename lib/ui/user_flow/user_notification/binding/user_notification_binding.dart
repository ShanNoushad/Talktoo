import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/user_notification/controller/user_notification_controller.dart';

class UserNotificationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<UserNotificationController>()) {
      Get.put<UserNotificationController>(UserNotificationController(), permanent: true);
    }
  }
}