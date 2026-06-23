import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/text_field/custom_text_field.dart';
import 'package:talk_in/custom/title/custom_title.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/controller/host_verification_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class HostVerificationAppBar extends StatelessWidget {
  const HostVerificationAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: CustomAppBar(
        appBarColor: AppColors.backGroundColor, // Seamless background canvas integration
        title: EnumLocale.txtListenerVerification.name.tr,
        textColor: AppColors.appDarkColor, // Light text typography adaptation
        showLeadingIcon: true,
      ),
    );
  }
}

class HostVerificationUploadImageView extends StatefulWidget {
  const HostVerificationUploadImageView({super.key});

  @override
  State<HostVerificationUploadImageView> createState() => _HostVerificationUploadImageViewState();
}

class _HostVerificationUploadImageViewState extends State<HostVerificationUploadImageView> {
  XFile? xFiles;
  final ImagePicker imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      color: AppColors.backGroundColor, // Full page section dark surface layout match
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EnumLocale.txtUploadImages.name.tr,
            style: AppFontStyle.fontStyleW700(
              fontSize: 17,
              fontColor: AppColors.appDarkColor, // Dark background crisp typography flip
            ),
          ),
          Text(
            EnumLocale.txtHostVerificationUploadImageTxt.name.tr,
            style: AppFontStyle.fontStyleW500(
              fontSize: 11,
              fontColor: AppColors.profileText,
              height: 1.8,
            ),
          ).paddingOnly(top: 4, bottom: 18),

          // Identity Proof Dropdown Selection Panel
          GetBuilder<HostVerificationController>(
            id: Constant.idIdentityProof,
            builder: (controller) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.lightPurple1, // Elevated dropdown list background surface
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.purpleBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      onTap: controller.toggleIdentityExpansion,
                      title: Text(
                        controller.selectedIdentityProof?.title ?? EnumLocale.txtSelectIdentityProof.name.tr,
                        style: controller.selectedIdentityProof == null
                            ? AppFontStyle.fontStyleW500(
                          fontSize: 14,
                          fontColor: AppColors.profileText,
                        )
                            : AppFontStyle.fontStyleW600(
                          fontSize: 14,
                          fontColor: AppColors.appDarkColor,
                        ),
                      ),
                      trailing: Icon(
                        controller.isIdentityExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.profileText,
                      ),
                    ),
                    if (controller.isIdentityExpanded)
                      Column(
                        children: List.generate(controller.identityProofList.length, (index) {
                          final item = controller.identityProofList[index];
                          return ListTile(
                            title: Text(
                              item.title ?? '',
                              style: AppFontStyle.fontStyleW500(
                                fontSize: 14,
                                fontColor: AppColors.appDarkColor,
                              ),
                            ),
                            onTap: () => controller.selectIdentityProof(item),
                          );
                        }),
                      ),
                  ],
                ),
              ).paddingOnly(bottom: 24);
            },
          ),

          // Triple Media Action/Display Modules Grid Row
          GetBuilder<HostVerificationController>(
            id: Constant.idIdentityProof,
            builder: (controller) {
              return Row(
                children: [
                  // 1. Personal Photo Module Slot
                  Expanded(
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        radius: const Radius.circular(14),
                        padding: EdgeInsets.zero,
                        color: AppColors.purpleBorder,
                        dashPattern: const [4, 6],
                        strokeWidth: 1,
                      ),
                      child: controller.personalPhoto == null
                          ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: AppColors.lightPurple1,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppAsset.uploadImage,
                              height: 45,
                              width: 45,
                            ).paddingOnly(top: 17),
                            Text(
                              EnumLocale.txtUploadImag.name.tr,
                              style: AppFontStyle.fontStyleW600(
                                fontSize: 11,
                                fontColor: AppColors.appDarkColor,
                              ),
                            ).paddingOnly(top: 10),
                            Text(
                              EnumLocale.txtPersonalPhotos.name.tr,
                              style: AppFontStyle.fontStyleW600(
                                fontSize: 9,
                                fontColor: AppColors.profileText,
                              ),
                            ).paddingOnly(top: 6, bottom: 7),
                            GestureDetector(
                              onTap: () => controller.pickImage(isPersonalPhoto: true),
                              child: Container(
                                width: Get.width,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    EnumLocale.txtCapture.name.tr,
                                    style: AppFontStyle.fontStyleW600(fontSize: 10, fontColor: AppColors.white),
                                  ),
                                ),
                              ).paddingOnly(bottom: 10, left: 10, right: 10),
                            ),
                          ],
                        ),
                      )
                          : Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                File(controller.personalPhoto!),
                                fit: BoxFit.cover,
                              ),
                            ).paddingAll(8),
                          ),
                          Positioned(
                            top: -10,
                            right: -8,
                            child: GestureDetector(
                              onTap: () {
                                controller.personalPhoto = null;
                                controller.update([Constant.idIdentityProof]);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                                child:  Icon(
                                  Icons.close,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // 2. ID Front Side Media Slot
                  Expanded(
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        radius: const Radius.circular(14),
                        padding: EdgeInsets.zero,
                        color: AppColors.purpleBorder,
                        dashPattern: const [4, 6],
                        strokeWidth: 1,
                      ),
                      child: controller.idProofPhoto1 == null
                          ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: AppColors.lightPurple1,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppAsset.uploadIdImage,
                              height: 45,
                              width: 45,
                            ).paddingOnly(top: 17),
                            Text(
                              EnumLocale.txtUploadIDPhotos.name.tr,
                              style: AppFontStyle.fontStyleW600(
                                fontSize: 11,
                                fontColor: AppColors.appDarkColor,
                              ),
                            ).paddingOnly(top: 10),
                            Text(
                              EnumLocale.txtFrontSide.name.tr,
                              style: AppFontStyle.fontStyleW600(
                                fontSize: 9,
                                fontColor: AppColors.profileText,
                              ),
                            ).paddingOnly(top: 6, bottom: 7),
                            GestureDetector(
                              onTap: () => controller.pickImage(isPersonalPhoto: false),
                              child: Container(
                                width: Get.width,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    EnumLocale.txtAttach.name.tr,
                                    style: AppFontStyle.fontStyleW600(fontSize: 10, fontColor: AppColors.white),
                                  ),
                                ),
                              ).paddingOnly(bottom: 10, left: 10, right: 10),
                            ),
                          ],
                        ),
                      )
                          : Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                File(controller.idProofPhoto1!),
                                fit: BoxFit.cover,
                              ),
                            ).paddingAll(8),
                          ),
                          Positioned(
                            top: -10,
                            right: -8,
                            child: GestureDetector(
                              onTap: () {
                                controller.idProofPhoto1 = null;
                                controller.update([Constant.idIdentityProof]);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                                child:  Icon(
                                  Icons.close,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // 3. ID Back Side Media Slot
                  Expanded(
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        radius: const Radius.circular(14),
                        padding: EdgeInsets.zero,
                        color: AppColors.purpleBorder,
                        dashPattern: const [4, 6],
                        strokeWidth: 1,
                      ),
                      child: controller.idProofPhoto2 == null
                          ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: AppColors.lightPurple1,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppAsset.uploadIdImage,
                              height: 45,
                              width: 45,
                            ).paddingOnly(top: 17),
                            Text(
                              EnumLocale.txtUploadIDPhotos.name.tr,
                              style: AppFontStyle.fontStyleW600(
                                fontSize: 11,
                                fontColor: AppColors.appDarkColor,
                              ),
                            ).paddingOnly(top: 10),
                            Text(
                              EnumLocale.txtBackSide.name.tr,
                              style: AppFontStyle.fontStyleW600(
                                fontSize: 9,
                                fontColor: AppColors.profileText,
                              ),
                            ).paddingOnly(top: 6, bottom: 7),
                            GestureDetector(
                              onTap: () => controller.pickImage(isPersonalPhoto: false),
                              child: Container(
                                width: Get.width,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    EnumLocale.txtAttach.name.tr,
                                    style: AppFontStyle.fontStyleW600(fontSize: 10, fontColor: AppColors.white),
                                  ),
                                ),
                              ).paddingOnly(bottom: 10, left: 10, right: 10),
                            ),
                          ],
                        ),
                      )
                          : Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                File(controller.idProofPhoto2!),
                                fit: BoxFit.cover,
                              ),
                            ).paddingAll(8),
                          ),
                          Positioned(
                            top: -10,
                            right: -8,
                            child: GestureDetector(
                              onTap: () {
                                controller.idProofPhoto2 = null;
                                controller.update([Constant.idIdentityProof]);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                                child:  Icon(
                                  Icons.close,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          )
        ],
      ),
    ).paddingOnly(bottom: 10);
  }
}

class HostVerificationFillFormView extends StatelessWidget {
  const HostVerificationFillFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.backGroundColor, // Core canvas block wrapper dark sync
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EnumLocale.txtFillForm.name.tr,
            style: AppFontStyle.fontStyleW700(
              fontSize: 17,
              fontColor: AppColors.appDarkColor,
            ),
          ),
          Text(
            EnumLocale.txtHostVerificationFillForm.name.tr,
            style: AppFontStyle.fontStyleW500(
              fontSize: 11,
              fontColor: AppColors.profileText,
              height: 1.8,
            ),
          ).paddingOnly(top: 4, bottom: 24),
          GetBuilder<HostVerificationController>(
            builder: (logic) {
              return Form(
                key: logic.formKey,
                child: Column(
                  children: [
                    if (Database.loginType != 2)
                      CustomTitle(
                        title: EnumLocale.txtEnterMail.name.tr,
                        textStyle: AppFontStyle.fontStyleW500(
                          fontSize: 12,
                          fontColor: AppColors.profileText,
                        ),
                        method: CustomTextField(
                          filled: true,
                          borderColor: AppColors.purpleBorder,
                          controller: logic.emailController,
                          fillColor: AppColors.lightPurple1, // Dark form field slot fill match
                          cursorColor: AppColors.primary,
                          fontColor: AppColors.appDarkColor,
                          fontSize: 15,
                          textInputAction: TextInputAction.next,
                          textInputType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return EnumLocale.desEnterEmail.name.tr;
                            } else if (!logic.isEmailValid(value)) {
                              return EnumLocale.desEnterValidEmailAddress.name.tr;
                            } else if (!value.toLowerCase().endsWith('@gmail.com')) {
                              return 'Please enter a Gmail address';
                            }
                            return null;
                          },
                        ),
                      ).paddingOnly(bottom: 21),
                    CustomTitle(
                      title: EnumLocale.txtEnterYourAddress.name.tr,
                      textStyle: AppFontStyle.fontStyleW500(
                        fontSize: 12,
                        fontColor: AppColors.profileText,
                      ),
                      method: CustomTextField(
                        filled: true,
                        borderColor: AppColors.purpleBorder,
                        controller: logic.addressController,
                        fillColor: AppColors.lightPurple1,
                        cursorColor: AppColors.primary,
                        fontColor: AppColors.appDarkColor,
                        fontSize: 15,
                        textInputAction: TextInputAction.next,
                        maxLines: 1,
                      ),
                    ).paddingOnly(bottom: 21),
                    CustomTitle(
                      title: EnumLocale.txtCountry.name.tr,
                      textStyle: AppFontStyle.fontStyleW500(
                        fontSize: 12,
                        fontColor: AppColors.profileText,
                      ),
                      method: CustomTextField(
                        filled: true,
                        borderColor: AppColors.purpleBorder,
                        controller: logic.countryCnt,
                        fillColor: AppColors.lightPurple1,
                        cursorColor: AppColors.primary,
                        fontColor: AppColors.appDarkColor,
                        fontSize: 15,
                        textInputAction: TextInputAction.next,
                        maxLines: 1,
                      ),
                    ).paddingOnly(bottom: 21),
                    CustomTitle(
                      title: EnumLocale.txtEnterYourAge.name.tr,
                      textStyle: AppFontStyle.fontStyleW500(
                        fontSize: 12,
                        fontColor: AppColors.profileText,
                      ),
                      method: CustomTextField(
                        filled: true,
                        borderColor: AppColors.purpleBorder,
                        controller: logic.ageController,
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
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class HostVerificationBottomButton extends StatelessWidget {
  const HostVerificationBottomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backGroundColor, // Swapped pure light docking surface for dark background
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.35), // Dark shadow density scaling
            offset: const Offset(0, -2), // Glow points up onto screen text contents tracking scroll edges
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: GetBuilder<HostVerificationController>(
        builder: (controller) {
          return PrimaryAppButton(
            onTap: () {
              controller.validateAndNext();
            },
            height: Get.height * 0.06,
            text: EnumLocale.txtNext.name.tr,
            textStyle: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
          ).paddingOnly(bottom: 10);
        },
      ),
    );
  }
}