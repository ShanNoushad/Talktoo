import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/bottom_sheet/all_language_bottom_sheet.dart';
import 'package:talk_in/custom/text_field/custom_text_field.dart';
import 'package:talk_in/custom/title/custom_title.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/controller/host_verification_controller.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class HostVerificationListenersDetailAppBar extends StatelessWidget {
  const HostVerificationListenersDetailAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: CustomAppBar(
        appBarColor: AppColors.backGroundColor, // Seamless dark background anchoring
        title: EnumLocale.txtListenerVerification.name.tr,
        textColor: AppColors.white, // Crisp light text contrast
        showLeadingIcon: true,
      ),
    );
  }
}

class HostVerificationListenersDetailView extends StatelessWidget {
  const HostVerificationListenersDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostVerificationController>(
      builder: (controller) {
        return Column(
          children: [
            // Section 1: Core Form Fields Container
            Container(
              width: Get.width,
              color: AppColors.backGroundColor, // Dark background base canvas
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    EnumLocale.txtListenerDetails.name.tr,
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 17,
                      fontColor: AppColors.appDarkColor, // Flipped from hardcoded black
                    ),
                  ).paddingOnly(top: 16, bottom: 16),
                  CustomTitle(
                    title: EnumLocale.txtEnterName.name.tr,
                    textStyle: AppFontStyle.fontStyleW500(
                      fontSize: 12,
                      fontColor: AppColors.profileText, // Standard subtle text label
                    ),
                    method: CustomTextField(
                      filled: true,
                      borderColor: AppColors.purpleBorder,
                      controller: controller.nameController,
                      fillColor: AppColors.lightPurple1, // Elevated field body
                      cursorColor: AppColors.primary,
                      fontColor: AppColors.appDarkColor,
                      fontSize: 15,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                    ),
                  ).paddingOnly(bottom: 18),
                  CustomTitle(
                    title: EnumLocale.txtEnterNickName.name.tr,
                    textStyle: AppFontStyle.fontStyleW500(
                      fontSize: 12,
                      fontColor: AppColors.profileText,
                    ),
                    method: CustomTextField(
                      filled: true,
                      borderColor: AppColors.purpleBorder,
                      controller: controller.nickNameController,
                      fillColor: AppColors.lightPurple1,
                      cursorColor: AppColors.primary,
                      fontColor: AppColors.appDarkColor,
                      fontSize: 15,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                    ),
                  ).paddingOnly(bottom: 18),
                  CustomTitle(
                    title: EnumLocale.txtGender.name.tr,
                    textStyle: AppFontStyle.fontStyleW500(
                      fontSize: 12,
                      fontColor: AppColors.profileText,
                    ),
                    method: CustomTextField(
                      filled: true,
                      borderColor: AppColors.purpleBorder,
                      controller: controller.genderCnt,
                      fillColor: AppColors.lightPurple1,
                      cursorColor: AppColors.primary,
                      fontColor: AppColors.appDarkColor,
                      fontSize: 15,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                    ),
                  ).paddingOnly(bottom: 18),
                  CustomTitle(
                    title: EnumLocale.txtEnterIntroduction.name.tr,
                    textStyle: AppFontStyle.fontStyleW500(
                      fontSize: 12,
                      fontColor: AppColors.profileText,
                    ),
                    method: CustomTextField(
                      filled: true,
                      borderColor: AppColors.purpleBorder,
                      controller: controller.introCnt,
                      fillColor: AppColors.lightPurple1,
                      cursorColor: AppColors.primary,
                      fontColor: AppColors.appDarkColor,
                      fontSize: 12,
                      textInputAction: TextInputAction.next,
                      maxLines: 5,
                    ),
                  ).paddingOnly(bottom: 21),
                  CustomTitle(
                    title: EnumLocale.txtEnterYourExperience.name.tr,
                    textStyle: AppFontStyle.fontStyleW500(
                      fontSize: 12,
                      fontColor: AppColors.profileText,
                    ),
                    method: CustomTextField(
                      filled: true,
                      borderColor: AppColors.purpleBorder,
                      controller: controller.experienceCnt,
                      fillColor: AppColors.lightPurple1,
                      cursorColor: AppColors.primary,
                      fontColor: AppColors.appDarkColor,
                      fontSize: 15,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                      textInputType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                    ),
                  ).paddingOnly(bottom: 21),
                ],
              ).paddingSymmetric(horizontal: 16),
            ).paddingOnly(bottom: 10, top: 10),

            // Section 2: Languages Selection Container
            Container(
              width: Get.width,
              color: AppColors.backGroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    EnumLocale.txtTalkLanguages.name.tr,
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 17,
                      fontColor: AppColors.appDarkColor,
                    ),
                  ).paddingOnly(top: 16, bottom: 4),
                  Text(
                    EnumLocale.txtSelectLanguages.name.tr,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 11,
                      fontColor: AppColors.profileText,
                    ),
                  ).paddingOnly(top: 4, bottom: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        EnumLocale.txtSelectLanguage.name.tr,
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 16,
                          fontColor: AppColors.appDarkColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.bottomSheet(
                            const AllLanguageBottomSheet(),
                            isScrollControlled: true,
                            backgroundColor: AppColors.transparent,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.lightPurple1,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.purpleBorder),
                          ),
                          child: Text(
                            EnumLocale.txtViewAll.name.tr,
                            style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.primary),
                          ),
                        ),
                      )
                    ],
                  ).paddingOnly(bottom: 12),
                  GetBuilder<HostVerificationController>(
                    builder: (controller) {
                      return Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: controller.selectedLanguages.map((lang) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.lightPurple1,
                              border: Border.all(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              lang,
                              style: AppFontStyle.fontStyleW500(
                                fontSize: 13,
                                fontColor: AppColors.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ).paddingOnly(bottom: 14);
                    },
                  )
                ],
              ).paddingSymmetric(horizontal: 16),
            ).paddingOnly(bottom: 10),

            // Section 3: Topics Selection List Container
            GetBuilder<HostVerificationController>(
              builder: (controller) {
                return Container(
                  width: Get.width,
                  color: AppColors.backGroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${EnumLocale.txtTalkAbout.name.tr} :-",
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 17,
                          fontColor: AppColors.appDarkColor,
                        ),
                      ).paddingOnly(top: 16, bottom: 4),
                      Text(
                        EnumLocale.txtSelectTopic.name.tr,
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 11,
                          fontColor: AppColors.profileText,
                        ),
                      ).paddingOnly(top: 4, bottom: 14),
                      ListView.builder(
                        itemCount: controller.talkTopic.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final topic = controller.talkTopic[index];
                          bool isSelected = controller.selectedTopics.contains(index);

                          return GestureDetector(
                            onTap: () => controller.selectTopic(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                              width: Get.width,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.lightPurple1 : AppColors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.purpleBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    topic.name.toString(),
                                    style: isSelected
                                        ? AppFontStyle.fontStyleW600(
                                      fontSize: 14,
                                      fontColor: AppColors.primary,
                                    )
                                        : AppFontStyle.fontStyleW500(
                                      fontSize: 14,
                                      fontColor: AppColors.profileText,
                                    ),
                                  ),
                                  const Spacer(),
                                  // Dark UI adapted radio circle selector
                                  Container(
                                    height: 22,
                                    width: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.grey),
                                      color: isSelected ? AppColors.primary : AppColors.transparent,
                                    ),
                                    child: isSelected
                                        ? Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.appDarkColor, // Dark core dot inside radio ring
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                        : null,
                                  ),
                                ],
                              ),
                            ).paddingOnly(bottom: 16),
                          );
                        },
                      )
                    ],
                  ).paddingSymmetric(horizontal: 16),
                ).paddingOnly(bottom: 10);
              },
            ),
          ],
        );
      },
    );
  }
}

class HostVerificationListenersDetailBottomButton extends StatelessWidget {
  const HostVerificationListenersDetailBottomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backGroundColor, // Replaced pure white background card dock
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.35), // Darkened ambient shadow for deep canvas blend
            offset: const Offset(0, -2), // Replaced downwards shadow with soft layout top-elevation rim glow
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: GetBuilder<HostVerificationController>(
        id: Constant.idBecomeHost,
        builder: (controller) {
          return PrimaryAppButton(
            onTap: () {
              controller.validateAndSubmit();
            },
            height: Get.height * 0.06,
            text: EnumLocale.txtSUBMIT.name.tr,
            textStyle: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
          ).paddingOnly(bottom: 10);
        },
      ),
    );
  }
}