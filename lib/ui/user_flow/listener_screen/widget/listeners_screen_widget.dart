import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/listener_screen/controller/listeners_screen_controller.dart';
import 'package:talk_in/ui/user_flow/listener_screen/widget/app_language_bottom_sheet.dart';
import 'package:talk_in/ui/user_flow/listener_screen/widget/talk_about_bottom_sheet.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class ListenersAppBarView extends StatelessWidget {
  const ListenersAppBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        appBarColor: AppColors.lightPurple,         // ✅ #12131A deep dark bg
        showBoxShadow: false,
        title: EnumLocale.txtAllListeners.name.tr,
        textColor: AppColors.white,
        showLeadingIcon: false,
        action: [
          GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.searchScreen);
            },
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: AppColors.lightPurple,           // ✅ #1E2030 dark card surface
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Image.asset(
                  AppAsset.searchIcon,
                  height: 18,
                  width: 18,
                  color: AppColors.appColor,            // ✅ #EDEFF5 near-white icon
                ),
              ),
            ).paddingOnly(right: 18),
          )
        ],
      ),
    );
  }
}

class ListenersTopButtonView extends StatelessWidget {
  const ListenersTopButtonView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GetBuilder<ListenersScreenController>(
          builder: (controller) {
            return Expanded(
              child: PrimaryAppButton(
                borderColor: AppColors.borderColor,     // ✅ #252840 dark border
                color: AppColors.lightPurple,           // ✅ #1E2030 dark card surface
                onTap: () {
                  Get.bottomSheet(
                    AppLanguageBottomSheet(),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      AppAsset.speakingBoy,
                      height: 25,
                      width: 25,
                      color: AppColors.darkOrange,      // ✅ #FF6D00 stays vivid on dark
                    ).paddingSymmetric(vertical: 10),
                    Text(
                      EnumLocale.txtLanguage.name.tr,
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 14,
                        fontColor: AppColors.appColor,  // ✅ #EDEFF5 near-white text
                      ),
                    ),
                    RotatedBox(
                      quarterTurns: 3,
                      child: Image.asset(
                        AppAsset.backArrowIcon,
                        height: 16,
                        width: 16,
                        color: AppColors.grey,          // ✅ #6B6E82 muted arrow
                      ),
                    ),
                  ],
                ).paddingSymmetric(horizontal: 10),
              ),
            );
          },
        ),
        SizedBox(width: 16),
        Expanded(
          child: PrimaryAppButton(
            borderColor: AppColors.borderColor,         // ✅ #252840 dark border
            color: AppColors.lightPurple,               // ✅ #1E2030 dark card surface
            onTap: () {
              Get.bottomSheet(
                TalkAboutBottomSheet(),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  AppAsset.talkAboutIcon,
                  height: 25,
                  width: 25,
                  color: AppColors.blue,                // ✅ #40C4FF bright blue on dark
                ).paddingSymmetric(vertical: 10),
                Text(
                  EnumLocale.txtTalkAbout.name.tr,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 14,
                    fontColor: AppColors.appColor,      // ✅ #EDEFF5 near-white text
                  ),
                ),
                RotatedBox(
                  quarterTurns: 3,
                  child: Image.asset(
                    AppAsset.backArrowIcon,
                    height: 16,
                    width: 16,
                    color: AppColors.grey,              // ✅ #6B6E82 muted arrow
                  ),
                ),
              ],
            ).paddingSymmetric(horizontal: 10),
          ),
        ),
      ],
    ).paddingOnly(left: 20, right: 20, bottom: 14);
  }
}