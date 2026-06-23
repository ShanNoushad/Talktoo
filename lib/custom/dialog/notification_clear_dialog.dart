import 'package:cupertino_rounded_corners/cupertino_rounded_corners.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/ui/host_flow/host_notification/controller/host_notification_controller.dart';
import 'package:talk_in/ui/user_flow/user_notification/controller/user_notification_controller.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class NotificationClearDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const NotificationClearDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Material(
        shape: const SquircleBorder(
          radius: BorderRadius.all(
            Radius.circular(110),
          ),
        ),
        color: AppColors.lightPurple1, // Darkened: changed from white to slightly elevated surface
        child: GetBuilder<UserNotificationController>(builder: (controller) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                EnumLocale.txtSureClearNotification.name.tr,
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW500(
                  fontSize: 17,
                  fontColor: AppColors.appDarkColor, // Lightened: changed to brightest text for dark bg
                ),
              ).paddingOnly(top: 8, bottom: 13),
              PrimaryAppButton(
                onTap: () {
                  Get.back();
                  onConfirm();
                },
                height: 47,
                borderRadius: 8,
                color: AppColors.primary, // Explicitly using brand primary (purple accent)
                text: EnumLocale.txtSure.name.tr,
                textStyle: AppFontStyle.fontStyleW600(
                  fontSize: 17,
                  fontColor: AppColors.appDarkColor, // High contrast text over primary accent
                ),
              ).paddingOnly(top: 20, bottom: 10, left: 5, right: 5),
              PrimaryAppButton(
                onTap: () {
                  Get.back();
                },
                height: 47,
                borderRadius: 8,
                color: AppColors.lightPurple, // Slightly darker surface for secondary cancel action
                text: EnumLocale.txtCancel.name.tr,
                textStyle: AppFontStyle.fontStyleW700(
                  fontSize: 17,
                  fontColor: AppColors.grey, // Muted grey for cancel text
                ),
              ).paddingOnly(bottom: 18, left: 5, right: 5)
            ],
          ).paddingAll(15);
        }),
      ),
    );
  }
}

class HostNotificationClearDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const HostNotificationClearDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Material(
        shape: const SquircleBorder(
          radius: BorderRadius.all(
            Radius.circular(110),
          ),
        ),
        color: AppColors.lightPurple1, // Darkened: changed from white to slightly elevated surface
        child: GetBuilder<HostNotificationController>(builder: (controller) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                EnumLocale.txtSureClearNotification.name.tr,
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW500(
                  fontSize: 17,
                  fontColor: AppColors.appDarkColor, // Lightened: changed to brightest text for dark bg
                ),
              ).paddingOnly(top: 8, bottom: 13),
              PrimaryAppButton(
                onTap: () {
                  Get.back();
                  onConfirm();
                },
                height: 47,
                borderRadius: 8,
                color: AppColors.primary, // Explicitly using brand primary (purple accent)
                text: EnumLocale.txtSure.name.tr,
                textStyle: AppFontStyle.fontStyleW600(
                  fontSize: 17,
                  fontColor: AppColors.appDarkColor, // High contrast text over primary accent
                ),
              ).paddingOnly(top: 20, bottom: 10, left: 5, right: 5),
              PrimaryAppButton(
                onTap: () {
                  Get.back();
                },
                height: 47,
                borderRadius: 8,
                color: AppColors.lightPurple, // Slightly darker surface for secondary cancel action
                text: EnumLocale.txtCancel.name.tr,
                textStyle: AppFontStyle.fontStyleW700(
                  fontSize: 17,
                  fontColor: AppColors.grey, // Muted grey for cancel text
                ),
              ).paddingOnly(bottom: 18, left: 5, right: 5)
            ],
          ).paddingAll(15);
        }),
      ),
    );
  }
}