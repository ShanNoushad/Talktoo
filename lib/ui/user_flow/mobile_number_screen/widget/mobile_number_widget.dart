import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:talk_in/ui/user_flow/mobile_number_screen/controller/mobile_number_controller.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

/// ── Back arrow ───────────────────────────────────────────────────────────────
class MobileNumberAppBarView extends StatelessWidget {
  const MobileNumberAppBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 0),
      child: GestureDetector(
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
    );
  }
}

/// ── Logo + title + subtitle ───────────────────────────────────────────────────
class MobileNumberDescriptionView extends StatelessWidget {
  const MobileNumberDescriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Center(
          child: Text(
            "TalkToo",
            style: AppFontStyle.fontStyleKaushanW400(
                fontSize: 62, fontColor: AppColors.black),
          ),
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          EnumLocale.txtLogInWithMobile.name.tr,
          style: AppFontStyle.fontStyleW600(
              fontSize: 20, fontColor: AppColors.black),
        ),
        const SizedBox(height: 6),

        // Subtitle
        Text(
          EnumLocale.txtMobileLoginDescription.name.tr,
          style: AppFontStyle.fontStyleW400(
              fontSize: 13, fontColor: AppColors.onBoardingTxt),
        ),
        const SizedBox(height: 28),

        // Field label
        Text(
          EnumLocale.txtEnterMobileNumber.name.tr,
          style: AppFontStyle.fontStyleW600(
              fontSize: 13, fontColor: AppColors.black),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

/// ── Phone input field ─────────────────────────────────────────────────────────
class MobileNumberOTPView extends StatelessWidget {
  const MobileNumberOTPView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MobileNumberController>(
      builder: (controller) {
        return Form(
          key: controller.formKey,
          child: IntlPhoneField(
            flagsButtonPadding: const EdgeInsets.all(8),
            flagsButtonMargin: const EdgeInsets.only(right: 13),
            dropdownIconPosition: IconPosition.trailing,
            controller: controller.numberController,
            obscureText: false,
            validator: (value) {
              if (value == null) {
                return EnumLocale.desEnterMobile.name.tr;
              }
              return null;
            },
            style: AppFontStyle.fontStyleW600(
              fontSize: 22,
              fontColor: AppColors.purple,
            ),
            cursorColor: AppColors.purple,
            dropdownTextStyle: AppFontStyle.fontStyleW700(
              fontSize: 16,
              fontColor: AppColors.black,
            ),
            pickerDialogStyle: PickerDialogStyle(
              countryCodeStyle: AppFontStyle.fontStyleW700(
                fontSize: 13,
                fontColor: AppColors.appColor,
              ),
              countryNameStyle: AppFontStyle.fontStyleW700(
                fontSize: 13,
                fontColor: AppColors.appColor,
              ),
              searchFieldCursorColor: AppColors.appColor,
              searchFieldInputDecoration: InputDecoration(
                hintStyle: AppFontStyle.fontStyleW400(
                  fontSize: 14,
                  fontColor: AppColors.grey,
                ),
                hintText: EnumLocale.txtSearchCountryCode.name.tr,
              ),
            ),
            dropdownIcon: const Icon(
              Icons.arrow_drop_down_outlined,
              color: Colors.black,
            ),
            keyboardType: TextInputType.number,
            showCountryFlag: false,
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFEEEDFE),
              hintStyle: AppFontStyle.fontStyleW400(
                fontSize: 18,
                fontColor: AppColors.onBoardingTxt,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                const BorderSide(color: Color(0xFF534AB7)),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                const BorderSide(color: Color(0xFF534AB7)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                    color: Color(0xFF534AB7), width: 1.5),
              ),
              errorStyle: AppFontStyle.fontStyleW500(
                fontSize: 8,
                fontColor: AppColors.red,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                BorderSide(color: AppColors.red, width: 1.5),
              ),
              counterStyle: AppFontStyle.fontStyleW500(
                fontSize: 9,
                fontColor: AppColors.grey,
              ),
            ),
            initialCountryCode: Database.selectedCountryCode,
            onCountryChanged: (value) {
              log("message================= ${value.code}");
              Database.onSetSelectedCountryCode(value.code);
              Database.getDialCode();
              log("Database.selectedCountryCode ================= ${Database.selectedCountryCode}");
            },
            onChanged: (phone) {
              controller.dialCode = phone.countryCode;
              controller.numberController.text = phone.number;
            },
          ),
        );
      },
    );
  }
}

/// ── Send OTP button ───────────────────────────────────────────────────────────
class MobileNumberButtonView extends StatelessWidget {
  const MobileNumberButtonView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MobileNumberController>(
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => controller.sendOtp(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: Text(
                EnumLocale.txtGetOtp.name.tr,
                style: AppFontStyle.fontStyleW600(
                    fontSize: 16, fontColor: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}