import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/home_screen/shimmer/top_listener_shimmer.dart';
import 'package:talk_in/ui/user_flow/listener_screen/controller/listeners_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/app_color.dart';
import '../../../utils/database.dart';

// class _C {
//   static const bg = Color(0xFFF4F6FB);
//   static const card = Colors.white;
//   static const title = Color(0xFF181C2E);
//   static const subtitle = Color(0xFF6B7280);
//   static const primary = Color(0xFF5B5EF4);
//   static const green = Color(0xFF22C55E);
//   static const orange = Color(0xFFFF9500);
//   static const red = Color(0xFFEF4444);
//   static const grey = Color(0xFFB0B8C1);
//   static const starActive = Color(0xFFFACC15);
//   static const starInactive = Color(0xFFE5E7EB);
//   static const shadow = Color(0x0F000000);
//   static const shadowDeep = Color(0x18000000);
// }

class _C {
  static const bg = Color(0xFF0F111A); // Deep dark background
  static const card = Color(0xFF1E2235); // Dark surface card color
  static const title = Color(0xFFFFFFFF); // White for high contrast readability
  static const subtitle = Color(0xFF9CA3AF); // Muted gray for secondary details
  static const primary = Color(
      0xFF7C7EFA); // Slightly lighter primary blue for dark mode brilliance
  static const green = Color(0xFF22C55E);
  static const orange = Color(0xFFFF9500);
  static const red = Color(0xFFEF4444);
  static const grey = Color(0xFF6B7280);
  static const starActive = Color(0xFFFACC15);
  static const shadow =
      Color(0x33000000); // Darker shadow footprint for dark UI
  static const shadowDeep = Color(0x55000000);
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
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section Header ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'All Listeners',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Filter',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _C.primary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.tune_rounded, size: 18, color: _C.primary),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Listener Cards ────────────────────────────────────────
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                itemCount: controller.allListener.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final listener = controller.allListener[index];

                  final bool isAvailable = listener.statusLabel == "Available";
                  final bool isOnCall = listener.statusLabel == "On Call";

                  // Status color — green / orange / grey
                  final Color statusColor = isAvailable
                      ? _C.green
                      : isOnCall
                          ? _C.orange
                          : _C.grey;

                  final String statusLabel = isAvailable
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
                            // ── Avatar ──────────────────────────────
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
                                        ? Image.network(
                                            listener.image!,
                                            height: 74,
                                            width: 74,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _placeholder(),
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

                                  // Language + Stars + call count
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          if (listener.language != null &&
                                              listener.language!.isNotEmpty) ...[
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
                                      Row(
                                        children: [
                                        ],
                                      ),
                                      SizedBox(height: 4,),
                                      Row(children: [
                                        Image.asset(AppAsset.starCoin,width: 15,),Text("/Sec",style: TextStyle(color: AppColors.white,fontSize: 10),),
                                        const SizedBox(width: 4),
                                        Text(
                                          '|',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: _C.subtitle,
                                          ),
                                        ),
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



                                      ],)
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // ── Action buttons ───────────────────────
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _ActionButton(
                                  icon: Icons.videocam_rounded,
                                  color: _C.green,
                                  onTap: () {
                                    final isFake = listener.isFake ?? false;
                                    if (isFake) {
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
                                      saveLastCalledListener(
                                        id: listener.id ?? '',
                                        name: listener.name ?? '',
                                        image: listener.image ?? '',
                                      );
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
                                          'callMode': 'video',
                                          'callId': '',
                                        },
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                _ActionButton(
                                  icon: Icons.call_rounded,
                                  color: _C.green,
                                  onTap: () {
                                    final isFake = listener.isFake ?? false;
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
                                    } else {
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
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // ── Pagination loader ─────────────────────────────────────
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: color,
          size: 22,
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