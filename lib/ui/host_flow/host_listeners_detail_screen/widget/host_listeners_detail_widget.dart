import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/custom/text_field/custom_text_field.dart';
import 'package:talk_in/custom/title/custom_title.dart';
import 'package:talk_in/ui/host_flow/host_listeners_detail_screen/controller/host_listeners_detail_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class HostListenersDetailTopView extends StatelessWidget {
  const HostListenersDetailTopView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GetBuilder<HostListenersDetailController>(
          builder: (controller) {
            final String? localImagePath = controller.pickImage;

            return SizedBox(
              height: Get.height * 0.38,
              width: Get.width,
              child: localImagePath != null
                  ? Image.file(
                File(localImagePath),
                fit: BoxFit.cover,
              )
                  : CustomProfileImage(
                image: Database.fetchListenerProfileModel?.data?.image ?? '',
              ),
            ).paddingOnly(bottom: 10);
          },
        ),
        Positioned(
          bottom: 22,
          left: 110,
          right: 110,
          child: GestureDetector(
            onTap: () {
              Get.defaultDialog(
                  backgroundColor: AppColors.lightPurple, // Changed from pure white to deep dark card container
                  title: EnumLocale.changeYourImage.name.tr,
                  titlePadding: const EdgeInsets.only(top: 30),
                  titleStyle: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.appDarkColor), // High contrast theme white
                  content: GetBuilder<HostListenersDetailController>(
                    builder: (controller) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Divider(
                              thickness: 1,
                              color: AppColors.borderColor, // Structural dark mode divider lines
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.back();
                              controller.takePhoto();
                            },
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Image(
                                      color: AppColors.appDarkColor, // Re-mapped option icon tints
                                      image: const AssetImage(AppAsset.cameraFlipIcon),
                                      height: 20,
                                    ),
                                  ),
                                  Text(
                                    EnumLocale.txtTakeAphoto.name.tr,
                                    style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.appDarkColor),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              onTap: () {
                                Get.back();
                                controller.getImageFromGallery();
                              },
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Image(
                                        color: AppColors.appDarkColor,
                                        image: const AssetImage(AppAsset.chatImageIcon),
                                        height: 20,
                                      ),
                                    ),
                                    Text(
                                      EnumLocale.txtChooseFromYourFile.name.tr,
                                      style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.appDarkColor),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ));
            },
            child: Container(
              padding: const EdgeInsets.only(top: 6, bottom: 6, left: 9, right: 9),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.30),
                    offset: const Offset(0, 0),
                    spreadRadius: 0,
                    blurRadius: 12.7,
                  ),
                ],
                color: AppColors.black.withValues(alpha: 0.60), // Slightly raised opacity track over dynamic covers
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    AppAsset.uploadImageIcon,
                    color: AppColors.white,
                    height: 14,
                    width: 22,
                  ).paddingOnly(right: 3),
                  Text(
                    EnumLocale.txtChangeImage.name.tr,
                    style: AppFontStyle.fontStyleW800(
                      fontSize: 12,
                      fontColor: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class HostListenersDetailView extends StatelessWidget {
  const HostListenersDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostListenersDetailController>(
      builder: (controller) {
        return Column(
          children: [
            Container(
              width: Get.width,
              color: AppColors.backGroundColor, // Changed block backdrop to primary deep dark layout base
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    EnumLocale.txtListenerDetails.name.tr,
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 17,
                      fontColor: AppColors.appDarkColor, // Fixed hardcoded header blacks to white theme profiles
                    ),
                  ).paddingOnly(top: 16, bottom: 16),
                  CustomTitle(
                    title: EnumLocale.txtEnterName.name.tr,
                    textStyle: AppFontStyle.fontStyleW500(
                      fontSize: 12,
                      fontColor: AppColors.listenersDetail,
                    ),
                    method: CustomTextField(
                      filled: true,
                      borderColor: AppColors.appTextColor.withValues(alpha: 0.18),
                      controller: controller.nameCnt,
                      fillColor: AppColors.lightPurple, // Shifted inner forms from solid light white over to dark panels
                      cursorColor: AppColors.appDarkColor,
                      fontColor: AppColors.appDarkColor,
                      fontSize: 15,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                    ),
                  ).paddingOnly(bottom: 18),
                  CustomTitle(
                    title: EnumLocale.txtNickName.name.tr,
                    textStyle: AppFontStyle.fontStyleW500(
                      fontSize: 12,
                      fontColor: AppColors.listenersDetail,
                    ),
                    method: CustomTextField(
                      filled: true,
                      borderColor: AppColors.appTextColor.withValues(alpha: 0.18),
                      controller: controller.nickNameCnt,
                      fillColor: AppColors.lightPurple,
                      cursorColor: AppColors.appDarkColor,
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
                      fontColor: AppColors.listenersDetail,
                    ),
                    method: CustomTextField(
                      filled: true,
                      borderColor: AppColors.appTextColor.withValues(alpha: 0.18),
                      controller: controller.introCnt,
                      fillColor: AppColors.lightPurple,
                      cursorColor: AppColors.appDarkColor,
                      fontColor: AppColors.appDarkColor,
                      fontSize: 12,
                      textInputAction: TextInputAction.next,
                      maxLines: 5,
                    ),
                  ).paddingOnly(bottom: 21),
                ],
              ).paddingSymmetric(horizontal: 16),
            ).paddingOnly(bottom: 10),
            Container(
              width: Get.width,
              color: AppColors.backGroundColor, // Changed from white to primary deep background
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    EnumLocale.txtTalkLanguages.name.tr,
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 17,
                      fontColor: AppColors.appDarkColor, // Swapped black fonts
                    ),
                  ).paddingOnly(top: 16, bottom: 4),
                  Text(
                    EnumLocale.txtSelectLanguages.name.tr,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 11,
                      fontColor: AppColors.appTextColor,
                    ),
                  ).paddingOnly(top: 4, bottom: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        EnumLocale.txtSelectLanguage.name.tr,
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 16,
                          fontColor: AppColors.appDarkColor, // Corrected label contrast visibility
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.bottomSheet(
                            AllLanguageBottomSheet(),
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.lightPurple, borderRadius: BorderRadius.circular(6)), // Tuned label actions backgrounds
                          child: Text(
                            EnumLocale.txtViewAll.name.tr,
                            style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.appDarkColor),
                          ),
                        ),
                      )
                    ],
                  ).paddingOnly(bottom: 12),
                  GetBuilder<HostListenersDetailController>(
                    id: Constant.idLanguageSection,
                    builder: (controller) {
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: controller.selectedLanguages.map((lang) {
                          final isSelected = controller.isSelected(lang);
                          return GestureDetector(
                            onTap: () => controller.toggleLanguage(lang),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.appColor.withValues(alpha: 0.15) : AppColors.lightPurple, // Wrapped selector shapes inside premium backdrops
                                border: Border.all(
                                  color: isSelected ? AppColors.appColor : AppColors.borderColor,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                lang,
                                style: AppFontStyle.fontStyleW500(
                                  fontSize: 13,
                                  fontColor: isSelected ? AppColors.appColor : AppColors.appTextColor,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ).paddingOnly(bottom: 16);
                    },
                  ),
                ],
              ).paddingSymmetric(horizontal: 16),
            ).paddingOnly(bottom: 10),
            Container(
              width: Get.width,
              color: AppColors.backGroundColor, // Changed from white to primary deep background
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
                      fontColor: AppColors.appTextColor,
                    ),
                  ).paddingOnly(top: 4, bottom: 14),
                  GetBuilder<HostListenersDetailController>(
                    id: Constant.talkAboutTopic,
                    builder: (controller) {
                      return ListView.builder(
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
                                color: AppColors.lightPurple, // Soft elevated container surface base
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.appColor : AppColors.borderColor,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    topic.name.toString(),
                                    style: isSelected
                                        ? AppFontStyle.fontStyleW600(
                                      fontSize: 14,
                                      fontColor: AppColors.appColor,
                                    )
                                        : AppFontStyle.fontStyleW500(
                                      fontSize: 14,
                                      fontColor: AppColors.appTextColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    height: 22,
                                    width: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: isSelected ? AppColors.transparent : AppColors.borderColor),
                                      color: isSelected ? AppColors.lightPurple1 : AppColors.backGroundColor, // Inverted radio configurations to track cleanly
                                    ),
                                    child: isSelected
                                        ? Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.appColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Container(
                                        height: 22,
                                        width: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.lightPurple),
                                          color: AppColors.appColor,
                                        ),
                                      ).paddingAll(0.5),
                                    )
                                        : null,
                                  ),
                                ],
                              ),
                            ).paddingOnly(bottom: 16),
                          );
                        },
                      );
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTitle(
                          title: EnumLocale.txtPrivateVideoCallRate.name.tr,
                          textStyle: AppFontStyle.fontStyleW500(
                            fontSize: 12,
                            fontColor: AppColors.listenersDetail,
                          ),
                          method: CustomTextField(
                            filled: true,
                            borderColor: AppColors.appTextColor.withValues(alpha: 0.18),
                            controller: controller.ratePrivateVideoCallCnt,
                            fillColor: AppColors.lightPurple,
                            cursorColor: AppColors.appDarkColor,
                            fontColor: AppColors.appDarkColor,
                            fontSize: 15,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                            textInputType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ).paddingOnly(bottom: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTitle(
                          title: EnumLocale.txtPrivateAudioCallRate.name.tr,
                          textStyle: AppFontStyle.fontStyleW500(
                            fontSize: 12,
                            fontColor: AppColors.listenersDetail,
                          ),
                          method: CustomTextField(
                            filled: true,
                            borderColor: AppColors.appTextColor.withValues(alpha: 0.18),
                            controller: controller.ratePrivateAudioCallCnt,
                            fillColor: AppColors.lightPurple,
                            cursorColor: AppColors.appDarkColor,
                            fontColor: AppColors.appDarkColor,
                            fontSize: 15,
                            textInputAction: TextInputAction.next,
                            textInputType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLines: 1,
                          ),
                        ).paddingOnly(bottom: 18),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTitle(
                          title: EnumLocale.txtRandomVideoCallRate.name.tr,
                          textStyle: AppFontStyle.fontStyleW500(
                            fontSize: 12,
                            fontColor: AppColors.listenersDetail,
                          ),
                          method: CustomTextField(
                            filled: true,
                            borderColor: AppColors.appTextColor.withValues(alpha: 0.18),
                            controller: controller.rateRandomVideoCallCnt,
                            fillColor: AppColors.lightPurple,
                            cursorColor: AppColors.appDarkColor,
                            fontColor: AppColors.appDarkColor,
                            fontSize: 15,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                            textInputType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ).paddingOnly(bottom: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomTitle(
                          title: EnumLocale.txtRandomAudioCallRate.name.tr,
                          textStyle: AppFontStyle.fontStyleW500(
                            fontSize: 12,
                            fontColor: AppColors.listenersDetail,
                          ),
                          method: CustomTextField(
                            filled: true,
                            borderColor: AppColors.appTextColor.withValues(alpha: 0.18),
                            controller: controller.rateRandomAudioCallCnt,
                            fillColor: AppColors.lightPurple,
                            cursorColor: AppColors.appDarkColor,
                            fontColor: AppColors.appDarkColor,
                            fontSize: 15,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                            textInputType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ).paddingOnly(bottom: 18),
                      ),
                    ],
                  )
                ],
              ).paddingSymmetric(horizontal: 16),
            ).paddingOnly(bottom: 10),
          ],
        );
      },
    );
  }
}

class HostListenersDetailBottomButton extends StatelessWidget {
  const HostListenersDetailBottomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostListenersDetailController>(
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.backGroundColor, // Changed from white to primary background slat
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.20),
                offset: const Offset(0, -2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: PrimaryAppButton(
            height: 47,
            onTap: () {
              if (Database.demoListener == true) {
                Utils.showToast(Get.context!, EnumLocale.txtDEmoListenerText.name.tr);
              } else {
                controller.onSaveProfile();
              }
            },
            child: Center(
              child: Text(
                EnumLocale.txtSAVED.name.tr,
                style: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
              ),
            ),
          ).paddingOnly(bottom: 10),
        );
      },
    );
  }
}

class AllLanguageBottomSheet extends StatelessWidget {
  AllLanguageBottomSheet({super.key});

  final controller = Get.find<HostListenersDetailController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.6,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.lightPurple, // Changed from white to deep bottom sheet background card
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: GetBuilder<HostListenersDetailController>(
        id: Constant.idLanguageSection,
        builder: (_) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    EnumLocale.txtSelectLanguage.name.tr,
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 16,
                      fontColor: AppColors.appDarkColor, // Replaced light-theme black configurations
                    ),
                  ).paddingOnly(bottom: 20, top: 20),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.lightPurple1, // Mapped button tracks
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Done",
                        style: AppFontStyle.fontStyleW500(fontSize: 14, fontColor: AppColors.appDarkColor),
                      ),
                    ),
                  )
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: controller.allLanguages.map((lang) {
                      final isSelected = controller.isSelected(lang);
                      return GestureDetector(
                        onTap: () => controller.toggleLanguage(lang),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.appColor.withValues(alpha: 0.15) : AppColors.backGroundColor, // Wrapped layout selectors inside polished tints
                            border: Border.all(
                              color: isSelected ? AppColors.appColor : AppColors.borderColor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            lang,
                            style: AppFontStyle.fontStyleW500(
                              fontSize: 13,
                              fontColor: isSelected ? AppColors.appColor : AppColors.appTextColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ).paddingOnly(bottom: 16),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}