import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:talk_in/ui/user_flow/my_profile_screen/controller/my_profile_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

// ── Profile top header ────────────────────────────────────────────────────────

class MyProfileTopView extends StatelessWidget {
  const MyProfileTopView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(
      id: Constant.idProfile,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.lightPurple1,
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderColor,
                width: 0.8,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── App bar row ─────────────────────────────────────────
              Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(50),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 22, top: 22, left: 20, right: 6),
                      child: Image.asset(
                        AppAsset.backArrowIcon,
                        height: 16,
                        color: AppColors.appColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    EnumLocale.txtMyProfile.name.tr,
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 20,
                      fontColor: AppColors.appColor,
                    ),
                  ),
                  const Spacer(),
                ],
              ).paddingOnly(bottom: 10, right: 16),

              // ── Avatar + name + edit button row ─────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with ring
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.7),
                        width: 1.5,
                      ),
                    ),
                    child: Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.purple200,
                        border: Border.all(
                          color: AppColors.lightPurple1,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: CustomProfileImage(
                          image: Database.loginUserProfilePic,
                        ),
                      ),
                    ).paddingAll(1),
                  ).paddingOnly(right: 12, left: 16),

                  // Name & email/nickname
                  SizedBox(
                    width: Get.width * 0.4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Database.loginUserName,
                          overflow: TextOverflow.ellipsis,
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 19,
                            fontColor: AppColors.appColor,
                          ),
                        ),
                        Text(
                          Database.loginType == 2
                              ? Database.loginUserNickName
                              : Database.loginUserEmail,
                          overflow: TextOverflow.ellipsis,
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 15,
                            fontColor: AppColors.profileMail,
                          ),
                        ),
                      ],
                    ).paddingOnly(top: 5),
                  ),

                  const Spacer(),

                  // Edit profile button
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.editProfileScreen),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.purple200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.purpleBorder,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            AppAsset.editIcon,
                            height: 17,
                            width: 17,
                            // Tint icon to match dark theme
                            color: AppColors.primary,
                          ),
                          SizedBox(
                            width: Get.width * 0.2,
                            child: Text(
                              EnumLocale.txtEditProfile.name.tr,
                              overflow: TextOverflow.ellipsis,
                              style: AppFontStyle.fontStyleW700(
                                fontSize: 12,
                                fontColor: AppColors.appColor,
                              ),
                            ).paddingOnly(left: 6, right: 2),
                          ),
                        ],
                      ),
                    ).paddingOnly(right: 14),
                  ).paddingOnly(top: 3),
                ],
              ).paddingOnly(bottom: 24),
            ],
          ).paddingOnly(top: Get.height * 0.042),
        );
      },
    );
  }
}

// ── Profile options list ──────────────────────────────────────────────────────

class ProfileOptionsView extends StatelessWidget {
  const ProfileOptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GetBuilder<MyProfileScreenController>(
        builder: (controller) {
          return Column(
            children: [
              // Top 3 quick-access tiles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TopItem(
                    icon: AppAsset.wallet,
                    title: EnumLocale.txtMyWallet.name.tr,
                    onTap: () => Get.toNamed(AppRoutes.myWalletScreen),
                  ),
                  TopItem(
                    icon: AppAsset.helpCenter,
                    title: EnumLocale.txtHelpCenter.name.tr,
                    onTap: () => Get.toNamed(AppRoutes.helpCenterScreen),
                  ),
                  TopItem(
                    icon: AppAsset.setting,
                    title: EnumLocale.txtSettings.name.tr,
                    onTap: () => Get.toNamed(AppRoutes.settingScreen),
                  ),
                ],
              ).paddingOnly(top: 16, bottom: 24, left: 9, right: 9),

              // Host Center (conditional)
              if (Database.settingApiModel?.data?.allowBecomeHostOption == true)
                CenterOption(
                  onTap: () {
                    Get.toNamed(AppRoutes.becomeHostScreen)?.then((_) {
                      Utils.onChangeStatusBar(brightness: Brightness.light);
                    });
                  },
                  icon: AppAsset.hostCenter,
                  title: EnumLocale.txtListenersCenter.name.tr,
                  subtitle: EnumLocale.txtHostCenterDescription.name.tr,
                  badgeText: EnumLocale.txtBecomeListener.name.tr,
                ),

              CenterOption(
                onTap: () async => controller.onClickPrivacyPolicy(),
                icon: AppAsset.privacyCenter,
                title: EnumLocale.txtPrivacyCenter.name.tr,
                subtitle: EnumLocale.txtDataPrivacy.name.tr,
              ),
              CenterOption(
                onTap: () => controller.onClickShare(),
                icon: AppAsset.shareApp,
                title: EnumLocale.txtShareApp.name.tr,
                subtitle: EnumLocale.txtShareAppDes.name.tr,
              ),
              CenterOption(
                onTap: () async => controller.onClickAboutUs(),
                icon: AppAsset.aboutUs,
                title: EnumLocale.txtAboutUs.name.tr,
                subtitle: EnumLocale.txtAboutUsDes.name.tr,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── CenterOption card ─────────────────────────────────────────────────────────

class CenterOption extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String? badgeText;
  final Function()? onTap;

  const CenterOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.profileOptionColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.borderColor,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Image.asset(
              icon,
              height: 68,
              width: 68,
            ).paddingOnly(right: 12),

            // Title + subtitle + optional badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          softWrap: true,
                          style: AppFontStyle.fontStyleW800(
                            fontSize: 18,
                            fontColor: AppColors.appColor,
                          ),
                        ),
                      ),
                      if (badgeText != null)
                        Container(
                          width: Get.width * 0.18,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.purpleBorder,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            badgeText!,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.fontStyleW700(
                              fontSize: 10,
                              fontColor: AppColors.purple400,
                            ),
                          ),
                        ).paddingOnly(left: 5),
                    ],
                  ),
                  Text(
                    subtitle,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 10,
                      fontColor: AppColors.listenersDetail,
                    ),
                  ),
                ],
              ),
            ),

            // Chevron arrow
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.grey,
              size: 20,
            ),
          ],
        ),
      ).paddingOnly(left: 16, right: 16, bottom: 18),
    );
  }
}

// ── TopItem tile ──────────────────────────────────────────────────────────────

class TopItem extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const TopItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(bottom: 10, top: 15),
          decoration: BoxDecoration(
            color: AppColors.profileOptionColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.borderColor,
              width: 0.8,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                icon,
                height: 60,
                width: 60,
              ).paddingSymmetric(horizontal: 25),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW600(
                  fontSize: 14,
                  fontColor: AppColors.appColor,
                ),
              ).paddingOnly(top: 8),
            ],
          ),
        ).paddingSymmetric(horizontal: 6),
      ),
    );
  }
}