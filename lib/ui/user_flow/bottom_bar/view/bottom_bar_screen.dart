import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:talk_in/ui/user_flow/bottom_bar/widget/bottom_bar_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';

import '../../../../custom/dialog/exit_app_dialog.dart';

class BottomBarScreen extends StatelessWidget {
  const BottomBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BottomBarController>(
      id: Constant.idBottomBar,
      builder: (logic) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;

            if (Get.isDialogOpen ?? false) return;

            await Get.dialog(
              barrierColor: Colors.black.withOpacity(0.9),
              Dialog(
                backgroundColor: Colors.transparent,
                child: const ExitAppDialog(),
              ),
            );
          },
          child: Scaffold(
            backgroundColor: AppColors.white,
            bottomNavigationBar: const BottomBarView(),
            body: IndexedStack(
              index: logic.selectIndex,
              children: logic.pages,
            ),
          ),
        );
      },
    );
  }
}