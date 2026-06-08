import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_background/app_background.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/main_screen/controller/main_screen_controller.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class MainScreenView extends StatelessWidget {
  const MainScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainScreenController>(
      builder: (controller) {
        return AppBackground(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── App title ──────────────────────────────────────────
                  Center(
                    child: Text(
                      "TalkToo",
                      style: AppFontStyle.fontStyleKaushanW400(
                          fontSize: 62, fontColor: AppColors.black),
                    ),
                  ).paddingOnly(
                      bottom: Get.height * 0.035, top: Get.height * 0.10),

                  // ── Subtitle ───────────────────────────────────────────
                  Text(
                    "Welcome back",
                    style: AppFontStyle.fontStyleW600(
                        fontSize: 22, fontColor: AppColors.appDarkColor),
                  ).paddingOnly(bottom: 8),

                  Text(
                    "Sign in with your mobile number to continue.",
                    textAlign: TextAlign.center,
                    style: AppFontStyle.fontStyleW400(
                        fontSize: 14, fontColor: AppColors.onBoardingTxt),
                  ).paddingOnly(bottom: Get.height * 0.06),

                  // ── Mobile Login button ────────────────────────────────
                  PrimaryAppButton(
                    onTap: () {
                      if (controller.selectedValue != 1) {
                        Utils.showToast(Get.context!,
                            "Please agree to the Privacy Policy to proceed.");
                        return;
                      }
                      Get.toNamed(AppRoutes.mobileLogIn);
                    },
                    borderRadius: 60,
                    color: AppColors.purple,
                    height: Get.height * 0.068,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration:  BoxDecoration(
                              shape: BoxShape.circle, color: AppColors.white),
                          child:  Icon(Icons.phone_android,
                              color: AppColors.purple, size: 22),
                        ).paddingAll(4),
                        const Spacer(),
                        Text(
                          EnumLocale.txtMobileLogin.name.tr,
                          style: AppFontStyle.fontStyleW600(
                              fontSize: 16, fontColor: AppColors.white),
                        ).paddingOnly(right: 50),
                        const Spacer(),
                      ],
                    ),
                  ).paddingOnly(bottom: Get.height * 0.04),

                  // ── Privacy Policy checkbox ────────────────────────────
                  GetBuilder<MainScreenController>(
                    id: Constant.radioButton,
                    builder: (controller) {
                      final isSelected = controller.selectedValue == 1;
                      return GestureDetector(
                        onTap: () => controller.toggleValue(1),
                        child: Container(
                          color: AppColors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.appColor
                                        : AppColors.darkGrey,
                                    width: 1,
                                  ),
                                  color: isSelected
                                      ? AppColors.appColor
                                      : Colors.transparent,
                                ),
                                child: isSelected
                                    ? Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.appColor,
                                      shape: BoxShape.circle),
                                  child: Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.white),
                                      color: AppColors.appColor,
                                    ),
                                  ).paddingAll(0.5),
                                )
                                    : null,
                              ).paddingOnly(right: 8),
                              Text(
                                EnumLocale.txtAgreePrivacyPolicy.name.tr,
                                style: AppFontStyle.fontStyleW500(
                                    fontSize: 13,
                                    fontColor: AppColors.black),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    controller.onClickPrivacyPolicy(),
                                child: Text(
                                  " ${EnumLocale.txtPrivacyPolicy.name.tr}",
                                  style: AppFontStyle.fontStyleW500(
                                    decorationColor: AppColors.appColor,
                                    fontSize: 13,
                                    textDecoration:
                                    TextDecoration.underline,
                                    fontColor: AppColors.appColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).paddingOnly(top: 10, bottom: 6),
                      );
                    },
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