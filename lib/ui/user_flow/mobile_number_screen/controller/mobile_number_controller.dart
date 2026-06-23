import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/utils/utils.dart';
import '../../../../utils/twillio_api.dart';

class MobileNumberController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final numberController = TextEditingController();

  // ✅ Test bypass config
  static const String _bypassNumber = '2233344444';
  static const String _bypassDialCode = '+91';

  String? dialCode;

  @override
  void onInit() async {
    numberController.clear();
    super.onInit();
  }

  void sendOtp(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      Utils.showToast(context, "Enter a valid mobile number");
      return;
    }

    final number = numberController.text.trim();
    final code = dialCode ?? '+91';
    final phoneNumber = '$code$number';

    if (number.isEmpty) {
      Utils.showToast(context, "Please enter mobile number");
      return;
    }

    if (number.length < 7 || number.length > 15) {
      Utils.showToast(context, "Enter a valid mobile number");
      return;
    }

    // ✅ Bypass: skip Twilio and go directly to OTP screen
    if (number == _bypassNumber) {
      log('🔧 Test bypass triggered for number: $number');
      Get.toNamed(
        AppRoutes.verifyOtp,
        arguments: [number, code, phoneNumber],
      );
      return;
    }

    try {
      Get.dialog(LoadingWidget(), barrierDismissible: false);

      final success = await TwilioApi.sendOtp(phoneNumber: phoneNumber);

      Get.back(); // Close loading dialog

      if (success) {
        Get.toNamed(
          AppRoutes.verifyOtp,
          arguments: [number, code, phoneNumber],
        );
      } else {
        Utils.showToast(Get.context!, "OTP sending failed. Please try again.");
      }
    } catch (e) {
      Get.back();
      log('sendOtp error: $e');
      Utils.showToast(Get.context!, "OTP process failed: $e");
    }
  }
}