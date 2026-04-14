import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

void showMoreOptionsBottomSheet({
  required BuildContext context,
  required bool isHost,
  required String userId,
  required VoidCallback onBlock,
  required VoidCallback onReport,
}) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    backgroundColor: AppColors.transparent,
    builder: (context) => Container(
      // height: Get.width * 0.52,
      width: Get.width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ===== Header Section =====
          Container(
            height: 65,
            color: AppColors.idContainerColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 4,
                      width: 35,
                      decoration: BoxDecoration(
                        color: AppColors.darkPurple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    10.height,
                    Text(
                      EnumLocale.txtMore.name.tr,
                      style: AppFontStyle.fontStyleW700(
                        fontColor: AppColors.black,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ).paddingOnly(left: 50),
                const Spacer(),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    height: 30,
                    width: 30,
                    margin: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.transparent,
                      border: Border.all(color: AppColors.black),
                    ),
                    child: Center(
                      child: Image.asset(
                        AppAsset.closeIcon,
                        width: 18,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ===== Options List =====
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                  onBlock();
                },
                child: Container(
                  height: 55,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: AppColors.transparent,
                  child: Row(
                    children: [
                      const Icon(Icons.block, color: Colors.redAccent),
                      12.width,
                      Text(
                        EnumLocale.txtBlock.name.tr,
                        style: AppFontStyle.fontStyleW700(
                          fontColor: AppColors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(color: AppColors.grey.withValues(alpha: 0.3), height: 1),
              GestureDetector(
                onTap: () {
                  Get.back();
                  onReport();
                },
                child: Container(
                  height: 55,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: AppColors.transparent,
                  child: Row(
                    children: [
                      const Icon(Icons.report, color: Colors.orangeAccent),
                      12.width,
                      Text(
                        EnumLocale.txtReport.name.tr,
                        style: AppFontStyle.fontStyleW700(
                          fontColor: AppColors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          10.height
        ],
      ),
    ),
  );
}
