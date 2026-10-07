import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/bottom_sheet/talk_now_button_bottom_sheet.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/shimmer/top_listener_shimmer.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/controller/profile_detail_screen_controller.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

import '../../../../custom/custom_profile/custom_profile_image.dart';

class _DarkTheme {
  static const bg = Color(0xFF0F111A);          // Deep dark section backdrop
  static const card = Color(0xFF1E2235);        // Dark overlapping info card
  static const title = Color(0xFFFFFFFF);       // Clear crisp white text
  static const subtitle = Color(0xFF9CA3AF);    // Muted slate gray text
  static const primary = Color(0xFF7C7EFA);     // Lighter radiant violet for visibility
  static const tagBg = Color(0xFF2E2546);       // Darker violet backdrop for tag
  static const shadow = Color(0x33000000);      // Soft dark overlay shadow
  static const deepShadow = Color(0x66000000);  // Deeper canvas drop shadow
}

class TopListenerWidget extends StatelessWidget {
  const TopListenerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = 32; // 16 left + 16 right
    final double cardSpacing = 12;
    final double cardWidth = (screenWidth - horizontalPadding - (cardSpacing * 2)) / 2.2;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _DarkTheme.bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
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
                  fontColor: _DarkTheme.title,
                ),
              ),
              InkWell(
                onTap: () => Get.toNamed(AppRoutes.topListenersViewAll),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4).copyWith(left: 5),
                  color: AppColors.transparent,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        EnumLocale.txtViewAll.name.tr,
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 14,
                          fontColor: _DarkTheme.primary,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: _DarkTheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ).paddingOnly(top: 16, bottom: 12),

          GetBuilder<HomeScreenController>(
            id: Constant.idGetListener,
            builder: (controller) {
              if (controller.isLoading) return const TopListenerShimmer();

              if (controller.topListeners.isEmpty) {
                return const SizedBox.shrink();
              }

              // Keep, in this priority order:
              //  1) Online (Available) listeners
              //  2) On Call listeners
              //  3) Offline listeners, but ONLY if they have private audio
              //     or video call enabled — still reachable even though
              //     not currently online.
              // Everyone else (offline with no call feature enabled) is dropped.
              final visibleListeners = controller.topListeners.where((listener) {
                final statusLabel = listener.statusLabel ?? '';
                final bool isAvailable = statusLabel == "Available";
                final bool isOnCall = statusLabel == "On Call";
                final bool hasCallEnabled =
                    (listener.isAvailableForPrivateAudioCall ?? false) ||
                        (listener.isAvailableForPrivateVideoCall ?? false);

                return isAvailable || isOnCall || hasCallEnabled;
              }).toList();

              // Sort: Online first, then On Call, then offline-but-call-enabled.
              visibleListeners.sort((a, b) {
                int rank(dynamic listener) {
                  final statusLabel = listener.statusLabel ?? '';
                  if (statusLabel == "Available") return 0;
                  if (statusLabel == "On Call") return 1;
                  return 2; // offline but audio/video call enabled
                }

                return rank(a).compareTo(rank(b));
              });

              if (visibleListeners.isEmpty) {
                return SizedBox(
                  height: 120,
                  child: Center(
                    child: Text(
                      'No one is online right now',
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 14,
                        fontColor: _DarkTheme.subtitle,
                      ),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: visibleListeners.take(4).length,
                  itemBuilder: (context, index) {
                    final listener = visibleListeners[index];
                    final statusLabel = listener.statusLabel ?? '';
                    final isAvailable = statusLabel == "Available";
                    final isOnCall = statusLabel == "On Call";
                    final isOffline = statusLabel == "Offline" || (!isAvailable && !isOnCall);
                    // The list is already filtered so any offline listener here
                    // has at least one call type enabled — show the call button
                    // for them too instead of hiding it just because they're offline.
                    final bool hasCallEnabled =
                        (listener.isAvailableForPrivateAudioCall ?? false) ||
                            (listener.isAvailableForPrivateVideoCall ?? false);
                    final bool showCallButton = !isOffline || hasCallEnabled;

                    final Color statusColor = isAvailable
                        ? const Color(0xFF4CD964)
                        : isOnCall
                        ? const Color(0xFFFF3B30)
                        : const Color(0xFF6B7280);

                    final String tagLabel = (listener.language?.isNotEmpty ?? false)
                        ? listener.language![0].toString()
                        : '';

                    return GestureDetector(
                      onTap: () {
                        Utils.showLog("Call Matching ==>> ${listener.id}");
                        Get.delete<ProfileDetailScreenController>();
                        Get.toNamed(
                          AppRoutes.profileDetailScreenView,
                          arguments: listener.id,
                        );
                      },
                      child: SizedBox(
                        width: cardWidth,
                        height: 200,
                        child: Stack(
                          children: [
                            // --- Top Container: Image ---
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              height: 125,
                              child: Container(
                                margin: EdgeInsets.only(right: cardSpacing),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _DarkTheme.shadow,
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
                                      listener.image != null && listener.image!.isNotEmpty
                                          ? CustomListenerProfileImage(
                                        image: listener.image!,
                                        fit: BoxFit.cover,
                                      )
                                          : Container(
                                        color: const Color(0xFF25293C),
                                        child: const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Color(0xFF4E4F66),
                                        ),
                                      ),

                                      // --- Top Rated Badge (top-left) ---
                                      if (index == 0)
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.65),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text('🔥', style: TextStyle(fontSize: 11)),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Top Rated',
                                                  style: AppFontStyle.fontStyleW600(
                                                    fontSize: 10,
                                                    fontColor: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                      // --- Status Dot (top-right) ---
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            color: statusColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: _DarkTheme.card, // Blends beautifully with dark architecture context
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // --- Bottom Container: Info card (overlaps image) ---
                            Positioned(
                              left: 0,
                              right: cardSpacing,
                              bottom: 0,
                              height: 95,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
                                decoration: BoxDecoration(
                                  color: _DarkTheme.card,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _DarkTheme.deepShadow,
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            listener.name ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppFontStyle.fontStyleW700(
                                              fontSize: 15,
                                              fontColor: _DarkTheme.title,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Color(0xFFFFB800),
                                                size: 12,
                                              ),
                                              const SizedBox(width: 2),
                                              Flexible(
                                                child: Text(
                                                  '${(listener.rating ?? 0).toString()} | ${listener.callCount ?? 0} talks',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: AppFontStyle.fontStyleW500(
                                                    fontSize: 11,
                                                    fontColor: _DarkTheme.subtitle,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // --- Call Button: hidden only if listener has
                                    // no call type enabled at all (offline with
                                    // audio/video both off never reaches this list
                                    // anymore, but this keeps it safe) ---
                                    if (showCallButton) ...[
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () {
                                          String role = Database.fetchLoginUserProfileModel?.user?.isListener == false
                                              ? 'user'
                                              : 'listener';
                                          log("################://role");
                                          Get.bottomSheet(
                                            TalkNowButtonBottomSheet(
                                              chatOnTap: () {
                                                Get.toNamed(
                                                  AppRoutes.personalChatScreen,
                                                  arguments: [
                                                    listener.id,
                                                    listener.name,
                                                    listener.statusLabel,
                                                    listener.image,
                                                    listener.ratePrivateAudioCall,
                                                    listener.ratePrivateVideoCall,
                                                    listener.isFake,
                                                    listener.video,
                                                    listener.isAvailableForPrivateVideoCall,
                                                    listener.isAvailableForPrivateAudioCall,
                                                  ],
                                                );
                                              },
                                              availableForPrivateAudioCall: listener.isAvailableForPrivateAudioCall ?? false,
                                              availableForPrivateVideoCall: listener.isAvailableForPrivateVideoCall ?? false,
                                              fakeVideo: listener.video ?? [],
                                              fakeAudio: listener.audio ?? "",
                                              isFake: listener.isFake ?? false,
                                              videoCallRatePrivate: listener.ratePrivateVideoCall.toString(),
                                              audioCallRatePrivate: listener.ratePrivateAudioCall.toString(),
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
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF22C55E),
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.call,
                                            color: Colors.white,
                                            size: 17,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),

                            // --- Tag/Category Badge (overlapping both containers) ---
                            if (tagLabel.isNotEmpty)
                              Positioned(
                                left: 10,
                                top: 90,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _DarkTheme.tagBg,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    tagLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppFontStyle.fontStyleW600(
                                      fontSize: 11,
                                      fontColor: _DarkTheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                          ],
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