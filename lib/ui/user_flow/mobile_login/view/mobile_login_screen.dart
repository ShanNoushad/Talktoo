import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/font_style.dart';
import '../controller/otp_controller.dart' show MobileLoginController;

class MobileLoginScreen extends StatelessWidget {
  const MobileLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MobileLoginController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.lightGrey,
                    ),
                    child: const Icon(Icons.arrow_back, size: 18),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    "TalkToo",
                    style: AppFontStyle.fontStyleKaushanW400(
                        fontSize: 62, fontColor: AppColors.black),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "Mobile number",
                  style: AppFontStyle.fontStyleW600(
                      fontSize: 13, fontColor: AppColors.black),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.lightGrey,
                    hintText: '98765 43210',
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text('+91',
                              style: AppFontStyle.fontStyleW500(
                                  fontSize: 14,
                                  fontColor: AppColors.onBoardingTxt)),
                          const SizedBox(width: 8),
                          Container(width: 0.5, height: 20, color: Colors.grey),
                        ],
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter phone number';
                    }
                    if (value.length != 10) {
                      return 'Enter valid 10-digit number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  "We'll send a 6-digit verification code to this number.",
                  style: AppFontStyle.fontStyleW400(
                      fontSize: 12, fontColor: AppColors.onBoardingTxt),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => controller.onSendOtp(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      "Send OTP",
                      style: AppFontStyle.fontStyleW600(
                          fontSize: 16, fontColor: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}