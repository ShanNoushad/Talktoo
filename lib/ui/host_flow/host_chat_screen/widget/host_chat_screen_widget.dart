import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/custom_chat_time/custom_format_chat_time.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class HostChatScreenAppBarView extends StatelessWidget {
  const HostChatScreenAppBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: CustomAppBar(
        title: EnumLocale.txtChats.name.tr,
        showLeadingIcon: false,
        textColor: AppColors.white,
        appBarColor: AppColors.lightPurple, // Deep purple card surface
        action: [
          GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.hostChatListSearchView);
            },
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: AppColors.lightPurple1, // Changed from pure white to slightly elevated surface
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Image.asset(
                  AppAsset.searchIcon,
                  height: 20,
                  color: AppColors.appColor,
                ),
              ),
            ).paddingOnly(right: 18),
          )
        ],
      ),
    );
  }
}

class HostChatViewItem extends StatelessWidget {
  final String name;
  final String image;
  final int index;
  final int unReadCount;
  final String lastMsgTime;
  final String lastMsg;
  final void Function()? onTap;

  const HostChatViewItem({
    super.key,
    required this.name,
    required this.image,
    required this.index,
    this.onTap,
    required this.unReadCount,
    required this.lastMsgTime,
    required this.lastMsg,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grey.withValues(alpha: 0.2), // Lowered alpha tint for dark mode polish
            ),
            child: Container(
              height: Get.height * 0.06,
              width: Get.height * 0.06,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderColor, width: 1), // Changed from white to general border color
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: CustomProfileImage(
                  image: image,
                  fit: BoxFit.cover,
                ),
              ),
            ).paddingAll(1),
          ).paddingOnly(right: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.appDarkColor), // Changed from black to brightest text color
                    ).paddingOnly(right: 8),
                  ],
                ).paddingOnly(bottom: 7),
                Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  lastMsg,
                  style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.profileText), // Using secondary dark text color
                ).paddingOnly(right: 15)
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              unReadCount > 0
                  ? Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: AppColors.appColor, // Soft white badge container background
                ),
                child: Center(
                  child: Text(
                    unReadCount.toString(),
                    style: AppFontStyle.fontStyleW600(fontSize: 13, fontColor: AppColors.black),
                  ),
                ),
              ).paddingOnly(bottom: 8)
                  : const SizedBox(
                height: 22,
                width: 22,
              ),
              Text(
                CustomFormatChatTime.convert(lastMsgTime),
                style: AppFontStyle.fontStyleW500(fontSize: 10, fontColor: AppColors.profileText),
              ),
            ],
          ),
        ],
      ),
    ).paddingOnly(bottom: 12, top: 12);
  }
}