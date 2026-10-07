import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/last_called_listener.dart';

import '../../../services/permission_handler/permission_handler.dart';
import '../../../socket/socket_emit.dart';

class _C {
  static const bg = Color(0xFF1E2235);
  static const card = Color(0xFF181D24);
  static const title = Color(0xFFFFFFFF);
  static const subtitle = Color(0xFF9CA3AF);
  static const green = Color(0xFF22C55E);
}

class ContinueConversationCard extends StatefulWidget {
  const ContinueConversationCard({super.key});

  @override
  State<ContinueConversationCard> createState() => _ContinueConversationCardState();
}

class _ContinueConversationCardState extends State<ContinueConversationCard> {
  LastCalledListener? _lastListener;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await getLastCalledListener();
    if (mounted) {
      setState(() {
        _lastListener = data;
        _loading = false;
      });
    }
  }

  void _callAgain() {
    final listener = _lastListener;
    if (listener == null) return;

    final bool callerIsUser =
        Database.fetchLoginUserProfileModel?.user?.isListener == false;
    final String callerId = callerIsUser
        ? Database.fetchLoginUserProfileModel?.user?.id ?? ''
        : Database.fetchLoginUserProfileModel?.user?.listenerId ?? '';
    final String callerName =
        Database.fetchLoginUserProfileModel?.user?.fullName ?? '';
    final String callerImage =
        Database.fetchLoginUserProfileModel?.user?.profilePic ?? '';
    final String callerRole = callerIsUser ? 'user' : 'listener';
    final String receiverRole = callerIsUser ? 'listener' : 'user';

    // ✅ Request mic permission, then EMIT the call to the server via socket —
    // mirrors ListenersGridEmbedded._startAudioCall. Navigation to the
    // outgoing-call screen happens automatically once the server responds
    // with the `outGoingCall` event (socket_listen.dart -> handleOutGoingCall).
    // We must NOT navigate here ourselves, or the receiver is never notified.
    PermissionHandler.onGetMicrophonePermission(
      onGranted: () async {
        await saveLastCalledListener(
          id: listener.id,
          name: listener.name,
          image: listener.image,
        );

        // Gives handleOutGoingCall's Get.back() something safe to dismiss.
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        SocketEmit.emitCallOutgoingRinging(
          callerId: callerId,
          receiverId: listener.id,
          callType: "audio",
          callerRole: callerRole,
          receiverRole: receiverRole,
          callerImage: callerImage,
          callerName: callerName,
          receiverImage: listener.image,
          receiverName: listener.name,
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    if (_loading || _lastListener == null) {
      return const SizedBox.shrink();
    }

    final listener = _lastListener!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _C.bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // ── Listener avatar ──────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: 36,
              height: 36,
              child: listener.image.isNotEmpty
                  ? CustomListenerProfileImage(
                image: listener.image,
                fit: BoxFit.cover,
              )
                  : Container(
                color: Colors.white,
                child: const Icon(
                  Icons.history_rounded,
                  color: _C.green,
                  size: 20,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ── Text column ───────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Continue your last conversation',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.title,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'You talked with ${listener.name} ${listener.timeLabel}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: _C.subtitle,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Repeat call button ────────────────────────
          GestureDetector(
            onTap: _callAgain,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: _C.green,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: _C.green.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.call_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Repeat Call',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}