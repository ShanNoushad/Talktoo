// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class BlockDialog extends StatelessWidget {
  final String hostId;
  final String userId;
  final bool isHost;
  final bool? isChatHostDetail;
  final VoidCallback? onTapCall;

  const BlockDialog({
    super.key,
    required this.hostId,
    required this.userId,
    required this.isHost,
    this.isChatHostDetail,
    this.onTapCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 410,
      width: 330,
      padding: const EdgeInsets.all(15),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          15.height,
          Image.asset(
            AppAsset.blockIcon,
            height: 100,
            width: 100,
          ),
          10.height,
          Text(
            isHost ? EnumLocale.txtBlockListener.name.tr : EnumLocale.txtBlockUser.name.tr,
            textAlign: TextAlign.center,
            style: AppFontStyle.fontStyleW800(fontColor: AppColors.black, fontSize: 30),
          ),
          4.height,
          Text(
            isHost ? EnumLocale.txtBlockDetailsListener.name.tr : EnumLocale.txtBlockDetailsUser.name.tr,
            textAlign: TextAlign.center,
            style: AppFontStyle.fontStyleW600(fontColor: AppColors.grey, fontSize: 18),
          ).paddingOnly(left: 7, right: 7),
          20.height,
          GestureDetector(
            onTap: onTapCall ??
                () async {
                  Get.close(2);
                },
            child: Container(
              alignment: Alignment.center,
              height: 50,
              width: Get.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: AppColors.red,
              ),
              child: Text(
                EnumLocale.txtBlock.name.tr,
                style: AppFontStyle.fontStyleW600(fontColor: AppColors.white, fontSize: 17),
              ),
            ),
          ),
          14.height,
          PrimaryAppButton(
            onTap: () {
              Get.back();
            },
            height: 47,
            borderRadius: 50,
            color: AppColors.lightGrey,
            text: EnumLocale.txtCancel.name.tr,
            textStyle: AppFontStyle.fontStyleW700(
              fontSize: 17,
              fontColor: AppColors.appColor,
            ),
          )
        ],
      ),
    );
  }
}
