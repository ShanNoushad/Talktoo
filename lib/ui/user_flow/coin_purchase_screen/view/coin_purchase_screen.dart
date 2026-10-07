import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/coin_purchase_screen/controller/coin_purchase_screen_controller.dart';
import 'package:talk_in/ui/user_flow/coin_purchase_screen/widget/coin_purchase_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

import '../../home_screen/controller/home_screen_controller.dart';

class CoinPurchaseScreen extends StatelessWidget {
  const CoinPurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: GetBuilder<CoinPurchaseScreenController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const _CoinPurchaseLoadingView();
          }

          return Column(
            children: [
              CoinPurchaseTopView(),
              CoinPurchaseView(), // Takes remaining space
              Expanded(
                child: Container(
                  width: Get.width,
                  decoration: BoxDecoration(color: AppColors.black),
                  child: Column(
                    children: [
                      Spacer(),
                      PrimaryAppButton(
                        onTap: () {
                          if (Get.isRegistered<HomeScreenController>()) {
                            Get.find<HomeScreenController>().fetchUserCoin();
                          }
                          Get.offNamed(AppRoutes.bottomBar);
                        },
                        height: 50,
                        color: AppColors.purple,
                        child: Center(
                          child: Text(
                            EnumLocale.txtDone.name.tr,
                            style: AppFontStyle.fontStyleW600(
                              fontSize: 16,
                              fontColor: AppColors.white,
                            ),
                          ),
                        ),
                      ).paddingOnly(left: 14, right: 14, bottom: 12),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CoinPurchaseLoadingView extends StatefulWidget {
  const _CoinPurchaseLoadingView();

  @override
  State<_CoinPurchaseLoadingView> createState() => _CoinPurchaseLoadingViewState();
}

class _CoinPurchaseLoadingViewState extends State<_CoinPurchaseLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  late final Animation<double> _opacity =
  Tween<double>(begin: 0.25, end: 0.6).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bone({double width = double.infinity, double height = 16, double radius = 8}) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bone(width: 140, height: 20),
            const SizedBox(height: 24),
            _bone(height: 90, radius: 16),
            const SizedBox(height: 16),
            _bone(width: 200, height: 16),
            const SizedBox(height: 12),
            _bone(width: 260, height: 16),
            const SizedBox(height: 32),
            _bone(height: 60, radius: 12),
            const SizedBox(height: 12),
            _bone(height: 60, radius: 12),
          ],
        ),
      ),
    );
  }
}