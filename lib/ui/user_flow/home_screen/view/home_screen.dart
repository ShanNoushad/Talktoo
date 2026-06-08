import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/widget/find_more_widget.dart';
import 'package:talk_in/ui/user_flow/home_screen/widget/home_app_bar_widget.dart';
import 'package:talk_in/ui/user_flow/home_screen/widget/top_listener_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

import '../../all_listeners_in_home/all_listeners_in_home.dart';

class HomeScreen extends GetView<HomeScreenController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.dark);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        Get.dialog(
          barrierColor: AppColors.black.withValues(alpha: 0.8),
          Dialog(
            backgroundColor: AppColors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: const ExitAppDialog(),
          ),
        );
        if (didPop) return;
      },
      child: Scaffold(
        backgroundColor: AppColors.backGroundColor,
        body: GetBuilder<HomeScreenController>(
          id: Constant.idGetListener,
          builder: (controller) {
            return RefreshIndicator(
              onRefresh: () async => controller.onRefresh(),
              child: Column(
                children: [
                  HomeAppBarWidget().paddingSymmetric(horizontal: 16),

                  // ── Incomplete profile banner ──────────────────────────
                  // Uses idProfileBanner so HomeScreenController.update()
                  // can trigger it independently.
                  GetBuilder<HomeScreenController>(
                    id: Constant.idProfileBanner,
                    builder: (ctrl) {
                      if (Database.isFillProfile == true) {
                        return const SizedBox.shrink();
                      }

                      return GestureDetector(
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.fillProfileScreen,
                            arguments: [
                              Database.loginUserName,
                              Database.loginUserProfilePic,
                              Database.loginUserEmail,
                            ],
                          )?.then((_) {
                            // When user returns from fill profile screen,
                            // re-check and hide the banner if now complete.
                            ctrl.update([Constant.idProfileBanner]);
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF7B5FCC),
                                Color(0xFF9C7FE8)
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7B5FCC)
                                    .withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Complete your profile",
                                      style: AppFontStyle.fontStyleW700(
                                        fontSize: 14,
                                        fontColor: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Add your name, photo & details to get started.",
                                      style: AppFontStyle.fontStyleW400(
                                        fontSize: 12,
                                        fontColor: Colors.white
                                            .withValues(alpha: 0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                  BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Set up",
                                  style: AppFontStyle.fontStyleW600(
                                    fontSize: 12,
                                    fontColor: const Color(0xFF7B5FCC),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // ── Main scrollable content ────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          FindMoreWidget(),
                          TopListenerWidget(),
                          ListenersGridEmbedded(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}