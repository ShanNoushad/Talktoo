import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/bottom_sheet/talk_now_button_bottom_sheet.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/custom/listeners/listeners.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/home_screen/shimmer/top_listener_shimmer.dart';
import 'package:talk_in/ui/user_flow/listener_screen/controller/listeners_screen_controller.dart';
import 'package:talk_in/ui/user_flow/listener_screen/widget/listeners_screen_widget.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';

class ListenersScreen extends StatelessWidget {
  const ListenersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,         // ✅ #12131A deep dark bg
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const ListenersAppBarView(),
      ),
      body: GetBuilder<ListenersScreenController>(
        id: Constant.idAllListener,
        builder: (controller) {
          // Sort order: Available (online) first, then On Call/Busy in the
          // middle, then Offline last. Computed on every rebuild so it always
          // reflects the latest statuses coming from the controller.
          final sortedListeners = [...controller.allListener]
            ..sort((a, b) {
              int rank(String? status) {
                if (status == "Available") return 0; // Online -> top
                if (status == "On Call" || status == "Busy") return 1; // Busy -> middle
                return 2; // Offline -> bottom
              }
              return rank(a.statusLabel).compareTo(rank(b.statusLabel));
            });

          return Column(
            children: [
              ListenersTopButtonView(),
              Expanded(
                child: Container(
                  width: Get.width,
                  height: Get.height,
                  color: AppColors.backGroundColor,        // ✅ #12131A instead of white
                  child: controller.isLoading
                      ? TopListenerShimmer().paddingSymmetric(horizontal: 14, vertical: 12)
                      : controller.allListener.isEmpty
                      ? Image.asset(
                    AppAsset.noListenerFound,
                  ).paddingSymmetric(horizontal: 62)
                      : RefreshIndicator(
                    color: AppColors.primary,   // ✅ purple spinner
                    backgroundColor: AppColors.lightPurple, // ✅ dark bg for indicator
                    onRefresh: () async => controller.onRefresh(),
                    child: SingleChildScrollView(
                      controller: controller.scrollController,
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: sortedListeners.length,
                            itemBuilder: (context, index) {
                              final allListener = sortedListeners[index];
                              return CustomListeners(
                                fake: allListener.isFake ?? false,
                                availableForPrivateAudioCall: allListener.isAvailableForPrivateAudioCall ?? false,
                                availableForPrivateVideoCall: allListener.isAvailableForPrivateVideoCall ?? false,
                                uniqueId: allListener.uniqueId ?? '',
                                statusTxtColor: allListener.statusLabel == "Offline"
                                    ? AppColors.grey                // ✅ muted grey for offline
                                    : AppColors.appColor,           // ✅ near-white for others
                                statusColor: allListener.statusLabel == "Available"
                                    ? AppColors.green               // ✅ #00C853 bright green
                                    : (allListener.statusLabel == "On Call" || allListener.statusLabel == "Busy")
                                    ? AppColors.red             // ✅ stays red
                                    : AppColors.unSelected,     // ✅ #3A3C52 dark muted
                                statusImage: allListener.statusLabel == "Available"
                                    ? Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.green.withValues(alpha: 0.3), // ✅ green glow ring
                                    shape: BoxShape.circle,
                                  ),
                                  child: Container(
                                    height: 7,
                                    width: 7,
                                    decoration: BoxDecoration(
                                      color: AppColors.green, // ✅ solid green dot
                                      shape: BoxShape.circle,
                                    ),
                                  ).paddingAll(1.8),
                                ).paddingOnly(right: 4)
                                    : (allListener.statusLabel == "On Call" || allListener.statusLabel == "Busy")
                                    ? Image.asset(
                                  AppAsset.onCallIcon,
                                  height: 10,
                                  width: 10,
                                ).paddingOnly(right: 3)
                                    : Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.unSelected.withValues(alpha: 0.3), // ✅ muted offline ring
                                    shape: BoxShape.circle,
                                  ),
                                  child: Container(
                                    height: 7,
                                    width: 7,
                                    decoration: BoxDecoration(
                                      color: AppColors.unSelected, // ✅ muted offline dot
                                      shape: BoxShape.circle,
                                    ),
                                  ).paddingAll(1.8),
                                ).paddingOnly(right: 4),
                                image: allListener.image ?? '',
                                status: allListener.statusLabel ?? '',
                                language: allListener.language?[0].toString() ?? '',
                                callCount: allListener.callCount ?? 0,
                                talkTopicName: allListener.talkTopics ?? [],
                                talkTopicLength: allListener.talkTopics?.length ?? 0,
                                index: index,
                                name: allListener.name ?? '',
                                age: allListener.age == null ? "" : ",${allListener.age.toString()}",
                                viewProfileOnTap: () {
                                  Get.toNamed(
                                    AppRoutes.profileDetailScreenView,
                                    arguments: allListener.id,
                                  );
                                },
                                talkNowOnTap: () {
                                  Get.bottomSheet(
                                    TalkNowButtonBottomSheet(
                                      chatOnTap: () {
                                        Get.toNamed(
                                          AppRoutes.personalChatScreen,
                                          arguments: [
                                            allListener.id,
                                            allListener.name,
                                            allListener.statusLabel,
                                            allListener.image,
                                            allListener.ratePrivateAudioCall,
                                            allListener.ratePrivateVideoCall,
                                            allListener.isFake,
                                            allListener.video,
                                            allListener.isAvailableForPrivateVideoCall,
                                            allListener.isAvailableForPrivateAudioCall,
                                          ],
                                        );
                                      },
                                      availableForPrivateAudioCall: allListener.isAvailableForPrivateAudioCall ?? false,
                                      availableForPrivateVideoCall: allListener.isAvailableForPrivateVideoCall ?? false,
                                      isFake: allListener.isFake ?? false,
                                      fakeVideo: allListener.video ?? [],
                                      fakeAudio: allListener.audio ?? "",
                                      audioCallRatePrivate: allListener.ratePrivateAudioCall.toString(),
                                      videoCallRatePrivate: allListener.ratePrivateVideoCall.toString(),
                                      callerId: Database.fetchLoginUserProfileModel?.user?.isListener == false
                                          ? Database.fetchLoginUserProfileModel?.user?.id ?? ''
                                          : Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
                                      receiverId: allListener.id ?? '',
                                      receiverName: allListener.name ?? '',
                                      receiverImage: allListener.image ?? '',
                                      callerName: Database.fetchLoginUserProfileModel?.user?.fullName ?? '',
                                      callerImage: Database.fetchLoginUserProfileModel?.user?.profilePic ?? '',
                                      callerRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener',
                                      receiverRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'listener' : 'user',
                                    ),
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                  );
                                },
                              ).paddingOnly(bottom: 12, left: 14, right: 14, top: index == 0 ? 12 : 0);
                            },
                          ),
                          GetBuilder<ListenersScreenController>(
                            id: Constant.idPaginationListener,
                            builder: (controller) => Visibility(
                              visible: controller.isPaginationLoading,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,           // ✅ purple spinner
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ).paddingOnly(top: 8);
        },
      ),
    );
  }
}