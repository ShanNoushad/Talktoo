import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/constant.dart';
import '../../../../utils/database.dart';
import '../../home_screen/controller/home_screen_controller.dart';
import '../../my_wallet_screen/controller/my_wallet_controller.dart';
import '../../coin_history_screen/api/purchase_coin_plan_api.dart';

class FindMoreWidget extends StatelessWidget {
  const FindMoreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      id: Constant.idCoinUpdate,
      builder: (_) {
        return Container(
          color: Colors.black,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () async {
                    log('---- FindMoreWidget tap ----');
                    log('coinsRecharged (local profile flag): '
                        '${Database.fetchLoginUserProfileModel?.user?.coinsRecharged}');

                    // ── Source of truth: hit the purchase history API directly ──
                    PurchaseCoinGetPlanApi.startPagination = 0;
                    final historyResult = await PurchaseCoinGetPlanApi.callApi(
                      startDate: "All",
                      endDate: "All",
                    );

                    log('Purchase history API response: ${historyResult?.toJson()}');
                    log('Purchase history item count: '
                        '${historyResult?.data?.length ?? 0}');

                    final bool hasPurchaseHistory =
                    (historyResult?.data?.isNotEmpty ?? false);

                    if (hasPurchaseHistory) {
                      log('Decision: history NOT empty → go to MyWallet');
                      if (!Get.isRegistered<MyWalletController>()) {
                        Get.put(MyWalletController());
                      }
                      Get.toNamed(AppRoutes.myWalletScreen);
                      return;
                    }

                    log('Decision: history empty → open Razorpay for first-call plan');

                    // First-time purchase — open Razorpay
                    final controller = Get.put(MyWalletController());

                    if (controller.coinPlan.isEmpty) {
                      await controller.fetchCoinPlanList();
                    }

                    if (controller.coinPlan.isEmpty) {
                      return;
                    }

                    final planIndex = controller.coinPlan.indexWhere(
                          (plan) =>
                      plan.productId ==
                          'com.example.app.coinpack_firstcall',
                    );
                    final safeIndex = planIndex < 0 ? 0 : planIndex;

                    controller.selectedCoinPlan =
                    controller.coinPlan[safeIndex];
                    controller.selectedPaymentMethod = 0;

                    controller.update([
                      Constant.idGetCoinPlan,
                      Constant.onChangePaymentMethod,
                    ]);

                    controller.onClickPayNow(
                      id: controller.coinPlan[safeIndex].id ?? '',
                      amount: controller.coinPlan[safeIndex].price ?? 0,
                      productKey:
                      controller.selectedCoinPlan?.productId ?? '',
                    );
                  },
                  child: ClipRRect(
                    borderRadius:
                    const BorderRadius.all(Radius.circular(15)),
                    child: Image.asset("assets/images/banner2.png"),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}