import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/home_screen/shimmer/top_listener_shimmer.dart';
import 'package:talk_in/ui/user_flow/listener_screen/controller/listeners_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';

// ── Light-theme color tokens ──────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFFF4F6FB);
  static const card = Colors.white;
  static const title = Color(0xFF181C2E);
  static const subtitle = Color(0xFF6B7280);
  static const primary = Color(0xFF5B5EF4);
  static const green = Color(0xFF22C55E);
  static const red = Color(0xFFEF4444);
  static const grey = Color(0xFFB0B8C1);
  static const starActive = Color(0xFFFACC15);
  static const starInactive = Color(0xFFE5E7EB);
  static const badgeSuperBg = Color(0xFFFFF7ED);
  static const badgeSuperText = Color(0xFFEA580C);
  static const badgeStarBg = Color(0xFFF0F4FF);
  static const badgeStarText = Color(0xFF5B5EF4);
  static const shadow = Color(0x0F000000);
  static const shadowDeep = Color(0x18000000);
}

class ListenersGridEmbedded extends StatelessWidget {
  const ListenersGridEmbedded({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ListenersScreenController>(
      id: Constant.idAllListener,
      builder: (controller) {
        if (controller.isLoading) {
          return TopListenerShimmer()
              .paddingSymmetric(horizontal: 14, vertical: 12);
        }

        if (controller.allListener.isEmpty) {
          return Center(
            child: Image.asset(AppAsset.noListenerFound)
                .paddingSymmetric(horizontal: 62),
          );
        }

        return Container(
          color: _C.bg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section Header ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'All Listeners',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _C.title,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Choose someone to talk to',
                          style: TextStyle(
                            fontSize: 12,
                            color: _C.subtitle,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        color: _C.primary.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _C.primary.withValues(alpha: 0.16),
                            width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: _C.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${controller.allListener.length} online',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _C.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Listener Cards ────────────────────────────────────────────
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                itemCount: controller.allListener.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final listener = controller.allListener[index];

                  final bool isAvailable =
                      listener.statusLabel == "Available";
                  final bool isOnCall = listener.statusLabel == "On Call";

                  // Offline = neither Available nor On Call
                  final bool isOffline = !isAvailable && !isOnCall;

                  final Color statusColor = isAvailable
                      ? _C.green
                      : isOnCall
                      ? _C.red
                      : _C.grey;

                  final double rating =
                  listener.callCount != null && listener.callCount! > 0
                      ? (3.5 + (listener.callCount! % 15) / 10.0)
                      .clamp(3.5, 5.0)
                      : 4.0;

                  // Caller info helpers
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

                  final String callerRole =
                  callerIsUser ? 'user' : 'listener';

                  final String receiverRole =
                  callerIsUser ? 'listener' : 'user';

                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.profileDetailScreenView,
                        arguments: listener.id,
                      );
                    },
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
                            // ── Avatar + status dot ───────────────────────
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                        _C.primary.withValues(alpha: 0.12),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: listener.image != null &&
                                        listener.image!.isNotEmpty
                                        ? Image.network(
                                      listener.image!,
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _placeholder(),
                                    )
                                        : _placeholder(),
                                  ),
                                ),
                                Positioned(
                                  bottom: 2,
                                  right: 2,
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

                            // ── Info column ───────────────────────────────
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Name + age
                                  Text(
                                    listener.age != null
                                        ? '${listener.name ?? ''}, ${listener.age}'
                                        : listener.name ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: _C.title,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 4),

                                  // Language chip
                                  if (listener.language != null &&
                                      listener.language!.isNotEmpty)
                                    _LanguageChip(
                                      language:
                                      listener.language![0].toString(),
                                    ),

                                  const SizedBox(height: 5),

                                  // Stars
                                  _StarRating(rating: rating),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // ── Action Buttons ────────────────────────────
                            // OFFLINE / ON CALL → chat icon only
                            // AVAILABLE         → chat + video + call
                            if (isOffline || isOnCall)
                            // Only show chat button when offline or on call
                              _TalkStyleButton(
                                icon: Icons.chat_bubble_rounded,
                                gradientColors: const [
                                  Color(0xFF5B8DEF),
                                  Color(0xFF3B5BDB),
                                ],
                                shadowColor: const Color(0xFF5B8DEF),
                                height: 50,
                                width: 44,
                                onTap: () {
                                  Get.toNamed(
                                    AppRoutes.personalChatScreen,
                                    arguments: [
                                      listener.id,
                                      listener.name,
                                      listener.statusLabel,
                                      listener.image,
                                      listener.ratePrivateAudioCall,
                                      listener.ratePrivateVideoCall,
                                      listener.isFake,
                                      listener.video,
                                      listener.isAvailableForPrivateVideoCall,
                                      listener.isAvailableForPrivateAudioCall,
                                    ],
                                  );
                                },
                              )
                            else
                            // AVAILABLE: chat + video + call (no popup)
                              IntrinsicHeight(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [
                                    // Chat + Video stacked
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _TalkStyleButton(
                                          icon: Icons.chat_bubble_rounded,
                                          gradientColors: const [
                                            Color(0xFF5B8DEF),
                                            Color(0xFF3B5BDB),
                                          ],
                                          shadowColor: const Color(0xFF5B8DEF),
                                          height: 40,
                                          width: 44,
                                          onTap: () {
                                            Get.toNamed(
                                              AppRoutes.personalChatScreen,
                                              arguments: [
                                                listener.id,
                                                listener.name,
                                                listener.statusLabel,
                                                listener.image,
                                                listener.ratePrivateAudioCall,
                                                listener.ratePrivateVideoCall,
                                                listener.isFake,
                                                listener.video,
                                                listener
                                                    .isAvailableForPrivateVideoCall,
                                                listener
                                                    .isAvailableForPrivateAudioCall,
                                              ],
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 6),
                                        // ── Video Call button ─────────────
                                        _TalkStyleButton(
                                          icon: Icons.videocam_rounded,
                                          gradientColors: const [
                                            Color(0xFF11998E),
                                            Color(0xFF38EF7D),
                                          ],
                                          shadowColor: const Color(0xFF11998E),
                                          height: 40,
                                          width: 44,
                                          onTap: () {
                                            final isFake =
                                                listener.isFake ?? false;
                                            if (isFake) {
                                              // Fake listener → FakeOutgoingCallController
                                              // args: [name, image, videoList, audio, callType]
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
                                            } else {
                                              // Real listener → OutgoingCallController
                                              Get.toNamed(
                                                AppRoutes.videoCallScreen,
                                                arguments: {
                                                  'callerId': callerId,
                                                  'receiverId': listener.id ?? '',
                                                  'receiverName': listener.name ?? '',
                                                  'receiverImage': listener.image ?? '',
                                                  'callerImage': callerImage,
                                                  'callerfullName': callerName,
                                                  'callerRole': callerRole,
                                                  'receiverRole': receiverRole,
                                                  'callType': 'private',
                                                  'callMode': 'video',
                                                  'callId': '',
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),

                                    const SizedBox(width: 6),

                                    // ── Audio Call button (tall) ───────────
                                    _TalkStyleButton(
                                      icon: Icons.call_rounded,
                                      gradientColors: const [
                                        Color(0xFF22C55E),
                                        Color(0xFF16A34A),
                                      ],
                                      shadowColor: const Color(0xFF22C55E),
                                      height: 86,
                                      width: 44,
                                      onTap: () {
                                        final isFake =
                                            listener.isFake ?? false;
                                        if (isFake) {
                                          // Fake listener → FakeOutgoingCallController
                                          // args: [name, image, videoList, audio, callType]
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
                                        } else {
                                          // Real listener → OutgoingCallController
                                          Get.toNamed(
                                            AppRoutes.outgoingAudioCallScreen,
                                            arguments: {
                                              'callerId': callerId,
                                              'receiverId': listener.id ?? '',
                                              'receiverName': listener.name ?? '',
                                              'receiverImage': listener.image ?? '',
                                              'callerImage': callerImage,
                                              'callerfullName': callerName,
                                              'callerRole': callerRole,
                                              'receiverRole': receiverRole,
                                              'callType': 'private',
                                              'callMode': 'audio',
                                              'callId': '',
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // ── Pagination Loader ─────────────────────────────────────────
              GetBuilder<ListenersScreenController>(
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
    );
  }

  Widget _placeholder() {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        color: _C.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(Icons.person_rounded, size: 34, color: _C.primary),
    );
  }
}

// ── Language chip ─────────────────────────────────────────────────────────────
class _LanguageChip extends StatelessWidget {
  final String language;
  const _LanguageChip({required this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _C.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border:
        Border.all(color: _C.primary.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.language_rounded, size: 11, color: _C.primary),
          const SizedBox(width: 4),
          Text(
            language,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _C.primary,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Star rating ───────────────────────────────────────────────────────────────
class _StarRating extends StatelessWidget {
  final double rating;
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          final full = i < rating.floor();
          final half = !full && (rating - i) >= 0.5;
          return Padding(
            padding: const EdgeInsets.only(right: 1),
            child: Icon(
              full
                  ? Icons.star_rounded
                  : half
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
              size: 13,
              color: (full || half) ? _C.starActive : _C.starInactive,
            ),
          );
        }),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _C.subtitle,
          ),
        ),
      ],
    );
  }
}

// ── Gradient icon-only button ─────────────────────────────────────────────────
class _TalkStyleButton extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final Color shadowColor;
  final double height;
  final double width;
  final VoidCallback onTap;

  const _TalkStyleButton({
    required this.icon,
    required this.gradientColors,
    required this.shadowColor,
    required this.height,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.30),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 19),
      ),
    );
  }
}