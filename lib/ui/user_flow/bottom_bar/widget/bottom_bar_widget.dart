import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';

class BottomBarView extends StatelessWidget {
  const BottomBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BottomBarController>(
      id: Constant.idBottomBar,
      builder: (logic) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.black,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.5),
                offset: const Offset(0, -2),
                blurRadius: 6.0,
                spreadRadius: 0,
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: logic.selectIndex,
            onTap: (value) => logic.onClick(value),
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.grey,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(AppAsset.homeFilled, height: 26, width: 26, color: logic.selectIndex == 0 ? AppColors.primary : AppColors.grey),
                label: EnumLocale.txtHome.name.tr,
              ),
              BottomNavigationBarItem(
                icon: Image.asset(AppAsset.listener, height: 26, width: 26, color: logic.selectIndex == 1 ? AppColors.primary : AppColors.grey),
                label: EnumLocale.txtListener.name.tr,
              ),
              BottomNavigationBarItem(
                icon: Image.asset(AppAsset.randomCall, height: 26, width: 26, color: logic.selectIndex == 2 ? AppColors.primary : AppColors.grey),
                label: EnumLocale.txtRandomCall.name.tr,
              ),
              BottomNavigationBarItem(
                icon: Image.asset(AppAsset.chat, height: 26, width: 26, color: logic.selectIndex == 3 ? AppColors.primary : AppColors.grey),
                label: EnumLocale.txtChat.name.tr,
              ),
              BottomNavigationBarItem(
                icon: Image.asset(AppAsset.calling, height: 26, width: 26, color: logic.selectIndex == 4 ? AppColors.primary : AppColors.grey),
                label: EnumLocale.txtCalling.name.tr,
              ),
            ],
          ),
        );
      },
    );
  }
}