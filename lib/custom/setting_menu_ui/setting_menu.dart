import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/font_style.dart';

class SettingMenu extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;
  final Widget? widget;

  const SettingMenu({super.key, required this.icon, required this.title, required this.onTap, this.widget});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Moving structural padding to explicit margins handles layout updates cleaner
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.profileOption,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16), // Keeps splash bounded perfectly to container geometry
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.purple100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                icon,
                height: 33,
                width: 33,
                color: AppColors.purple400,
              ),
            ).paddingAll(7),
            Expanded(
              child: Text(
                title,
                style: AppFontStyle.fontStyleW600(
                  fontSize: 16,
                  fontColor: AppColors.appDarkColor,
                ),
              ).paddingOnly(left: 12),
            ),
            widget ??
                RotatedBox(
                    quarterTurns: 2,
                    child: Image.asset(
                      AppAsset.backArrowIcon,
                      height: 13,
                      width: 13,
                      color: AppColors.grey,
                    )).paddingAll(15),
          ],
        ),
      ),
    );
  }
}

class SettingMainMenu extends StatelessWidget {
  final String text;
  final String subText;
  final String topImage;
  final double rightSpace;
  final double? imageHeight;
  const SettingMainMenu({
    super.key,
    required this.text,
    required this.subText,
    required this.topImage,
    required this.rightSpace,
    this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity, // Forces full width alignment over varied device displays
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.setting,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Get.width * 0.76,
                      child: Text(
                        text,
                        style: AppFontStyle.fontStyleW800(
                          fontSize: 20,
                          fontColor: AppColors.appDarkColor,
                        ),
                      ).paddingOnly(bottom: 4),
                    ),
                    SizedBox(
                      width: Get.width * 0.7,
                      child: Text(
                        subText,
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 11,
                          fontColor: AppColors.profileText,
                          height: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).paddingOnly(top: 10),
        Positioned(
          right: rightSpace,
          top: Get.height * 0.017,
          child: Image.asset(
            topImage,
            height: imageHeight ?? 90,
          ),
        ),
      ],
    );
  }
}

class SettingMainMenuListTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final bool isExpanded;
  final VoidCallback onTap;

  const SettingMainMenuListTile({
    super.key,
    required this.title,
    required this.subTitle,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16), // Replaced padding extension with performance-friendly margins
      decoration: BoxDecoration(
        color: AppColors.lightPurple1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: UniqueKey(),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            onTap();
          },
          shape: const Border(), // Replaced runtime execution target with static abstract zero geometry border
          childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          collapsedIconColor: AppColors.grey,
          iconColor: AppColors.primary,
          title: Text(
            title,
            style: AppFontStyle.fontStyleW600(
              fontSize: 16,
              fontColor: AppColors.appDarkColor,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                subTitle,
                style: AppFontStyle.fontStyleW400(
                  fontColor: AppColors.profileText,
                  fontSize: 13,
                ),
              ),
            ).paddingOnly(bottom: 10),
          ],
        ),
      ),
    );
  }
}