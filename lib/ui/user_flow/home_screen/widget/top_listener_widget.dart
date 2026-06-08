import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/bottom_sheet/talk_now_button_bottom_sheet.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/shimmer/top_listener_shimmer.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/controller/profile_detail_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class TopListenerWidget extends StatelessWidget {
  const TopListenerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Card width calculated so exactly 2.5 cards are visible at once
    // Total visible = screenWidth - 32 (horizontal padding)
    // 2.5 cards = availableWidth => cardWidth = availableWidth / 2.5
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = 32; // 16 left + 16 right
    final double cardSpacing = 10;
    // (cardWidth * 2.5) + (cardSpacing * 2) = screenWidth - horizontalPadding
    final double cardWidth = (screenWidth - horizontalPadding - (cardSpacing * 2)) / 2.5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 1,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                EnumLocale.txtTopListener.name.tr,
                style: AppFontStyle.fontStyleW600(
                  fontSize: 18,
                  fontColor: AppColors.appDarkColor,
                ),
              ),
              InkWell(
                onTap: () => Get.toNamed(AppRoutes.topListenersViewAll),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4).copyWith(left: 5),
                  color: AppColors.transparent,
                  child: Text(
                    EnumLocale.txtViewAll.name.tr,
                    style: AppFontStyle.fontStyleW500(
                      decorationColor: AppColors.appTextColor,
                      textDecoration: TextDecoration.underline,
                      fontSize: 13,
                      fontColor: AppColors.appTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ).paddingOnly(top: 16, bottom: 12),

          // Listener Cards
          GetBuilder<HomeScreenController>(
            id: Constant.idGetListener,
            builder: (controller) {
              if (controller.isLoading) return const TopListenerShimmer();

              if (controller.topListenersModel?.data?.isEmpty == true) {
                return Image.asset(AppAsset.noListenerFound).paddingAll(50);
              }

              return SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: controller.topListeners.take(4).length,
                  itemBuilder: (context, index) {
                    final listener = controller.topListeners[index];
                    final statusLabel = listener.statusLabel ?? '';
                    final isAvailable = statusLabel == "Available";
                    final isOnCall = statusLabel == "On Call";
                    final isOffline = statusLabel == "Offline" || (!isAvailable && !isOnCall);

                    final Color statusColor = isAvailable
                        ? const Color(0xFF4CD964)
                        : isOnCall
                        ? const Color(0xFFFF3B30)
                        : const Color(0xFFB0B0B0);

                    return GestureDetector(
                      onTap: () {
                        Utils.showLog("Call Matching ==>> ${listener.id}");
                        Get.delete<ProfileDetailScreenController>();
                        Get.toNamed(
                          AppRoutes.profileDetailScreenView,
                          arguments: listener.id,
                        );
                      },
                      child: Container(
                        width: cardWidth,
                        margin: EdgeInsets.only(right: cardSpacing, bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // --- Background: Full Profile Image ---
                              listener.image != null && listener.image!.isNotEmpty
                                  ? Image.network(
                                listener.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFFE8E0F0),
                                  child: const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Color(0xFFB0A0C8),
                                  ),
                                ),
                              )
                                  : Container(
                                color: const Color(0xFFE8E0F0),
                                child: const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Color(0xFFB0A0C8),
                                ),
                              ),

                              // --- Gradient Overlay (bottom-up) ---
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.15),
                                        Colors.black.withValues(alpha: 0.72),
                                      ],
                                      stops: const [0.35, 0.6, 1.0],
                                    ),
                                  ),
                                ),
                              ),

                              // --- Status Badge (top-left) ---
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.40),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        statusLabel,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // --- Bottom Info + Call Button ---
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Name, age, language, calls
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Name + Age
                                            Text(
                                              '${listener.name ?? ''}${listener.age != null ? ', ${listener.age}' : ''}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.1,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            // Language
                                            if ((listener.language?.isNotEmpty ?? false))
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.language,
                                                    color: Colors.white70,
                                                    size: 11,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Flexible(
                                                    child: Text(
                                                      listener.language![0].toString(),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            const SizedBox(height: 2),
                                            // Call Count
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.headset,
                                                  color: Colors.white60,
                                                  size: 11,
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  '${listener.callCount ?? 0} calls',
                                                  style: const TextStyle(
                                                    color: Colors.white60,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // --- Call Button: hidden when Offline ---
                                      if (!isOffline) ...[
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () {
                                            String role = Database.fetchLoginUserProfileModel?.user?.isListener == false
                                                ? 'user'
                                                : 'listener';
                                            log("################################$role");
                                            Get.bottomSheet(
                                              TalkNowButtonBottomSheet(
                                                chatOnTap: () {
                                                  Get.toNamed(
                                                    AppRoutes.personalChatScreen,
                                                    arguments: [
                                                      controller.topListenersModel?.data?[index].id,
                                                      controller.topListenersModel?.data?[index].name,
                                                      controller.topListenersModel?.data?[index].statusLabel,
                                                      controller.topListenersModel?.data?[index].image,
                                                      controller.topListenersModel?.data?[index].ratePrivateAudioCall,
                                                      controller.topListenersModel?.data?[index].ratePrivateVideoCall,
                                                      controller.topListenersModel?.data?[index].isFake,
                                                      controller.topListenersModel?.data?[index].video,
                                                      controller.topListenersModel?.data?[index].isAvailableForPrivateVideoCall,
                                                      controller.topListenersModel?.data?[index].isAvailableForPrivateAudioCall,
                                                    ],
                                                  );
                                                },
                                                availableForPrivateAudioCall: controller.topListenersModel?.data?[index].isAvailableForPrivateAudioCall ?? false,
                                                availableForPrivateVideoCall: controller.topListenersModel?.data?[index].isAvailableForPrivateVideoCall ?? false,
                                                fakeVideo: controller.topListenersModel?.data?[index].video ?? [],
                                                fakeAudio: controller.topListenersModel?.data?[index].audio ?? "",
                                                isFake: controller.topListenersModel?.data?[index].isFake ?? false,
                                                videoCallRatePrivate: controller.topListenersModel?.data?[index].ratePrivateVideoCall.toString() ?? '',
                                                audioCallRatePrivate: controller.topListenersModel?.data?[index].ratePrivateAudioCall.toString() ?? '',
                                                callerId: Database.fetchLoginUserProfileModel?.user?.isListener == false
                                                    ? Database.fetchLoginUserProfileModel?.user?.id ?? ''
                                                    : Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
                                                receiverId: listener.id ?? '',
                                                receiverName: listener.name ?? '',
                                                receiverImage: listener.image ?? '',
                                                callerName: Database.fetchLoginUserProfileModel?.user?.fullName ?? '',
                                                callerImage: Database.fetchLoginUserProfileModel?.user?.profilePic ?? '',
                                                callerRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener',
                                                receiverRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'listener' : 'user',
                                              ),
                                              isScrollControlled: true,
                                              backgroundColor: Colors.transparent,
                                            );
                                          },
                                          child: Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF7B5FCC),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF7B5FCC).withValues(alpha: 0.5),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.call,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ).paddingOnly(bottom: 16),
    );
  }
}