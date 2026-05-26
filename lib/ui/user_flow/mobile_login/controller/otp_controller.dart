import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/utils/utils.dart';

class MobileLoginController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Hardcoded for now — swap with a country picker if needed
  final String dialCode = '+91';

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  Future<void> onSendOtp() async {
    if (!formKey.currentState!.validate()) return;

    Get.dialog(const LoadingWidget(), barrierDismissible: false);

    final fullPhone = '$dialCode${phoneController.text.trim()}';

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: fullPhone,
      timeout: const Duration(seconds: 60),

      // Android auto-verify
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (Get.isDialogOpen ?? false) Get.back();
        // Auto-verified — you can sign in silently here if needed
      },

      verificationFailed: (FirebaseAuthException e) {
        if (Get.isDialogOpen ?? false) Get.back();
        Utils.showToast(Get.context!, e.message ?? 'Verification failed');
      },

      codeSent: (String verificationId, int? resendToken) {
        if (Get.isDialogOpen ?? false) Get.back();

        // Pass all 3 args as a List so OtpController can read them
        Get.toNamed(
          AppRoutes.verifyOtp,
          arguments: [
            phoneController.text.trim(), // [0] — shown on OTP screen
            dialCode,                    // [1] — used to build mobileNumber
            verificationId,              // [2] — critical for credential
          ],
        );
      },

      codeAutoRetrievalTimeout: (String verificationId) {
        // timeout — nothing to do in UI
      },
    );
  }
}