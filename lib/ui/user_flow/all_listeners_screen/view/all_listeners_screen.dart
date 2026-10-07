import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/bottom_sheet/talk_now_button_bottom_sheet.dart';
import 'package:talk_in/custom/listeners/listeners.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/all_listeners_screen/controller/all_listeners_controller.dart';
import 'package:talk_in/ui/user_flow/all_listeners_screen/widget/all_listeners_widget.dart';
import 'package:talk_in/ui/user_flow/home_screen/shimmer/top_listener_shimmer.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';

class AllListenersScreen extends StatelessWidget {
  const AllListenersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const AllListenersAppBar(),
      ),
      body: GetBuilder<AllListenersController>(
        id: Constant.idGetListener,
        builder: (controller) {
          if (controller.isLoading) {
            return TopListenerShimmer().paddingSymmetric(horizontal: 14, vertical: 16);
          }

          if (controller.allListener.isEmpty) {
            return Center(child: Image.asset(AppAsset.noListenerFound).paddingAll(60));
          }
          print(controller.allListener.map((l) => l.statusLabel).toSet());

          // Sort order: Online (Available) first, then Busy (On Call), then Offline last.
          // rank() treats both "On Call" and "Busy" as the busy bucket, in case the
          // backend uses either label — otherwise a "Busy" label would incorrectly
          // fall through to the Offline bucket below.
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
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => controller.onRefresh(),
                  child: SingleChildScrollView(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: BouncingScrollPhysics(),
                          itemCount: sortedListeners.length,
                          itemBuilder: (context, index) {
                            final allListener = sortedListeners[index];
                            return CustomListeners(
                              fake: allListener.isFake ?? false,

                              availableForPrivateAudioCall: allListener.isAvailableForPrivateAudioCall ?? false,
                              availableForPrivateVideoCall: allListener.isAvailableForPrivateVideoCall ?? false,
                              uniqueId: allListener.uniqueId ?? '',
                              statusTxtColor:
                              allListener.statusLabel == "Offline" ? AppColors.appTextColor : AppColors.white,
                              statusColor: allListener.statusLabel == "Available"
                                  ? AppColors.green
                                  : (allListener.statusLabel == "On Call" || allListener.statusLabel == "Busy")
                                  ? AppColors.red
                                  : AppColors.lightGrey1,
                              statusImage: allListener.statusLabel == "Available"
                                  ? Container(
                                // height: 12,
                                // width: 12,
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Container(
                                  height: 7,
                                  width: 7,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
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
                                // height: 12,
                                // width: 12,
                                decoration: BoxDecoration(
                                  color: AppColors.onBoardingTxt.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Container(
                                  height: 7,
                                  width: 7,
                                  decoration: BoxDecoration(
                                    color: AppColors.onBoardingTxt,
                                    shape: BoxShape.circle,
                                  ),
                                ).paddingAll(1.8),
                              ).paddingOnly(right: 4),
                              image: allListener.image ?? '',
                              status: allListener.statusLabel ?? '',
                              language: allListener.language?[0] ?? '',
                              callCount: allListener.callCount ?? 0,
                              talkTopicName: allListener.talkTopics ?? [],
                              // talkTopicName: allListener?.talkTopics?.join(', ') ?? '',
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
                                // if (allListener.isFake == true) {
                                //   Utils.showLog("this is fake Listener>>>>>>>>>");
                                //   Get.toNamed(
                                //     AppRoutes.fakeOutgoingCall,
                                //     arguments: [
                                //       allListener.name,
                                //       allListener.image,
                                //       allListener.video,
                                //       controller.isBackProfile
                                //     ],
                                //   );
                                // } else {
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
                                    availableForPrivateVideoCall: allListener.isAvailableForPrivateVideoCall ?? false,
                                    availableForPrivateAudioCall: allListener.isAvailableForPrivateAudioCall ?? false,
                                    isFake: allListener.isFake ?? false,
                                    fakeVideo: allListener.video ?? [],
                                    fakeAudio: allListener.audio ?? "",
                                    // ratePrivateVideoCall: allListener.ratePrivateVideoCall.toString() ?? '',
                                    // ratePrivateAudioCall: allListener.ratePrivateAudioCall.toString() ?? '',
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
                                    // callType: "video",
                                    callerRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener',
                                    receiverRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'listener' : 'user',
                                  ),
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                );
                                // }
                              },
                            ).paddingOnly(bottom: 12, left: 16, right: 16);
                          },
                        ),
                        GetBuilder<AllListenersController>(
                          id: Constant.idPaginationListener,
                          builder: (controller) => Visibility(
                            visible: controller.isPaginationLoading,
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ).paddingSymmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}