import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/ui/user_flow/listener_screen/controller/listeners_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class AppLanguageBottomSheet extends StatefulWidget {
  const AppLanguageBottomSheet({super.key});

  @override
  State<AppLanguageBottomSheet> createState() => _AppLanguageBottomSheetState();
}

class _AppLanguageBottomSheetState extends State<AppLanguageBottomSheet> {
  ListenersScreenController controller = Get.find();

  static const Set<String> allowedLanguages = {
    'Malayalam',
    'Tamil',
    'Hindi',
    'Kannada',
    'Telugu',
    'English',
  };

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.only(top: 15),
            decoration:  BoxDecoration(
              color: AppColors.lightPurple,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: GetBuilder<ListenersScreenController>(builder: (controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header ───────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppAsset.speakingBoy,
                        height: 28,
                        width: 28,
                        color: AppColors.darkOrange,
                      ),
                      Text(
                        EnumLocale.txtAPPLanguage.name.tr,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 20,
                          fontColor: AppColors.darkOrange,
                        ),
                      ).paddingOnly(bottom: 12, left: Get.width * 0.03),
                      Spacer(),
                      InkWell(
                        onTap: () => Get.back(),
                        child: Image.asset(
                          AppAsset.closeFillIcon,
                          height: 26,
                        ),
                      ),
                    ],
                  ).paddingSymmetric(horizontal: 16),

                  // ── Subtitle ─────────────────────────────────────────
                  Text(
                    EnumLocale.txtSelectAppLanguageTxt.name.tr,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 13,
                      fontColor: AppColors.white,
                    ),
                  ).paddingOnly(bottom: 26, right: 16, left: 16),

                  // ── Search + Grid ─────────────────────────────────────
                  GetBuilder<ListenersScreenController>(
                    builder: (controller) {
                      final visibleLanguages = controller.filteredLanguages
                          .where((lang) => allowedLanguages.contains(lang))
                          .toList();

                      return Expanded(
                        child: Column(
                          children: [
                            // Search bar
                            TextField(
                              cursorColor: AppColors.grey,
                              onChanged: (value) =>
                                  controller.updateLanguageSearchQuery(value),
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide:
                                  BorderSide(color: AppColors.grey),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide:
                                  BorderSide(color: AppColors.grey),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                hintText:
                                EnumLocale.txtSearchLanguage.name.tr,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                prefixIcon: Icon(Icons.search,
                                    color: AppColors.grey),
                              ),
                            ).paddingOnly(bottom: 12, left: 16, right: 16),

                            // Language grid — only allowed 6
                            Expanded(
                              child: GridView.builder(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 10),
                                gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 2.8,
                                ),
                                itemCount: visibleLanguages.length,
                                itemBuilder: (context, index) {
                                  final lang = visibleLanguages[index];
                                  final isSelected =
                                  controller.isSelected(lang);

                                  return GestureDetector(
                                    onTap: () =>
                                        controller.toggleLanguage(lang),
                                    child: Container(
                                      padding:
                                      EdgeInsets.only(left: 4, right: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.white
                                              : AppColors.grey,
                                          width: 1,
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(12),
                                      ),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Center(
                                            child: Text(
                                              lang,
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              style:
                                              AppFontStyle.fontStyleW600(
                                                fontSize: 15,
                                                fontColor: AppColors.white,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Positioned(
                                              top: -10,
                                              right: -5,
                                              child: Image.asset(
                                                AppAsset.selectIcon,
                                                height: 24,
                                                width: 24,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // ── Submit / Clear buttons ────────────────────────────
                  Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: PrimaryAppButton(
                            onTap: () {
                              controller.filterListenerByLanguage();
                              Get.back();
                            },
                            height: 47,
                            borderRadius: 30,
                            text: EnumLocale.txtSubmit.name.tr,
                            textStyle: AppFontStyle.fontStyleW600(
                                fontSize: 16, fontColor: AppColors.white),
                          ).paddingOnly(bottom: 10),
                        ),
                        controller.selectedLanguages.isNotEmpty
                            ? 15.width
                            : Offstage(),
                        controller.selectedLanguages.isNotEmpty
                            ? Expanded(
                          child: PrimaryAppButton(
                            onTap: () {
                              controller.clearSelectedLanguages();
                            },
                            height: 47,
                            borderRadius: 30,
                            text: EnumLocale.txtClear.name.tr,
                            textStyle: AppFontStyle.fontStyleW600(
                                fontSize: 16,
                                fontColor: AppColors.white),
                          ).paddingOnly(bottom: 10),
                        )
                            : Offstage(),
                      ],
                    ).paddingOnly(left: 16, right: 16, top: 10),
                  ),
                ],
              );
            }),
          );
        },
      ),
    );
  }
}