import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(
              color: const Color(0xFF7C4DFF),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.arrow_back,
            size: 18,
            color: Colors.white,
          ),
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
        // ── "Talktoo" logo ─────────────────────────────────────────────
        Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Talk',
                  style: GoogleFonts.nunito(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: 'too',
                  style: GoogleFonts.nunito(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 40),

        // ── "Log In" white ─────────────────────────────────────────────
        Text(
          'Log In',
          style: GoogleFonts.nunito(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),

        // ── "With Mobile" purple ───────────────────────────────────────
        Text(
          'With Mobile',
          style: GoogleFonts.nunito(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF9C27B0),
          ),
        ),

        const SizedBox(height: 12),

        // ── Subtitle ───────────────────────────────────────────────────
        Text(
          'Enter your mobile number to\nreceive a one-time password.',
          style: AppFontStyle.fontStyleW400(
            fontSize: 14,
            fontColor: const Color(0xFF9E9E9E),
          ),
        ),

        const SizedBox(height: 36),

        // ── Field label ────────────────────────────────────────────────
        Text(
          'Mobile Number',
          style: AppFontStyle.fontStyleW600(
            fontSize: 14,
            fontColor: Colors.white,
          ),
        ),

        const SizedBox(height: 8),
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
            flagsButtonPadding: const EdgeInsets.symmetric(horizontal: 12),
            flagsButtonMargin: EdgeInsets.zero,
            dropdownIconPosition: IconPosition.trailing,
            controller: controller.numberController,
            obscureText: false,
            validator: (value) {
              if (value == null) {
                return EnumLocale.desEnterMobile.name.tr;
              }
              return null;
            },
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            cursorColor: const Color(0xFF9C27B0),
            dropdownTextStyle: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            pickerDialogStyle: PickerDialogStyle(
              backgroundColor: const Color(0xFF12102A),
              countryCodeStyle: AppFontStyle.fontStyleW700(
                fontSize: 13,
                fontColor: const Color(0xFF9C27B0),
              ),
              countryNameStyle: AppFontStyle.fontStyleW700(
                fontSize: 13,
                fontColor: Colors.white,
              ),
              searchFieldCursorColor: const Color(0xFF9C27B0),
              searchFieldInputDecoration: InputDecoration(
                hintStyle: AppFontStyle.fontStyleW400(
                  fontSize: 14,
                  fontColor: Colors.white38,
                ),
                hintText: EnumLocale.txtSearchCountryCode.name.tr,
              ),
            ),
            dropdownIcon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.white54,
              size: 22,
            ),
            keyboardType: TextInputType.number,
            showCountryFlag: false,
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Enter mobile number',
              filled: true,
              fillColor: const Color(0xFF0D0B1E),
              hintStyle: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.white24,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF7C4DFF),
                  width: 1.5,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF7C4DFF),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF00BCD4),
                  width: 1.8,
                ),
              ),
              errorStyle: AppFontStyle.fontStyleW500(
                fontSize: 10,
                fontColor: AppColors.red,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.red, width: 1.8),
              ),
            ),
            initialCountryCode: Database.selectedCountryCode,
            onCountryChanged: (value) {
              log("Country changed: ${value.code}");
              Database.onSetSelectedCountryCode(value.code);
              Database.getDialCode();
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
          padding: const EdgeInsets.only(bottom: 32),
          child: GestureDetector(
            onTap: () => controller.sendOtp(context),
            child: Container(
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7B2FBE),
                    Color(0xFF9C27B0),
                    Color(0xFF6A0DAD),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                // Neon glow effect
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Get OTP',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}