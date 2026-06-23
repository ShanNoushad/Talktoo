import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/chat_list_search_screen/controller/chat_list_search_controller.dart';
import 'package:talk_in/ui/user_flow/chat_screen/widget/chat_screen_widget.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';

class ChatListSearchWidget extends StatelessWidget {
  const ChatListSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar row ──────────────────────────────────────────
            GetBuilder<ChatListSearchController>(
              builder: (controller) {
                return Container(
                  color: AppColors.backGroundColor,
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 4),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Get.back(),
                        borderRadius: BorderRadius.circular(50),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Image.asset(
                            AppAsset.backArrowIcon,
                            height: 16,
                            color: AppColors.appColor,
                          ),
                        ),
                      ),

                      // Search field
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.lightPurple1,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.borderColor,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                AppAsset.searchIcon,
                                height: 18,
                                width: 18,
                                color: controller.hasText
                                    ? AppColors.appColor
                                    : AppColors.otpScreenGrey,
                              ),
                              const SizedBox(width: 10),

                              // Divider
                              Container(
                                height: 16,
                                width: 0.8,
                                color: AppColors.grey
                                    .withValues(alpha: 0.35),
                              ),
                              const SizedBox(width: 10),

                              // Text field
                              Expanded(
                                child: TextField(
                                  controller: controller.searchController,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.appColor,
                                  ),
                                  cursorColor: AppColors.primary,
                                  decoration: InputDecoration(
                                    hintText:
                                    EnumLocale.txtSearchPeople.name.tr,
                                    hintStyle: TextStyle(
                                      color: AppColors.otpScreenGrey,
                                      fontSize: 15,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding:
                                    const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                  textInputAction: TextInputAction.done,
                                ),
                              ),

                              // Clear button
                              if (controller.hasText)
                                GestureDetector(
                                  onTap: controller.clearText,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Image.asset(
                                      AppAsset.closeFillIcon,
                                      height: 20,
                                      width: 20,
                                      color: AppColors.profileLanguage
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ).paddingOnly(right: 14),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Subtle divider below search bar
            Divider(
              color: AppColors.historyDivider,
              height: 0,
              thickness: 0.6,
            ),

            // ── Results list ────────────────────────────────────────────
            Expanded(
              child: Container(
                color: AppColors.backGroundColor,
                child: GetBuilder<ChatListSearchController>(
                  builder: (controller) {
                    if (controller.displayedListeners.isEmpty) {
                      return SizedBox(
                        height: Get.height,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                AppAsset.noChatFound,
                                height: 200,
                                color: AppColors.grey.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No results found',
                                style: TextStyle(
                                  color: AppColors.otpScreenGrey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: controller.displayedListeners.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      separatorBuilder: (_, __) => Divider(
                        color: AppColors.historyDivider,
                        height: 0,
                        thickness: 0.6,
                        indent: 76,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) {
                        final user =
                        controller.displayedListeners[index];
                        return SearchChatViewItem(
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.personalChatScreen,
                              arguments: [
                                user.chatUserId,
                                user.name,
                                user.isOnline,
                                user.image,
                                user.ratePrivateAudioCall,
                                user.ratePrivateVideoCall,
                                user.isFake,
                                user.video,
                                user.isAvailableForPrivateVideoCall,
                                user.isAvailableForPrivateAudioCall,
                              ],
                            );
                          },
                          isOnline: user.isOnline ?? false,
                          lastMsgTime: user.messageTime.toString(),
                          lastMsg: user.lastMessage ?? '',
                          index: index,
                          name: user.name ?? '',
                          image: user.image ?? '',
                        ).paddingOnly(left: 14, right: 14, top: 4, bottom: 4);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}