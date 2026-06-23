import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class HomeAppBarWidget extends GetWidget<HomeScreenController> {
  HomeAppBarWidget({super.key});
  final editController = Get.find<EditProfileController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.lightPurple,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // ── Avatar + Name/ID ───────────────────────────────────────────
            GetBuilder<EditProfileController>(
              id: Constant.idProfile,
              builder: (controller) {
                final bool isIncomplete = Database.isFillProfile == false;
                final String name = Database.loginUserName.isNotEmpty
                    ? Database.loginUserName
                    : "Welcome!";

                return Expanded(
                  child: Row(
                    children: [
                      // Avatar — dotted border only when profile complete
                      DottedBorder(
                        options: CircularDottedBorderOptions(
                          color: isIncomplete
                              ? AppColors.grey
                              : Colors.black,
                          dashPattern: isIncomplete ? [2, 3] : [3, 2],
                          strokeWidth: 1,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(AppRoutes.myProfileScreen)?.then((_) {
                              Utils.onChangeStatusBar(
                                  brightness: Brightness.dark);
                            });
                          },
                          child: Container(
                            clipBehavior: Clip.hardEdge,
                            height: Get.height * 0.06,
                            width: Get.height * 0.06,
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey,
                              shape: BoxShape.circle,
                            ),
                            child: isIncomplete &&
                                Database.loginUserProfilePic.isEmpty
                            // Placeholder avatar for incomplete profile
                                ?  Icon(Icons.person,
                                color: AppColors.grey, size: 30)
                                : CustomProfileImage(
                              image: Database.loginUserProfilePic,
                            ),
                          ),
                        ),
                      ).paddingOnly(right: 9),

                      // Name + ID / incomplete label
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name row
                          Row(
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppFontStyle.fontStyleW700(
                                  fontSize: 16,
                                  fontColor: AppColors.white,
                                ),
                              ).paddingOnly(right: 5, bottom: 3),
                            ],
                          ),

                          // If profile complete → show unique ID chip
                          // If incomplete → show a small "tap to set up" label
                          if (!isIncomplete)
                            GetBuilder<HomeScreenController>(
                              builder: (hController) {
                                return GestureDetector(
                                  onTap: () {
                                    if (!hController.isToastVisible) {
                                      Utils.copyText(
                                          Database.fetchLoginUserProfileModel
                                              ?.user?.uniqueId ??
                                              "");
                                      Utils.showToast(context, "copied");
                                      hController.isToastVisible = true;
                                      Future.delayed(
                                          const Duration(seconds: 3), () {
                                        hController.isToastVisible = false;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        bottom: 3, left: 6, right: 6, top: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.idContainerColor,
                                      borderRadius: BorderRadius.circular(60),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          "ID: ${Database.fetchLoginUserProfileModel?.user?.uniqueId ?? ""}",
                                          overflow: TextOverflow.ellipsis,
                                          style: AppFontStyle.fontStyleW600(
                                            fontSize: 10,
                                            fontColor: AppColors.idTxtColor,
                                          ),
                                        ).paddingOnly(right: 3),
                                        Image.asset(
                                          AppAsset.copyIcon,
                                          height: 12,
                                          width: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0EDFF),
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: Text(
                                "Profile incomplete",
                                style: AppFontStyle.fontStyleW500(
                                  fontSize: 10,
                                  fontColor: const Color(0xFF7B5FCC),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            // ── Coin balance ───────────────────────────────────────────────
            GetBuilder<HomeScreenController>(
              id: Constant.idCoinUpdate,
              builder: (controller) {
                return GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.myWalletScreen),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.lightPurple,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          AppAsset.starCoin,
                          height: 24,
                          width: 24,
                        ),
                        controller.isCoinLoading
                            ? Shimmer.fromColors(
                          baseColor: AppColors.lightGrey1,
                          highlightColor:
                          AppColors.grey.withValues(alpha: 0.2),
                          child: Text(
                            Database.listenerCoin.toString(),
                            style: AppFontStyle.fontStyleW700(
                                fontSize: 16,
                                fontColor: AppColors.orange),
                          ),
                        ).paddingOnly(left: 6, right: 6)
                            : Text(
                          Database.userCoin.toString(),
                          style: AppFontStyle.fontStyleW700(
                              fontSize: 15,
                              fontColor: AppColors.orange),
                        ).paddingOnly(left: 6, right: 5),
                      ],
                    ),
                  ).paddingOnly(right: 6),
                );
              },
            ),
            // GestureDetector(
            //   onTap: (){Get.toNamed(AppRoutes.myWalletScreen);},
            //   child: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Image.asset(
            //         AppAsset.starCoin,
            //         height: 24,
            //         width: 24,
            //       ),
            //       Text(
            //         Database.userCoin.toString(),
            //         style: AppFontStyle.fontStyleW700(
            //           fontSize: 14,
            //           fontColor: AppColors.randomCallCoin,
            //         ),
            //       ).paddingOnly(left: 6),
            //     ],
            //   ),
            // ),
            SizedBox(width: 8,),
            // ── Notification bell ──────────────────────────────────────────
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.userNotificationView),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: AppColors.lightRed.withValues(alpha: 0.5),
                ),
                child: Image.asset(
                  AppAsset.notificationIconRed,
                  height: 20,
                  width: 20,
                ),
              ),
            ),
          ],
        ).paddingOnly(top: Get.height * 0.048, bottom: 10),
      ),
    );
  }
}