import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/dialog/delete_account_dialog.dart';
import 'package:talk_in/custom/dialog/logout_dialog.dart';
import 'package:talk_in/custom/setting_menu_ui/setting_menu.dart';
import 'package:talk_in/custom/switch/switch.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/setting_screen/controller/setting_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

class SettingScreenAppBar extends StatelessWidget {
  const SettingScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: CustomAppBar(
        appBarColor: AppColors.backGroundColor, // Dark background instead of lightPurple
        title: EnumLocale.txtSettings.name.tr,
        textColor: AppColors.appDarkColor, // Light near-white text contrast
        showLeadingIcon: true,
        onTap: () async {
          Get.back();
          await 0.5.delay();
          Utils.onChangeStatusBar(brightness: Brightness.dark); // Updated status bar to match dark theme flow
        },
      ),
    );
  }
}

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backGroundColor, // Full page dark canvas setup
      child: Column(
        children: [
          SettingMainMenu(
            rightSpace: Get.width * -0.07,
            text: EnumLocale.txtManageYourAccountSettings.name.tr,
            subText: EnumLocale.txtManageYourAccountSettingsSubText.name.tr,
            topImage: AppAsset.settingBlur,
          ).paddingOnly(bottom: 20),

          GetBuilder<SettingController>(
            builder: (controller) {
              return SettingMenu(
                widget: CommonCupertinoSwitch(
                  value: controller.isShowNotification,
                  onChanged: (bool val) {
                    controller.onSwitchNotification(val);
                  },
                  activeColor: AppColors.green,
                  trackColor: AppColors.unSelected,
                  scale: 0.8,
                ),
                icon: AppAsset.notification,
                title: EnumLocale.txtNotification.name.tr,
                onTap: () {},
              ).paddingOnly(bottom: 14); // Adjusted spacing hierarchy down slightly
            },
          ),

          SettingMenu(
            icon: AppAsset.settingAppLanguage,
            title: EnumLocale.txtAPPLanguage.name.tr,
            onTap: () {
              Get.toNamed(AppRoutes.appLanguageScreen);
            },
          ).paddingOnly(bottom: 14),

          SettingMenu(
            icon: AppAsset.logOut,
            title: EnumLocale.txtLogoutApp.name.tr,
            onTap: () {
              Get.dialog(
                barrierColor: AppColors.black.withValues(alpha: 0.8),
                Dialog(
                  backgroundColor: AppColors.transparent,
                  shadowColor: AppColors.transparent,
                  surfaceTintColor: AppColors.transparent,
                  elevation: 0,
                  child: const LogoutDialog(),
                ),
              );
            },
          ).paddingOnly(bottom: 14),

          GetBuilder<SettingController>(
            builder: (controller) {
              return SettingMenu(
                icon: AppAsset.delete,
                title: EnumLocale.txtDeleteAccount.name.tr,
                onTap: () {
                  Get.dialog(
                    barrierColor: AppColors.black.withValues(alpha: 0.8),
                    Dialog(
                      backgroundColor: AppColors.transparent,
                      shadowColor: AppColors.transparent,
                      surfaceTintColor: AppColors.transparent,
                      elevation: 0,
                      child: DeleteAccountDialog(
                        onTap: () {
                          controller.onDeleteAccount();
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ), // Removed the .paddingSymmetric(horizontal: 16) extension to eliminate layout conflicts
    );
  }
}