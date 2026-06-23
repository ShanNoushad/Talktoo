import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/ui/user_flow/home_screen/api/user_coin_api.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/controller/random_call_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

// ✅ Downgraded to StatelessWidget — no asset to precache anymore
class RandomMatchView extends StatelessWidget {
  const RandomMatchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: const BoxDecoration(
          // ✅ Pure dark gradient — no PNG asset dependency at all
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff1A1040),   // dark purple top-left
              Color(0xff12131A),   // near-black center
              Color(0xff0D0E17),   // darkest bottom-right
            ],
          ),
        ),
        child: GetBuilder<RandomCallController>(builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    AppAsset.closeIcon,
                    color: AppColors.appColor,
                    height: 26,
                    width: 26,
                  ),
                ),
              ).paddingOnly(top: 65, right: 33, bottom: 36),
              Text(
                EnumLocale.txtItsAMatch.name.tr,
                style: AppFontStyle.fontStyleLato700(
                  fontSize: 40,
                  fontColor: AppColors.appColor,
                ),
              ).paddingOnly(bottom: 30),
              Center(
                child: RippleAnimation(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  delay: const Duration(milliseconds: 100),
                  repeat: true,
                  minRadius: 80,
                  maxRadius: 25,
                  ripplesCount: 3,
                  duration: const Duration(seconds: 3),
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: ClipOval(
                      child: CustomProfileImage(
                        image: controller.randomAvailableListenerModel?.data?.image ?? '',
                      ),
                    ),
                  ),
                ).paddingSymmetric(horizontal: 45),
              ),
              Text(
                "${controller.randomAvailableListenerModel?.data?.name ?? ''}, ${controller.randomAvailableListenerModel?.data?.age ?? ''}",
                style: AppFontStyle.fontStyleW600(
                  fontSize: 20,
                  fontColor: AppColors.appColor,
                ),
              ).paddingOnly(top: 18),
              Text(
                "ID:${controller.randomAvailableListenerModel?.data?.uniqueId ?? ''}",
                style: AppFontStyle.fontStyleW500(
                  fontSize: 14,
                  fontColor: AppColors.listenersDetail,
                ),
              ).paddingOnly(bottom: 10, top: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.lightOrange100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(AppAsset.dimondCoin, height: 18, width: 18),
                    Text(
                      controller.selectedIndex == 1
                          ? (controller.randomAvailableListenerModel?.data?.rateRandomVideoCall ?? 0).toString()
                          : (controller.randomAvailableListenerModel?.data?.rateRandomAudioCall ?? 0).toString(),
                      style: AppFontStyle.fontStyleW700(fontSize: 12, fontColor: AppColors.orange),
                    ).paddingOnly(left: 6, right: 6),
                    Text(
                      "/ min",
                      style: AppFontStyle.fontStyleW700(fontSize: 12, fontColor: AppColors.orange),
                    ),
                  ],
                ),
              ).paddingOnly(right: 10).paddingOnly(bottom: 20, left: 16),
              SizedBox(
                height: Get.height * 0.032,
                child: ListView.builder(
                  itemCount: controller.randomAvailableListenerModel?.data?.talkTopics?.length ?? 0,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.purple100,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          controller.randomAvailableListenerModel?.data?.talkTopics?[index] ?? '',
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 12,
                            fontColor: AppColors.purple400,
                          ),
                        ),
                      ),
                    ).paddingOnly(right: 5);
                  },
                ).paddingOnly(right: 6),
              ).paddingOnly(bottom: 20, left: 16),
              SizedBox(
                height: Get.height * 0.15,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Image.asset(
                      AppAsset.languageIcon,
                      height: 20,
                      width: 20,
                      color: AppColors.grey,
                    ),
                    Text(
                      '${EnumLocale.txtLanguage.name.tr} : ',
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 14,
                        fontColor: AppColors.listenersDetail,
                      ),
                    ).paddingOnly(left: 8),
                    Expanded(
                      flex: 3,
                      child: Text(
                        controller.randomAvailableListenerModel?.data?.language?.join(', ') ?? '',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 14,
                          fontColor: AppColors.appColor,
                        ),
                      ),
                    ),
                  ],
                ).paddingOnly(top: 8, left: 12, right: 12),
              ),
              const Spacer(),
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: PrimaryAppButton(
                          gradientColor: [AppColors.primary, const Color(0xff5B2ECC)],
                          onTap: () {
                            log("<<<<<<<<<<<<<<<<<<<<<<  ${Database.userCoin.toString()}");
                            final isAudio = controller.selectedIndex == 0;
                            final requiredCoins = isAudio
                                ? controller.randomAvailableListenerModel?.data?.rateRandomAudioCall ?? 0
                                : controller.randomAvailableListenerModel?.data?.rateRandomVideoCall ?? 0;

                            if (controller.randomAvailableListenerModel?.data?.isFake == true) {
                              Utils.showLog("fake call  ${controller.randomAvailableListenerModel?.data?.isFake}");
                              Get.toNamed(
                                AppRoutes.fakeOutgoingCall,
                                arguments: [
                                  controller.randomAvailableListenerModel?.data?.name ?? '',
                                  controller.randomAvailableListenerModel?.data?.image ?? '',
                                  controller.randomAvailableListenerModel?.data?.video ?? '',
                                  controller.randomAvailableListenerModel?.data?.audio ?? '',
                                  controller.selectedIndex == 0 ? "audio" : "video",
                                ],
                              );
                            } else {
                              if (int.parse(Database.userCoin.toString()) < requiredCoins) {
                                Utils.showToast(Get.context!, "You have not enough coins.");
                                Get.toNamed(AppRoutes.myWalletScreen);
                              } else {
                                SocketEmit.randomCallRinging(
                                  callerId: Database.fetchLoginUserProfileModel?.user?.id ?? '',
                                  receiverId: controller.randomAvailableListenerModel?.data?.id ?? '',
                                  callType: controller.selectedIndex == 0 ? "audio" : "video",
                                  callerRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener',
                                  receiverRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'listener' : 'user',
                                  receiverName: controller.randomAvailableListenerModel?.data?.name ?? '',
                                  receiverImage: controller.randomAvailableListenerModel?.data?.image ?? '',
                                  callerName: Database.fetchLoginUserProfileModel?.user?.fullName ?? '',
                                  callerImage: Database.fetchLoginUserProfileModel?.user?.profilePic ?? '',
                                );
                              }
                            }
                          },
                          height: 50,
                          borderRadius: 30,
                          color: AppColors.primary.withValues(alpha: 0.2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                controller.selectedIndex == 1 ? AppAsset.videoCallIcon : AppAsset.callIcon,
                                color: AppColors.white,
                                height: 24,
                                width: 24,
                              ),
                              8.width,
                              Text(
                                controller.selectedIndex == 1
                                    ? EnumLocale.txtVideoCall.name.tr
                                    : EnumLocale.txtAudioCall.name.tr,
                                style: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      10.width,
                      Expanded(
                        child: PrimaryAppButton(
                          gradientColor: [const Color(0xff19BE00), const Color(0xff10B607)],
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.personalChatScreen,
                              arguments: [
                                controller.randomAvailableListenerModel?.data?.id,
                                controller.randomAvailableListenerModel?.data?.name,
                                controller.randomAvailableListenerModel?.data?.isOnline,
                                controller.randomAvailableListenerModel?.data?.image,
                                controller.randomAvailableListenerModel?.data?.ratePrivateAudioCall,
                                controller.randomAvailableListenerModel?.data?.ratePrivateVideoCall,
                                controller.randomAvailableListenerModel?.data?.isFake,
                                controller.randomAvailableListenerModel?.data?.video,
                                controller.randomAvailableListenerModel?.data?.isAvailableForPrivateVideoCall,
                                controller.randomAvailableListenerModel?.data?.isAvailableForPrivateAudioCall,
                              ],
                            );
                          },
                          height: 50,
                          borderRadius: 30,
                          color: AppColors.green.withValues(alpha: 0.2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(AppAsset.chat, color: AppColors.white, height: 24, width: 24),
                              8.width,
                              Text(
                                EnumLocale.txtsayHello.name.tr,
                                style: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ).paddingOnly(bottom: 16, left: 22, right: 22),
                  PrimaryAppButton(
                    gradientColor: [const Color(0xffCF00FD), const Color(0xff8400FF)],
                    onTap: () {
                      controller.getaAvailableListener().then((value) {
                        if (controller.randomAvailableListenerModel?.data != null) {
                          Get.toNamed(AppRoutes.randomMatchView)?.then((value) async {
                            controller.userCoinModel = await UserCoinApi.callApi();
                            Database.onSetUserCoin(controller.userCoinModel!.coin.toString());
                          });
                        } else {
                          log("No available listener found");
                          Utils.showToast(Get.context!, controller.randomAvailableListenerModel?.message ?? '');
                        }
                      });
                    },
                    height: 50,
                    borderRadius: 30,
                    color: AppColors.chatPink.withValues(alpha: 0.2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(AppAsset.rematchIcon, color: AppColors.white, height: 24, width: 24),
                        8.width,
                        Text(
                          EnumLocale.txtReMatch.name.tr,
                          style: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
                        ),
                      ],
                    ),
                  ).paddingOnly(bottom: 32, left: 22, right: 22),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}