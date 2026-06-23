import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/dialog/notification_clear_dialog.dart';
import 'package:talk_in/ui/host_flow/host_notification/shimmer/notification_shimmer.dart';
import 'package:talk_in/ui/user_flow/user_notification/controller/user_notification_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class UserNotificationAppBar extends StatelessWidget {
  const UserNotificationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: CustomAppBar(
        appBarColor: AppColors.lightPurple, // Changed to main dark background
        title: EnumLocale.txtNotification.name.tr,
        textColor: AppColors.appDarkColor, // Crisp, near-white text for dark theme
        showLeadingIcon: true,
        action: [
          GetBuilder<UserNotificationController>(
              id: Constant.idUserNotification,
              builder: (controller) {
                return GestureDetector(
                  onTap: () {
                    Get.dialog(
                      barrierColor: AppColors.black.withValues(alpha: 0.8),
                      Dialog(
                        backgroundColor: AppColors.transparent,
                        shadowColor: AppColors.transparent,
                        surfaceTintColor: AppColors.transparent,
                        elevation: 0,
                        child: NotificationClearDialog(onConfirm: controller.clearNotificationUser),
                      ),
                    );
                  },
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: AppColors.lightPurple1, // Muted dark surface for the clear icon tile
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Image.asset(
                        AppAsset.filterClearIcon,
                        height: 26,
                        width: 26,
                        color: AppColors.appColor, // Force the icon to look white/light if it's a asset template
                      ),
                    ),
                  ).paddingOnly(right: 18),
                );
              })
        ],
      ),
    );
  }
}

class UserNotificationView extends StatelessWidget {
  const UserNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserNotificationController>(
        id: Constant.idUserNotification,
        builder: (controller) {
          return controller.isLoading
              ? Expanded(child: NotificationShimmer())
              : controller.notificationList.isEmpty
              ? Expanded(child: Image.asset(AppAsset.noNotificationFound).paddingAll(70))
              : Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.onRefresh(),
              color: AppColors.primary,
              backgroundColor: AppColors.lightPurple1,
              child: SingleChildScrollView(
                controller: controller.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    ListView.builder(
                      itemCount: controller.notificationList.length + 1,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        if (index == controller.notificationList.length) {
                          return GetBuilder<UserNotificationController>(
                            id: Constant.idPaginationListener,
                            builder: (_) => controller.isPaginationLoading
                                ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                                : const SizedBox(),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.notificationList[index].title ?? '',
                              // Changed fontColor from AppColors.black to AppColors.appDarkColor
                              style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.appDarkColor),
                            ).paddingOnly(bottom: 3),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Text(
                                    controller.notificationList[index].message ?? '',
                                    style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: AppColors.notificationTxt),
                                  ),
                                ),
                                6.width,
                                Text(
                                  controller.notificationList[index].date ?? '',
                                  // Changed fontColor from AppColors.black to AppColors.grey
                                  style: AppFontStyle.fontStyleW600(fontSize: 10, fontColor: AppColors.grey),
                                )
                              ],
                            ).paddingOnly(bottom: 5),
                            Divider(
                              color: AppColors.historyDivider, // Darker, theme-friendly divider line
                              height: 25,
                            )
                          ],
                        ).paddingSymmetric(horizontal: 16); // Added padding so texts don't hug screen edges
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}