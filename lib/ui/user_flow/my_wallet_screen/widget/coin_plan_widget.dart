import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/controller/my_wallet_controller.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/shimmer/coin_plan_shimmer.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

import '../model/fetch_coin_plan.dart';

class CoinPlanWidget extends GetView<MyWalletController> {
  const CoinPlanWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EnumLocale.txtAddCoinBalanceSelectPlan.name.tr,
            style: AppFontStyle.fontStyleW800(
              fontSize: 17,
              fontColor: AppColors.appDarkColor,
            ),
          ).paddingOnly(top: 22),
          const SizedBox(height: 22),
          GetBuilder<MyWalletController>(
            id: Constant.idGetCoinPlan,
            builder: (controller) {
              if (controller.isLoading) {
                return const CoinPlanShimmer();
              }

              // Once the user has already completed their first (₹1)
              // recharge, don't show that introductory plan again.
              final bool hasPurchasedCoins =
                  Database.fetchLoginUserProfileModel?.user?.coinsRecharged == true ||
                      Database.isFirstPayDone == true;

              final List<CoinPlan> visiblePlans = hasPurchasedCoins
                  ? controller.coinPlan
                  .where((plan) => plan.productId != 'com.example.app.coinpack_firstcall')
                  .toList()
                  : controller.coinPlan;

              return ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: visiblePlans.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final plan = visiblePlans[index];
                  // Map back to the index in the FULL coinPlan list, since
                  // PaymentOptionBottomSheet indexes into controller.coinPlan
                  // directly (via controller.coinPlan[index] in onClickPayNow).
                  final int originalIndex = controller.coinPlan.indexOf(plan);

                  return GestureDetector(
                    onTap: () {
                      controller.selectedPaymentMethod = -1;
                      controller.update([Constant.onChangePaymentMethod]);
                      controller.selectedCoinPlan = plan;
                      controller.update([Constant.idGetCoinPlan]);
                      Utils.showLog(
                          'Selected Plan Product ID: ${controller.selectedCoinPlan?.productId.toString() ?? ' '}');

                      Get.bottomSheet(
                        PaymentOptionBottomSheet(index: originalIndex),
                        isScrollControlled: true,
                        backgroundColor: AppColors.transparent,
                      );
                    },
                    child: CoinPlanTile(
                      coinPlan: plan,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ).paddingSymmetric(horizontal: 14),
    );
  }
}
class PaymentOptionTile extends StatelessWidget {
  final int index;
  final double? width;
  final double? height;
  final String title;
  final String image;
  final MyWalletController controller;

  const PaymentOptionTile({
    super.key,
    required this.index,
    required this.title,
    required this.image,
    required this.controller,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = controller.selectedPaymentMethod == index;

    return InkWell(
      onTap: () => controller.onChangePaymentMethod(index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.lightPurple1, // Dark option surface box
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor, // Highlights matching primary brand purple
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Image.asset(
              image,
              width: width ?? 50,
              height: height ?? 50,
              fit: BoxFit.contain,
            ),
            Text(
              title,
              style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.appDarkColor), // Crisp light text readability
            ).paddingOnly(left: 16),
            const Spacer(),
            Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey,
                ),
                color: isSelected ? AppColors.primary : AppColors.transparent,
              ),
              child: isSelected
                  ? Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.appDarkColor, // High contrast radio dot layout
                  ),
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class CoinPlanTile extends StatelessWidget {
  const CoinPlanTile({super.key, required this.coinPlan});

  final CoinPlan coinPlan;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.coinTileColor, // Deep gold-tinted background card layout
            border: Border.all(color: AppColors.yellowBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.purple200, // Elevated deep purple box accent frame for the icon
                  border: Border.all(color: AppColors.purpleBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  AppAsset.starCoin,
                  height: 41,
                  width: 41,
                ),
              ).paddingAll(6),
              Expanded(
                child: Text(
                  '${coinPlan.coins} coin',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 16,
                    fontColor: AppColors.yellow, // Vibrant rating/star yellow text
                  ),
                ).paddingOnly(left: 6),
              ),
              Text(
                "₹${coinPlan.price}",
                style: AppFontStyle.fontStyleW700(
                  fontSize: 22,
                  fontColor: AppColors.orange, // Vibrant warning/coin semantic orange instead of dark orange
                ),
              ).paddingOnly(right: 14),
              RotatedBox(
                quarterTurns: 2,
                child: Image.asset(
                  AppAsset.backArrowIcon,
                  height: 12,
                  width: 12,
                  color: AppColors.orangeText,
                ),
              ).paddingOnly(right: 8),
            ],
          ),
        ).paddingOnly(bottom: 16),
        if (coinPlan.isPopular == true)
          Positioned(
            top: Get.height * -0.011,
            right: Get.width * 0.07,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.orange, // Semi-vibrant badge background frame space
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.orangeBorder),
              ),
              child: Text(
                EnumLocale.txtMostPopularPlan.name.tr,
                style: AppFontStyle.fontStyleW600(
                  fontSize: 10,
                  fontColor: AppColors.backGroundColor, // Dark background-toned text over orange surface for deep contrast
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class PaymentOptionBottomSheet extends StatelessWidget {
  final int index;
  const PaymentOptionBottomSheet({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.profileOptionColor, // Replaced pure white with deep profile background slate
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.purpleBorder, width: 1.5), // Elegant dark top rim line
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: GetBuilder<MyWalletController>(
        id: Constant.onChangePaymentMethod,
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.unSelected,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ).paddingOnly(bottom: 12),
              ),
              Text(
                EnumLocale.txtPaymentMethod.name.tr,
                style: AppFontStyle.fontStyleW600(fontSize: 17, fontColor: AppColors.appDarkColor),
              ).paddingOnly(bottom: 15, top: 5),

              if ((Platform.isAndroid && Database.settingApiModel?.data?.isRazorpayEnabled == true) || (Platform.isIOS && Database.settingApiModel?.data?.isRazorpayIosEnabled == true))
                PaymentOptionTile(
                  index: 0,
                  title: "Razorpay",
                  controller: controller,
                  image: AppAsset.razorpay,
                ),
              if ((Platform.isAndroid && Database.settingApiModel?.data?.isStripeEnabled == true) || (Platform.isIOS && Database.settingApiModel?.data?.isStripeIosEnabled == true))
                PaymentOptionTile(
                  index: 1,
                  title: "Stripe",
                  controller: controller,
                  image: AppAsset.stripe,
                ),
              if ((Platform.isAndroid && Database.settingApiModel?.data?.isFlutterwaveEnabled == true) || (Platform.isIOS && Database.settingApiModel?.data?.isFlutterwaveIosEnabled == true))
                PaymentOptionTile(
                  index: 2,
                  title: "Flutterwave",
                  controller: controller,
                  image: AppAsset.flutterWave,
                ),
              if ((Platform.isAndroid && Database.settingApiModel?.data?.isGooglePlayEnabled == true) || (Platform.isIOS && Database.settingApiModel?.data?.isGooglePlayIosEnabled == true))
                PaymentOptionTile(
                  index: 3,
                  title: "In App Purchase",
                  controller: controller,
                  image: Platform.isIOS ? AppAsset.appStoreImage : AppAsset.googleIcon,
                  width: 50,
                  height: 26,
                ),
              if ((Platform.isAndroid && Database.settingApiModel?.data?.isCashfreeAndroidEnabled == true) || (Platform.isIOS && Database.settingApiModel?.data?.isCashfreeIosEnabled == true))
                PaymentOptionTile(
                  index: 4,
                  title: "Cash Free",
                  controller: controller,
                  image: AppAsset.cashFreeImage,
                  width: 50,
                  height: 26,
                ),
              if ((Platform.isAndroid && Database.settingApiModel?.data?.isPaystackAndroidEnabled == true) || (Platform.isIOS && Database.settingApiModel?.data?.isPaystackIosEnabled == true))
                PaymentOptionTile(
                  index: 5,
                  title: "Pay Stack",
                  controller: controller,
                  image: AppAsset.payStackImage,
                  width: 50,
                  height: 26,
                ),
              if ((Platform.isAndroid && Database.settingApiModel?.data?.isPaypalAndroidEnabled == true) || (Platform.isIOS && Database.settingApiModel?.data?.isPaypalIosEnabled == true))
                PaymentOptionTile(
                  index: 6,
                  title: "Pay Pal",
                  controller: controller,
                  image: AppAsset.payPalImage,
                  width: 50,
                  height: 26,
                ),
              PrimaryAppButton(
                onTap: () {
                  log("Plan Selected ID: ${controller.coinPlan[index].id}");
                  log("Product key: ${controller.selectedCoinPlan?.productId}");
                  controller.onClickPayNow(
                      id: controller.coinPlan[index].id ?? '',
                      amount: controller.coinPlan[index].price ?? 0,
                      productKey: controller.selectedCoinPlan?.productId ?? '');
                },
                height: 50,
                borderRadius: 30,
                color: AppColors.primary,
                text: EnumLocale.txtPay.name.tr,
                textStyle: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.appDarkColor),
              ).paddingOnly(bottom: 10, top: 18),
            ],
          );
        },
      ),
    );
  }
}