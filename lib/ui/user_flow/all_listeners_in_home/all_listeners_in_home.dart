import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/services/permission_handler/permission_handler.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/ui/user_flow/home_screen/shimmer/top_listener_shimmer.dart';
import 'package:talk_in/ui/user_flow/all_listeners_screen/controller/all_listeners_controller.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/app_color.dart';
import '../../../utils/database.dart';
import '../../../utils/enums.dart' show EnumLocale;
import '../../../utils/font_style.dart';
import '../../../utils/utils.dart';
import '../home_screen/controller/home_screen_controller.dart';

class _C {
  static const card = Color(0xFF1E2235);
  static const title = Color(0xFFFFFFFF);
  static const subtitle = Color(0xFF9CA3AF);
  static const primary = Color(0xFF7C7EFA);
  static const green = Color(0xFF22C55E);
  static const orange = Color(0xFFFF9500);
  static const grey = Color(0xFF6B7280);
  static const starActive = Color(0xFFFACC15);
  static const shadow = Color(0x33000000);
  static const shadowDeep = Color(0x55000000);
}

class ListenersGridEmbedded extends StatelessWidget {
  const ListenersGridEmbedded({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllListenersController>(
      id: Constant.idGetListener,
      init: AllListenersController(),
      builder: (controller) {
        if (controller.isLoading) {
          return TopListenerShimmer()
              .paddingSymmetric(horizontal: 14, vertical: 12);
        }

        // Keep, in this priority order:
        //  1) Online (Available) listeners
        //  2) On Call listeners
        //  3) Offline listeners, but ONLY if they have private audio or
        //     video call enabled — they're still reachable even though
        //     not currently online.
        // Everyone else (offline with no call feature enabled) is dropped.
        final visibleListeners = controller.allListener.where((listener) {
          final bool isAvailable = listener.statusLabel == "Available";
          final bool isOnCall = listener.statusLabel == "On Call";
          final bool hasCallEnabled =
              (listener.isAvailableForPrivateAudioCall ?? false) ||
                  (listener.isAvailableForPrivateVideoCall ?? false);

          return isAvailable || isOnCall || hasCallEnabled;
        }).toList();

        // Sort: Online first, then On Call, then offline-but-call-enabled.
        visibleListeners.sort((a, b) {
          int rank(dynamic listener) {
            if (listener.statusLabel == "Available") return 0;
            if (listener.statusLabel == "On Call") return 1;
            return 2; // offline but audio/video call enabled
          }

          return rank(a).compareTo(rank(b));
        });

        if (controller.allListener.isEmpty || visibleListeners.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AppAsset.noListenerFound)
                    .paddingSymmetric(horizontal: 62),
                const SizedBox(height: 12),
                const Text(
                  'No one is online right now',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _C.subtitle,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Listeners',
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 18,
                        fontColor: AppColors.white,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => Get.toNamed(AppRoutes.allListeners),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4)
                                .copyWith(left: 5),
                            color: AppColors.transparent,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  EnumLocale.txtViewAll.name.tr,
                                  style: AppFontStyle.fontStyleW600(
                                    fontSize: 14,
                                    fontColor: AppColors.primary,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                itemCount: visibleListeners.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final listener = visibleListeners[index];

                  final bool isAvailable = listener.statusLabel == "Available";
                  final bool isOnCall = listener.statusLabel == "On Call";

                  // Each call type has its OWN availability flag — a listener
                  // can have video enabled without audio, or vice versa.
                  // Computed here (once) so both the status pill and the
                  // action buttons below can share it.
                  final bool audioEnabled =
                      listener.isAvailableForPrivateAudioCall ?? false;
                  final bool videoEnabled =
                      listener.isAvailableForPrivateVideoCall ?? false;
                  final bool hasCallEnabled = audioEnabled || videoEnabled;

                  // Treat a listener as "Online" if they're actually available,
                  // OR if they're reachable via an active call button — but
                  // don't override "On Call", which takes priority.
                  final bool showAsOnline =
                      isAvailable || (!isOnCall && hasCallEnabled);

                  final Color statusColor = showAsOnline
                      ? _C.green
                      : isOnCall
                      ? _C.orange
                      : _C.grey;

                  final String statusLabel = showAsOnline
                      ? "Online"
                      : isOnCall
                      ? "On Call"
                      : "Offline";

                  final double rating =
                  listener.callCount != null && listener.callCount! > 0
                      ? (3.5 + (listener.callCount! % 15) / 10.0)
                      .clamp(3.5, 5.0)
                      : 4.0;

                  final bool callerIsUser =
                      Database.fetchLoginUserProfileModel?.user?.isListener ==
                          false;
                  final String callerId = callerIsUser
                      ? Database.fetchLoginUserProfileModel?.user?.id ?? ''
                      : Database.fetchLoginUserProfileModel?.user?.listenerId ??
                      '';
                  final String callerName =
                      Database.fetchLoginUserProfileModel?.user?.fullName ?? '';
                  final String callerImage =
                      Database.fetchLoginUserProfileModel?.user?.profilePic ??
                          '';
                  final String callerRole = callerIsUser ? 'user' : 'listener';
                  final String receiverRole =
                  callerIsUser ? 'listener' : 'user';

                  return GestureDetector(
                    onTap: () => Get.toNamed(
                      AppRoutes.profileDetailScreenView,
                      arguments: listener.id,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _C.card,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: _C.shadow,
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                          BoxShadow(
                            color: _C.shadowDeep,
                            blurRadius: 24,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: listener.image != null &&
                                        listener.image!.isNotEmpty
                                        ? SizedBox(
                                      height: 74,
                                      width: 74,
                                      child: CustomListenerProfileImage(
                                        image: listener.image!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                        : _placeholder(),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          listener.name ?? '',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: _C.title,
                                            letterSpacing: -0.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                              alpha: 0.12),
                                          borderRadius:
                                          BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          statusLabel,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  if (listener.talkTopics != null &&
                                      listener.talkTopics!.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                        _C.primary.withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        listener.talkTopics.toString(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: _C.primary,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 6),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          if (listener.language != null &&
                                              listener
                                                  .language!.isNotEmpty) ...[
                                            const Icon(Icons.language_rounded,
                                                size: 13, color: _C.subtitle),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                listener.language!.join(', '),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: _C.subtitle,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                          ],
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(children: [
                                        Image.asset(AppAsset.starCoin,
                                            width: 15),
                                        Text(
                                          // ratePrivateAudioCall is the per-minute rate; divide by 60 to get
                                          // the per-second coin cost shown here.
                                          "${((num.tryParse(listener.ratePrivateAudioCall?.toString() ?? '') ?? 0) / 60).toStringAsFixed(2)} /Sec",
                                          style: TextStyle(
                                              color: AppColors.white,
                                              fontSize: 10),
                                        ),
                                        const SizedBox(width: 4),
                                        Text('|',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: _C.subtitle)),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.star_rounded,
                                            size: 14, color: _C.starActive),
                                        const SizedBox(width: 2),
                                        Text(
                                          rating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: _C.title,
                                          ),
                                        ),
                                      ]),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Builder(builder: (context) {
                              // audioEnabled / videoEnabled are computed above
                              // (shared with the status pill). Only show the
                              // button for a call type the listener actually
                              // has enabled, so we never emit a call the
                              // server will reject as "Receiver not available".
                              final List<Widget> buttons = [];

                              if (videoEnabled) {
                                buttons.add(
                                  _ActionButton(
                                    icon: Icons.videocam_rounded,
                                    color: _C.green,
                                    onTap: () => _startVideoCall(
                                      listener: listener,
                                      callerId: callerId,
                                      callerName: callerName,
                                      callerImage: callerImage,
                                      callerRole: callerRole,
                                      receiverRole: receiverRole,
                                    ),
                                  ),
                                );
                              }

                              if (audioEnabled) {
                                if (buttons.isNotEmpty) {
                                  buttons.add(const SizedBox(width: 8));
                                }
                                buttons.add(
                                  _ActionButton(
                                    icon: Icons.call_rounded,
                                    color: _C.green,
                                    onTap: () => _startAudioCall(
                                      listener: listener,
                                      callerId: callerId,
                                      callerName: callerName,
                                      callerImage: callerImage,
                                      callerRole: callerRole,
                                      receiverRole: receiverRole,
                                    ),
                                  ),
                                );
                              }

                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: buttons,
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              GetBuilder<AllListenersController>(
                id: Constant.idPaginationListener,
                builder: (controller) => Visibility(
                  visible: controller.isPaginationLoading,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(color: _C.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        );
      },
    );}

  /// -------- Audio call trigger (mirrors TalkNowButtonBottomSheet) --------
  void _startAudioCall({
    required dynamic listener,
    required String callerId,
    required String callerName,
    required String callerImage,
    required String callerRole,
    required String receiverRole,
  }) async {
    final bool isFake = listener.isFake ?? false;

    if (isFake) {
      Get.toNamed(
        AppRoutes.outgoingAudioCallScreen,
        arguments: [
          listener.name ?? '',
          listener.image ?? '',
          listener.video ?? [],
          listener.audio ?? '',
          'audio',
        ],
      );
      return;
    }
    if (Get.isRegistered<HomeScreenController>()) {
      await Get.find<HomeScreenController>().fetchUserCoin();
    }
    // Coin balance check (parity with TalkNowButtonBottomSheet)
    final String audioCallRatePrivate =
        listener.ratePrivateAudioCall?.toString() ?? '0';
    if (callerRole == "user" &&
        (int.tryParse(Database.userCoin.toString()) ?? 0) <
            (int.tryParse(audioCallRatePrivate) ?? 0)) {
      Get.toNamed(AppRoutes.myWalletScreen);
      Utils.showToast(Get.context!, "You have not enough coins.");
      return;
    }

    // ✅ Request mic permission, then EMIT the call to the server via socket.
    // Navigation to outgoingAudioCallScreen happens automatically once the
    // server responds with the `outGoingCall` event (handled in
    // socket_listen.dart -> handleOutGoingCall). We must NOT navigate here
    // ourselves — doing so before emitting means the server (and therefore
    // the receiver) is never notified at all, which is why the call wasn't
    // sending.
    PermissionHandler.onGetMicrophonePermission(
      onGranted: () async {
        saveLastCalledListener(
          id: listener.id ?? '',
          name: listener.name ?? '',
          image: listener.image ?? '',
        );

        // ⚠️ handleOutGoingCall (socket_listen.dart) unconditionally calls
        // Get.back() when the server confirms the call, then pushes the
        // outgoing-call screen. That Get.back() is only safe if there's a
        // temporary route/dialog on top to close. In the bottom-sheet flow
        // that role is played by the bottom sheet itself; here, since this
        // button lives directly on the embedded Home screen with nothing on
        // top, that Get.back() was popping Home itself off the stack —
        // landing back on Splash/Login underneath it. Showing this loading
        // dialog first gives Get.back() something correct to dismiss.
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        SocketEmit.emitCallOutgoingRinging(
          callerId: callerId,
          receiverId: listener.id ?? '',
          callType: "audio",
          callerRole: callerRole,
          receiverRole: receiverRole,
          callerImage: callerImage,
          callerName: callerName,
          receiverImage: listener.image ?? '',
          receiverName: listener.name ?? '',
        );
      },
    );
  }

  /// -------- Video call trigger (mirrors TalkNowButtonBottomSheet) --------
  void _startVideoCall({
    required dynamic listener,
    required String callerId,
    required String callerName,
    required String callerImage,
    required String callerRole,
    required String receiverRole,
  }) async {
    final bool isFake = listener.isFake ?? false;

    if (isFake) {
      PermissionHandler.onGetCameraPermission(
        onGranted: () {
          PermissionHandler.onGetMicrophonePermission(
            onGranted: () {
              Get.toNamed(
                AppRoutes.outgoingAudioCallScreen,
                arguments: [
                  listener.name ?? '',
                  listener.image ?? '',
                  listener.video ?? [],
                  listener.audio ?? '',
                  'video',
                ],
              );
            },
          );
        },
      );
      return;
    }
    if (Get.isRegistered<HomeScreenController>()) {
      await Get.find<HomeScreenController>().fetchUserCoin();
    }
    // Coin balance check (parity with TalkNowButtonBottomSheet)
    final String videoCallRatePrivate =
        listener.ratePrivateVideoCall?.toString() ?? '0';
    if (callerRole == "user" &&
        (int.tryParse(Database.userCoin.toString()) ?? 0) <
            (int.tryParse(videoCallRatePrivate) ?? 0)) {
      Get.toNamed(AppRoutes.myWalletScreen);
      Utils.showToast(Get.context!, "You have not enough coins");
      return;
    }

    // ✅ Request camera + mic permission, then EMIT the call to the server
    // via socket. Navigation happens automatically once the server responds
    // with the `outGoingCall` event (handled in socket_listen.dart ->
    // handleOutGoingCall). We must NOT navigate here ourselves.
    PermissionHandler.onGetCameraPermission(
      onGranted: () {
        PermissionHandler.onGetMicrophonePermission(
          onGranted: () async {
            saveLastCalledListener(
              id: listener.id ?? '',
              name: listener.name ?? '',
              image: listener.image ?? '',
            );

            // See note in _startAudioCall — this dialog gives
            // handleOutGoingCall's Get.back() something safe to dismiss
            // instead of popping the Home screen itself.
            Get.dialog(
              const Center(child: CircularProgressIndicator()),
              barrierDismissible: false,
            );

            SocketEmit.emitCallOutgoingRinging(
              callerId: callerId,
              receiverId: listener.id ?? '',
              callType: "video",
              callerRole: callerRole,
              receiverRole: receiverRole,
              callerImage: callerImage,
              callerName: callerName,
              receiverImage: listener.image ?? '',
              receiverName: listener.name ?? '',
            );
          },
        );
      },
    );
  }

  Widget _placeholder() {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        color: _C.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Icon(Icons.person_rounded, size: 34, color: _C.primary),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Scale relative to screen width, clamped so it never gets
    // too small on tiny phones or too large on tablets.
    final double size = (screenWidth * 0.12).clamp(40.0, 56.0);
    final double iconSize = size * 0.46;
    final double radius = size * 0.25;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Icon(
          icon,
          color: color,
          size: iconSize,
        ),
      ),
    );
  }
}
Future<void> saveLastCalledListener({
  required String id,
  required String name,
  required String image,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('last_listener_id', id);
  await prefs.setString('last_listener_name', name);
  await prefs.setString('last_listener_image', image);
  await prefs.setString('last_listener_time', DateTime.now().toIso8601String());
}