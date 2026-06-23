import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/bottom_sheet/talk_now_button_bottom_sheet.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/host_flow/host_calling_screen/controller/host_calling_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class HostCallingScreenAppBar extends StatelessWidget {
  const HostCallingScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: CustomAppBar(
        appBarColor: AppColors.lightPurple, // Clean deep card surface background
        title: EnumLocale.txtRecentCalling.name.tr,
        textColor: AppColors.white, // Maps safely to your near-white dark theme text config
        showLeadingIcon: false,
      ),
    );
  }
}

class HostCallingScreenItem extends StatelessWidget {
  final int index;
  final String image;
  final String name;
  final String time;
  final HostCallingScreenController controller;
  final String callStatusText;
  final num coin;
  final VoidCallback? onTalkNowTap;

  const HostCallingScreenItem({
    super.key,
    required this.index,
    required this.image,
    required this.name,
    required this.coin,
    required this.callStatusText,
    required this.time,
    required this.controller,
    this.onTalkNowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor), // Changed from lightGrey to clean dark structural borders
      ),
      child: Row(
        children: [
          Container(
            clipBehavior: Clip.hardEdge,
            height: Get.height * 0.078,
            width: Get.height * 0.078,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: CustomProfileImage(
              image: image,
            ),
          ).paddingAll(5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        name,
                        style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.appDarkColor), // Changed from AppColors.black to brightest dark-theme white text
                      ).paddingOnly(right: 8),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Image.asset(
                      callStatusText == "Missed Call"
                          ? AppAsset.missedCall
                          : callStatusText == "Incoming Call"
                          ? AppAsset.incomingCall
                          : AppAsset.outgoingCall,
                      height: 19,
                      width: 19,
                    ),
                    Text(
                      callStatusText,
                      style: AppFontStyle.fontStyleW600(
                          fontSize: 12,
                          fontColor: callStatusText == "Missed Call"
                              ? const Color(0xffFF5252) // Maps explicitly to AppColors.red or system semantic red
                              : callStatusText == "Incoming Call"
                              ? AppColors.green
                              : AppColors.blue),
                    ).paddingOnly(left: 4, right: 4)
                  ],
                ).paddingOnly(bottom: 4, top: 2),
                Text(
                  time,
                  style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: AppColors.profileText),
                ),
              ],
            ).paddingOnly(left: 3),
          ),
          GestureDetector(
            onTap: () {
              if (onTalkNowTap != null) {
                onTalkNowTap!();
              } else {
                Get.bottomSheet(
                  TalkNowButtonBottomSheet(
                    chatOnTap: () {
                      Get.toNamed(
                        AppRoutes.hostPersonalChatScreen,
                        arguments: [
                          controller.callingHistory[index].userId,
                          controller.callingHistory[index].fullName,
                          controller.callingHistory[index].isOnline,
                          controller.callingHistory[index].profilePic,
                        ],
                      );
                    },
                    availableForPrivateVideoCall: true,
                    availableForPrivateAudioCall: true,
                    isFake: controller.callingHistory[index].isFake ?? false,
                    fakeVideo: controller.callingHistory[index].video ?? [],
                    fakeAudio: controller.callingHistory[index].audio ?? "",
                    audioCallRatePrivate: '',
                    videoCallRatePrivate: '',
                    callerId: Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
                    receiverId: controller.callingHistory[index].userId ?? '',
                    receiverName: controller.callingHistory[index].fullName ?? '',
                    receiverImage: controller.callingHistory[index].profilePic ?? '',
                    callerName: Database.fetchLoginUserProfileModel?.user?.fullName ?? '',
                    callerImage: Database.fetchLoginUserProfileModel?.user?.profilePic ?? '',
                    callerRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener',
                    receiverRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'listener' : 'user',
                  ),
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xffFF1261),
                    Color(0xffFF1C20),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Image.asset(
                    AppAsset.callIcon,
                    color: AppColors.white,
                    height: 19,
                    width: 19,
                  ),
                  Text(
                    EnumLocale.txtTalkNow.name.tr,
                    style: AppFontStyle.fontStyleW600(fontSize: 11, fontColor: AppColors.white),
                  ).paddingOnly(left: 6)
                ],
              ),
            ).paddingOnly(right: 6),
          ),
        ],
      ),
    ).paddingSymmetric(horizontal: 16);
  }
}