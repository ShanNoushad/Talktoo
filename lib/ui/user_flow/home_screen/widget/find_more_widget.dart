import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constant.dart';
import '../../my_wallet_screen/controller/my_wallet_controller.dart';
import '../../my_wallet_screen/widget/coin_plan_widget.dart';

class FindMoreWidget extends StatelessWidget {
  const FindMoreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
              onTap: () async {
                final controller = Get.put(MyWalletController());

                // Fetch plans if empty
                if (controller.coinPlan.isEmpty) {
                  await controller.fetchCoinPlan;
                }

                // Find the target plan
                final planIndex = controller.coinPlan.indexWhere(
                      (plan) =>
                  plan.productId == 'com.example.app.coinpack_firstcall',
                );
                final safeIndex = planIndex < 0 ? 0 : planIndex;

                // Set selected plan
                controller.selectedCoinPlan = controller.coinPlan[safeIndex];

                // ✅ Set payment method to Razorpay (index 0) directly
                controller.selectedPaymentMethod = 0;

                controller.update([
                  Constant.idGetCoinPlan,
                  Constant.onChangePaymentMethod,
                ]);

                // ✅ Directly trigger Razorpay without showing bottom sheet
                controller.onClickPayNow(
                  id: controller.coinPlan[safeIndex].id ?? '',
                  amount: controller.coinPlan[safeIndex].price ?? 0,
                  productKey: controller.selectedCoinPlan?.productId ?? '',
                );
              },
              child: ClipRRect(
                borderRadius:
                const BorderRadius.all(Radius.circular(15)),
                child: Image.asset("assets/images/banner2.png"),
              ),
            ),
          ),

          // ── Original "Find More Listener" section ────────────────────
        ],
      ),
    );
  }
}