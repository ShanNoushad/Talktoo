import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/setting_menu_ui/setting_menu.dart';
import 'package:talk_in/ui/user_flow/help_center_screen/controller/help_center_screen_controller.dart';
import 'package:talk_in/ui/user_flow/help_center_screen/shimmer/help_center_shimmer.dart';
import 'package:talk_in/ui/user_flow/help_center_screen/widget/help_center_screen_widget.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor, // Changed from hardcoded AppColors.black to semantic main background
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.backGroundColor, // Ensures the app bar blend is seamless
        elevation: 0,
        flexibleSpace: const HelpCenterAppBar(),
      ),
      body: SafeArea(
        child: GetBuilder<HelpCenterScreenController>(builder: (logic) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingMainMenu(
                  imageHeight: 75,
                  rightSpace: Get.width * 0.012,
                  text: EnumLocale.txtNeedAnyHelpFAQ.name.tr,
                  subText: EnumLocale.txtHelpCenterDescription.name.tr,
                  topImage: AppAsset.helpCenterBlur,
                ).paddingOnly(bottom: 20),
                SettingMenu(
                  icon: AppAsset.helpCenterGirl,
                  title: EnumLocale.txtHaveAnIssue.name.tr,
                  onTap: () async {
                    final helpdeskEmail = Database.settingApiModel?.data?.helpdeskEmail ?? '';
                    final userEmail = Database.fetchLoginUserProfileModel?.user?.email ?? 'no-reply@yourapp.com';

                    if (helpdeskEmail.isEmpty) {
                      Get.snackbar("Error", "Helpdesk email not available");
                      return;
                    }

                    final Uri emailUri = Uri(
                      scheme: 'mailto',
                      path: helpdeskEmail,
                      query: Uri.encodeFull(
                        'subject=Support Request from $userEmail&body=User Email: $userEmail\n\nPlease describe your issue here.',
                      ),
                    );

                    if (await canLaunchUrl(emailUri)) {
                      await launchUrl(emailUri);
                    } else {
                      Get.snackbar("Error", "Could not open email client");
                    }
                  },
                ).paddingOnly(bottom: 22),
                Text(
                  EnumLocale.txtFrequentlyAskedQuestions.name.tr,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 16,
                    fontColor: AppColors.appDarkColor, // Lightened: changed from black to brightest text
                  ),
                ).paddingSymmetric(horizontal: 16),
                GetBuilder<HelpCenterScreenController>(
                  id: Constant.idFAQListeners,
                  builder: (controller) {
                    return controller.isLoading
                        ? HelpCenterShimmer()
                        : Column(
                      children: List.generate(controller.faqList.length, (index) {
                        final faq = controller.faqList[index];
                        final isExpanded = controller.expandedIndex == index;

                        return SettingMainMenuListTile(
                          title: faq.question ?? '',
                          subTitle: faq.answer ?? '',
                          isExpanded: isExpanded,
                          onTap: () => controller.toggleExpansion(index),
                        ).paddingOnly(top: 14, bottom: 4); // Adjusted padding for smoother list rhythm
                      }),
                    );
                  },
                )
              ],
            ),
          );
        }),
      ),
    );
  }
}