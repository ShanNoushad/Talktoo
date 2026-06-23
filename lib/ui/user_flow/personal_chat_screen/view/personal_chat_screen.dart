import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/custom_audio_time/custom_format_audio_time.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/controller/personal_chat_screen_controller.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/shimmer/personal_chat_screen_shimmer.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/widget/personal_chat_screen_widget.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class PersonalChatScreen extends StatelessWidget {
  const PersonalChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          GetBuilder<PersonalChatScreenController>(
            id: Constant.idGetOldChat,
            builder: (controller) {
              return Column(
                children: [
                  // App bar sits on the main dark background
                  ChatScreenAppBar(),

                  // Pagination loading bar
                  GetBuilder<PersonalChatScreenController>(
                    id: Constant.idPagination,
                    builder: (controller) => Visibility(
                      visible: controller.isPaginationLoading,
                      child: LinearProgressIndicator(
                        color: AppColors.primary,
                        backgroundColor:
                        AppColors.lightPurple.withValues(alpha: 0.4),
                      ),
                    ),
                  ),

                  // ── Chat message list ───────────────────────────────
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(AppAsset.chatBackGround),
                          fit: BoxFit.cover,
                          // Darken the wallpaper so bubbles stand out
                          colorFilter: ColorFilter.mode(
                            AppColors.backGroundColor.withValues(alpha: 0.55),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      child: SizedBox(
                        height: Get.height - 100,
                        child: controller.isLoading
                            ? PersonalChatScreenShimmer()
                            : SingleChildScrollView(
                          controller: controller.scrollController,
                          child: ListView.builder(
                            reverse: true,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 8),
                            itemCount: controller.oldChat.length,
                            itemBuilder: (context, index) {
                              final isLastMessage = index == 0;
                              final msg = controller.oldChat[index];
                              final isSender =
                                  msg.senderId == Database.loginUserId;

                              Widget messageWidget =
                              _buildMessageWidget(
                                msg: msg,
                                controller: controller,
                                isSender: isSender,
                                isLastMessage: isLastMessage,
                              );

                              return Align(
                                alignment: isSender
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: messageWidget,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom input bar — sits on the dark background
                  Container(
                    color: AppColors.backGroundColor,
                    child: PersonalChatBottomView(),
                  ),
                ],
              );
            },
          ),

          // ── Audio recording indicator ─────────────────────────────
          Positioned(
            bottom: 80,
            child: GetBuilder<PersonalChatScreenController>(
              id: Constant.idChangeAudioRecordingEvent,
              builder: (controller) => Visibility(
                visible: controller.isRecordingAudio,
                child: Container(
                  height: 40,
                  width: 120,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.purple100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.purpleBorder,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppAsset.microPhoneIcon,
                        color: AppColors.primary,
                        width: 18,
                      ),
                      5.width,
                      Text(
                        CustomFormatAudioTime.convert(controller.countTime),
                        style: AppFontStyle.fontStyleW500(
                          fontColor: AppColors.appColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageWidget({
    required dynamic msg,
    required PersonalChatScreenController controller,
    required bool isSender,
    required bool isLastMessage,
  }) {
    switch (msg.messageType) {
      case 1:
        return ChatTextWidget(
          msg: msg,
          controller: controller,
          isRead: msg.isRead ?? false,
        );
      case 2:
        return ChatImageWidget(
          msg: msg,
          controller: controller,
          isRead: msg.isRead ?? false,
        );
      case 3:
        return isSender
            ? SenderAudioMessageWidget(
          audioUrl: msg.audio ?? "",
          time: msg.date ?? "",
          id: msg.id ?? "",
          chat: msg,
          isLastMessage: isLastMessage,
        )
            : ReceiverAudioMessageWidget(
          audioUrl: msg.audio ?? "",
          time: msg.date ?? "",
          id: msg.id ?? "",
          chat: msg,
        );
      case 4:
        return ChatAudioCallWidget(
          msg: msg,
          controller: controller,
          audioCallDuration: msg.callDuration ?? "00:00:00",
        );
      case 5:
        return ChatVideoCallWidget(
          msg: msg,
          controller: controller,
          callDuration: msg.callDuration ?? "00:00:00",
        );
      default:
        return const SizedBox.shrink();
    }
  }
}