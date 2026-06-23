import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/controller/my_wallet_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class MyWalletScreenTopView extends StatelessWidget {
  const MyWalletScreenTopView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backGroundColor,
        image: DecorationImage(
          image: AssetImage(AppAsset.walletBg),
          fit: BoxFit.cover,
          opacity: 0.35,
        ),
      ),
      child: Column(
        children: [
          // Header Row with absolute centering to prevent layout skewing across different screen sizes
          SizedBox(
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 6,
                  child: InkWell(
                    onTap: () {
                      Get.back();
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        height: 16,
                        AppAsset.backArrowIcon,
                        color: AppColors.appDarkColor,
                      ),
                    ),
                  ),
                ),
                Text(
                  EnumLocale.txtMyWallet.name.tr,
                  style: AppFontStyle.fontStyleW600(fontSize: 20, fontColor: AppColors.appDarkColor),
                ),
              ],
            ),
          ).paddingOnly(bottom: 10),

          GetBuilder<MyWalletController>(
              id: Constant.idGetCoinPlan,
              builder: (controller) {
                return Container(
                  padding: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: AppColors.lightPurple1,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.purpleBorder, width: 1.5),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        AppAsset.walletCross,
                        height: 147,
                        width: 147,
                      ).paddingOnly(right: 10),
                      Expanded( // Enforced template overflow safety
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: Get.width * 0.40,
                              child: FittedBox(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  EnumLocale.txtCurrentCoinBalance.name.tr,
                                  style: AppFontStyle.fontStyleW600(
                                    fontSize: 14,
                                    fontColor: AppColors.getCoinText,
                                    decorationColor: AppColors.getCoinText,
                                    textDecoration: TextDecoration.underline,
                                  ),
                                ).paddingOnly(bottom: 6, top: 15),
                              ),
                            ),
                            Text(
                              "${controller.fetchCoinPlan?.userCoin ?? 0}",
                              style: AppFontStyle.fontStyleW900(
                                fontSize: 44,
                                fontColor: AppColors.yellow,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(AppRoutes.coinHistoryScreen);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
                                decoration: BoxDecoration(
                                  color: AppColors.coinTileColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.yellowBorder),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min, // Prevents button row stretching out of frame
                                  children: [
                                    Text(
                                      EnumLocale.txtViewCoinHistory.name.tr,
                                      style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: AppColors.orangeText),
                                    ).paddingOnly(left: 6, right: 6),
                                    RotatedBox(
                                      quarterTurns: 2,
                                      child: Image.asset(
                                        AppAsset.backArrowIcon,
                                        height: 10,
                                        width: 10,
                                        color: AppColors.orangeText,
                                      ),
                                    ).paddingOnly(right: 4),
                                  ],
                                ),
                              ).paddingOnly(right: 14),
                            ).paddingOnly(top: 4, bottom: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).paddingOnly(bottom: 24, left: 20, right: 20);
              }),
        ],
      ).paddingOnly(top: Get.height * 0.042),
    );
  }
}

class WalletGuideView extends StatelessWidget {
  const WalletGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EnumLocale.txtWalletGuide.name.tr,
          style: AppFontStyle.fontStyleW800(
            fontSize: 17,
            fontColor: AppColors.appDarkColor,
          ),
        ),
        Text(
          EnumLocale.txtUserGuide.name.tr,
          style: AppFontStyle.fontStyleW500(
            fontSize: 11,
            fontColor: AppColors.profileText,
            height: 1.7,
          ),
        ).paddingOnly(top: 8),
      ],
    ).paddingSymmetric(horizontal: 14);
  }
}