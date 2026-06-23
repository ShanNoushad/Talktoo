import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/bottom_bar/salomon_bottom_bar.dart';
import 'package:talk_in/ui/host_flow/host_bottom_bar/controller/host_bottom_bar_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';

class HostBottomBarView extends StatelessWidget {
  const HostBottomBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostBottomBarController>(
      id: Constant.idBottomBar,
      builder: (logic) {
        return Container(
          height: Platform.isIOS ? 85 : 80,
          decoration: BoxDecoration(
            color: AppColors.backGroundColor, // Changed from AppColors.white to match dark background
            boxShadow: [
              BoxShadow(
                // Softened the shadow alpha for dark mode context (0.5 was too harsh)
                color: AppColors.black.withValues(alpha: 0.2),
                offset: const Offset(0.0, -2.0), // Reoriented shadow slightly to lift up from bottom
                blurRadius: 10.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: OverflowBox(
            maxHeight: double.infinity,
            maxWidth: double.infinity,
            child: SalomonBottomBar(
              currentIndex: logic.selectIndex,
              onTap: (value) async {
                logic.onClick(value);
              },
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(left: 10, right: 10, top: Platform.isIOS ? 10 : 0),
              selectedColorOpacity: 0.15, // Blends a subtle tint block around the selected icon
              items: [
                bottomBarItemView(
                  index: 0,
                  selectIndex: logic.selectIndex,
                  image: AppAsset.homeFilled,
                  label: EnumLocale.txtHome.name.tr,
                ),
                bottomBarItemView(
                  index: 1,
                  selectIndex: logic.selectIndex,
                  image: AppAsset.calling,
                  label: EnumLocale.txtCalling.name.tr,
                ),
                bottomBarItemView(
                  index: 2,
                  selectIndex: logic.selectIndex,
                  image: AppAsset.chat,
                  label: EnumLocale.txtChat.name.tr,
                ),
                bottomBarItemView(
                  index: 3,
                  selectIndex: logic.selectIndex,
                  image: AppAsset.walletIcon,
                  label: EnumLocale.txtWallet.name.tr,
                ),
                bottomBarItemView(
                  index: 4,
                  selectIndex: logic.selectIndex,
                  image: AppAsset.profileIcon,
                  label: EnumLocale.txtProfile.name.tr,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

SalomonBottomBarItem bottomBarItemView({
  required final int index,
  required final int selectIndex,
  required final String image,
  required final String label,
}) {
  final bool isSelected = selectIndex == index;

  return SalomonBottomBarItem(
    icon: Image.asset(
      image,
      height: 26,
      width: 26,
      // Active uses the brand primary (violet), inactive uses dark unselected gray
      color: isSelected ? AppColors.primary : AppColors.unSelected,
    ),
    title: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        // Text switches to high contrast (appColor near-white) when active
        color: isSelected ? AppColors.appColor : AppColors.unSelected,
      ),
    ).paddingOnly(bottom: 5),
    selectedColor: AppColors.primary, // The highlighted surrounding pill active color
  );
}