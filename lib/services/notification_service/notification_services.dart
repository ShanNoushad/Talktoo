// import 'dart:math';
//
// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:mobile_device_identifier/mobile_device_identifier.dart';
// import 'package:talk_in/custom/dialog/app_restart_dialog.dart';
// import 'package:talk_in/main.dart';
// import 'package:talk_in/routes/app_routes.dart';
// import 'package:talk_in/services/permission_handler/permission_handler.dart';
// import 'package:talk_in/socket/socket_emit.dart';
// import 'package:talk_in/utils/app_color.dart';
// import 'package:talk_in/utils/database.dart';
// import 'package:talk_in/utils/utils.dart';
// import '../../socket/socket_service.dart';
//
// class NotificationServices {
//   static FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//   static Future<void> init() async {
//     Utils.showLog("🔧 [NS:init] Starting NotificationServices.init()");
//
//     Utils.showLog("🔧 [NS:init] Removing old channels...");
//     await AwesomeNotifications().removeChannel('call_channel');
//     await AwesomeNotifications().removeChannel('call_channel_v2');
//     await AwesomeNotifications().removeChannel('chat_channel');
//     Utils.showLog("✅ [NS:init] Old channels removed");
//
//     await AwesomeNotifications().initialize(
//       null,
//       [
//         NotificationChannel(
//           channelKey: 'call_channel_v2',
//           channelName: 'Call Channel v2',
//           channelDescription: 'Channel for incoming call notifications',
//           defaultColor: Colors.green,
//           importance: NotificationImportance.Max,
//           locked: true,
//           channelShowBadge: true,
//           playSound: true,
//           soundSource: 'resource://raw/ringtone',
//           enableVibration: true,
//         ),
//         NotificationChannel(
//           channelKey: 'chat_channel',
//           channelName: 'Chat Channel',
//           channelDescription: 'Channel for chat notifications',
//           defaultColor: Colors.blue,
//           importance: NotificationImportance.High,
//           channelShowBadge: true,
//           playSound: true,
//           enableVibration: true,
//         ),
//       ],
//       debug: true,
//     );
//     Utils.showLog("✅ [NS:init] AwesomeNotifications initialized");
//
//     bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
//     Utils.showLog("🔧 [NS:init] Notification permission allowed: $isAllowed");
//     if (!isAllowed) {
//       Utils.showLog("⚠️ [NS:init] Requesting notification permission...");
//       await AwesomeNotifications().requestPermissionToSendNotifications();
//     }
//
//     AwesomeNotifications().setListeners(
//       onActionReceivedMethod: onAwesomeNotificationActionReceived,
//     );
//     Utils.showLog("✅ [NS:init] Listeners set");
//
//     await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//       criticalAlert: true,
//     );
//     Utils.showLog("✅ [NS:init] FCM permission requested");
//
//     // 🔍 Log current FCM token
//     final token = await messaging.getToken();
//     Utils.showLog("📱 [NS:init] Current FCM token: $token");
//     Utils.showLog("📱 [NS:init] Stored FCM token: ${Database.fcmToken}");
//     Utils.showLog("📱 [NS:init] Tokens match: ${token == Database.fcmToken}");
//
//     Utils.showLog("✅ [NS:init] NotificationServices.init() complete");
//   }
//
//   static Future<void> onAwesomeNotificationActionReceived(
//       ReceivedAction receivedAction) async {
//     Utils.showLog("📦 [NS:action] ===== Notification action received =====");
//     Utils.showLog("📦 [NS:action] Payload: ${receivedAction.payload}");
//     Utils.showLog("📦 [NS:action] Button pressed: ${receivedAction.buttonKeyPressed}");
//     Utils.showLog("📦 [NS:action] Notification ID: ${receivedAction.id}");
//     Utils.showLog("📦 [NS:action] Channel: ${receivedAction.channelKey}");
//
//     if (receivedAction.payload != null && receivedAction.payload!.isNotEmpty) {
//       final data = receivedAction.payload!;
//       Utils.showLog("📦 [NS:action] Data type: ${data['type']}");
//       Utils.showLog("📦 [NS:action] CallerId: ${data['callerId']}");
//       Utils.showLog("📦 [NS:action] ReceiverId: ${data['receiverId']}");
//       Utils.showLog("📦 [NS:action] CallId: ${data['callId']}");
//
//       if (receivedAction.buttonKeyPressed == 'ACCEPT' ||
//           receivedAction.buttonKeyPressed == 'DECLINE') {
//         Utils.showLog("🔘 [NS:action] Call button pressed: ${receivedAction.buttonKeyPressed}");
//
//         await AwesomeNotifications().dismiss(receivedAction.id!);
//         Utils.showLog("✅ [NS:action] Notification dismissed");
//
//         // ✅ Reconnect socket if not connected
//         Utils.showLog("🔌 [NS:action] Socket connected: ${SocketEmit.isConnected()}");
//         if (!SocketEmit.isConnected()) {
//           Utils.showLog("🔌 [NS:action] Socket not connected, reconnecting...");
//           final identity = (await MobileDeviceIdentifier().getDeviceId())!;
//           final fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
//           Utils.showLog("📱 [NS:action] Fresh FCM token for reconnect: $fcmToken");
//           await Database.init(identity, fcmToken);
//           await Future.delayed(const Duration(milliseconds: 500));
//           await SocketService.socketConnect();
//           Utils.showLog("🔌 [NS:action] Socket connect called, waiting...");
//
//           int retries = 0;
//           while (!SocketEmit.isConnected() && retries < 10) {
//             await Future.delayed(const Duration(milliseconds: 500));
//             retries++;
//             Utils.showLog("⏳ [NS:action] Waiting for socket... attempt $retries/10");
//           }
//
//           if (!SocketEmit.isConnected()) {
//             Utils.showLog("❌ [NS:action] Socket FAILED to connect after 10 retries");
//             return;
//           }
//           Utils.showLog("✅ [NS:action] Socket connected after $retries retries");
//         }
//
//         final isAccept = receivedAction.buttonKeyPressed == 'ACCEPT';
//         Utils.showLog("📞 [NS:action] Emitting call response: isAccept=$isAccept");
//
//         if (!SocketEmit.isConnected()) {
//           Utils.showLog("❌ [NS:action] Socket still not connected, cannot emit");
//           return;
//         }
//
//         if (isAccept) {
//           Utils.showLog("✅ [NS:action] Requesting camera & mic permission before accept...");
//           PermissionHandler.onGetCameraPermission(
//             onGranted: () {
//               Utils.showLog("✅ [NS:action] Camera granted, requesting mic...");
//               PermissionHandler.onGetMicrophonePermission(
//                 onGranted: () {
//                   Utils.showLog("✅ [NS:action] Mic granted, emitting ACCEPT...");
//                   SocketEmit.emitCallResponseProcessed(
//                     callerId: data['callerId']!,
//                     receiverId: data['receiverId']!,
//                     callId: data['callId']!,
//                     isAccept: true,
//                     callType: data['callType'] ?? 'audio',
//                     callMode: data['callMode'] ?? 'private',
//                     callerRole: data['callerRole'] ?? '',
//                     receiverRole: data['receiverRole'] ?? '',
//                     receiverName: data['receiverName'] ?? '',
//                     receiverImage: data['receiverImage'] ?? '',
//                     callerName: data['callerfullName'] ?? '',
//                     callerImage: data['callerImage'] ?? '',
//                   );
//                   Utils.showLog("✅ [NS:action] ACCEPT emitted to socket");
//                 },
//               );
//             },
//           );
//         } else {
//           Utils.showLog("❌ [NS:action] Emitting DECLINE to socket...");
//           SocketEmit.emitCallResponseProcessed(
//             callerId: data['callerId']!,
//             receiverId: data['receiverId']!,
//             callId: data['callId']!,
//             isAccept: false,
//             callType: data['callType'] ?? 'audio',
//             callMode: data['callMode'] ?? 'private',
//             callerRole: data['callerRole'] ?? '',
//             receiverRole: data['receiverRole'] ?? '',
//             receiverName: data['receiverName'] ?? '',
//             receiverImage: data['receiverImage'] ?? '',
//             callerName: data['callerfullName'] ?? '',
//             callerImage: data['callerImage'] ?? '',
//           );
//           Utils.showLog("✅ [NS:action] DECLINE emitted to socket");
//         }
//       } else {
//         Utils.showLog("🔔 [NS:action] Notification tapped (no button), navigating...");
//         onHandleNotificationNavigation(data);
//       }
//     } else {
//       Utils.showLog("⚠️ [NS:action] Payload is null or empty — cannot process");
//     }
//   }
//
//   static void onHandleNotificationNavigation(Map<String, dynamic> data) {
//     Utils.showLog("🧭 [NS:nav] Handling navigation for type: ${data['type']}");
//
//     if (data["type"] == "CHAT") {
//       Utils.showLog("💬 [NS:nav] Navigating to chat screen");
//       Utils.showLog("💬 [NS:nav] isListener: ${Database.fetchLoginUserProfileModel?.user?.isListener}");
//
//       if (Database.fetchLoginUserProfileModel?.user?.isListener == false) {
//         Utils.showLog("💬 [NS:nav] → User chat screen");
//         Get.toNamed(
//           AppRoutes.personalChatScreen,
//           arguments: [
//             data['senderId'],
//             data['senderName'],
//             data['isOnline'],
//             data['senderProfilePic'],
//             data['ratePrivateAudioCall'],
//             data['ratePrivateVideoCall'],
//             data['isFake'] ?? false,
//             data['video'],
//             data['isAvailableForPrivateVideoCall'],
//             data['isAvailableForPrivateAudioCall'],
//           ],
//         );
//       } else if (data["type"] == "missed_call") {
//         Utils.showLog("📞 [NS:nav] Navigating to missed call profile: ${data['callerId']}");
//         Get.toNamed(AppRoutes.profileDetailScreenView, arguments: data['callerId']);
//       } else if (data["type"] == "callIncoming") {
//         Utils.showLog("📞 [NS:nav] Navigating to incoming call screen");
//         Get.toNamed(AppRoutes.incomingCallScreen, arguments: data);
//       } else {
//         Utils.showLog("⚠️ [NS:nav] Unknown notification type: ${data['type']}");
//       }
//     } else if (data["type"] == "missed_call") {
//       Utils.showLog("📞 [NS:nav] Navigating to missed call profile: ${data['callerId']}");
//       Get.toNamed(AppRoutes.profileDetailScreenView, arguments: data['callerId']);
//     } else {
//       Utils.showLog("⚠️ [NS:nav] Unknown notification type: ${data['type']}");
//     }
//   }
//
//   static Future<void> showAwesomeNotification(RemoteMessage message) async {
//     Utils.showLog("🔔 [NS:show] ===== showAwesomeNotification called =====");
//     Utils.showLog("🔔 [NS:show] Full data: ${message.data}");
//     Utils.showLog("🔔 [NS:show] Type: ${message.data['type']}");
//     Utils.showLog("🔔 [NS:show] Title: ${message.data['title']}");
//     Utils.showLog("🔔 [NS:show] Body: ${message.data['body']}");
//     Utils.showLog("🔔 [NS:show] Has notification block: ${message.notification != null}");
//
//     String type = message.data['type'] ?? '';
//     String channelKey = 'chat_channel';
//     NotificationCategory category = NotificationCategory.Message;
//     List<NotificationActionButton> actions = [];
//
//     if (type == 'callIncoming') {
//       Utils.showLog("📞 [NS:show] Type is callIncoming → using call_channel_v2");
//       channelKey = 'call_channel_v2';
//       category = NotificationCategory.Call;
//       actions = [
//         NotificationActionButton(
//             key: 'ACCEPT', label: 'Accept', color: Colors.green),
//         NotificationActionButton(
//             key: 'DECLINE', label: 'Decline', color: Colors.red),
//       ];
//     } else {
//       Utils.showLog("💬 [NS:show] Type is '$type' → using chat_channel");
//     }
//
//     int getUniqueNotificationId() {
//       var randomNumber = Random();
//       var resultOne = randomNumber.nextInt(2000);
//       var resultTwo = randomNumber.nextInt(100);
//       if (resultTwo >= resultOne) resultTwo += 1;
//       return resultTwo;
//     }
//
//     final notifId = getUniqueNotificationId();
//     Utils.showLog("🔔 [NS:show] Creating notification — ID: $notifId, Channel: $channelKey");
//
//     try {
//       await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//           id: notifId,
//           channelKey: channelKey,
//           title: message.data['title'] ?? 'Notification',
//           body: message.data['body'] ?? 'You have a new message',
//           category: category,
//           icon: 'resource://drawable/ic_notification',
//           payload: message.data
//               .map((k, v) => MapEntry(k.toString(), v.toString())),
//           notificationLayout: NotificationLayout.Default,
//           displayOnForeground: true,
//           displayOnBackground: true,
//           wakeUpScreen: (channelKey == 'call_channel_v2'),
//           fullScreenIntent: (channelKey == 'call_channel_v2'),
//           criticalAlert: (channelKey == 'call_channel_v2'),
//           autoDismissible: (channelKey != 'call_channel_v2'),
//           timeoutAfter: (channelKey == 'call_channel_v2')
//               ? const Duration(seconds: 30)
//               : null,
//         ),
//         actionButtons: actions,
//       );
//       Utils.showLog("✅ [NS:show] createNotification SUCCESS — ID: $notifId");
//     } catch (e, stack) {
//       Utils.showLog("❌ [NS:show] createNotification FAILED: $e");
//       Utils.showLog("❌ [NS:show] StackTrace: $stack");
//     }
//
//     Utils.showLog("🔔 [NS:show] ===== showAwesomeNotification done =====");
//   }
//
//   static Future<void> firebaseInit() async {
//     Utils.showLog("🔥 [NS:fbInit] ===== firebaseInit called =====");
//
//     FirebaseMessaging.onMessage.listen((message) {
//       Utils.showLog("🔥 [NS:fbInit] onMessage received");
//       Utils.showLog("🔥 [NS:fbInit] Data: ${message.data}");
//       Utils.showLog("🔥 [NS:fbInit] Type: ${message.data['type']}");
//
//       if ((Get.currentRoute == AppRoutes.personalChatScreen ||
//           Get.currentRoute == AppRoutes.hostPersonalChatScreen) &&
//           message.data["type"] == "CHAT") {
//         Utils.showLog("💬 [NS:fbInit] Already on chat screen — suppressing notification");
//       } else if (message.data['type'] == 'listener_verified') {
//         Utils.showLog("✅ [NS:fbInit] listener_verified — showing restart dialog");
//         Get.dialog(
//           barrierDismissible: false,
//           barrierColor: AppColors.black.withValues(alpha: 0.8),
//           Dialog(
//             backgroundColor: AppColors.transparent,
//             shadowColor: Colors.transparent,
//             surfaceTintColor: Colors.transparent,
//             elevation: 0,
//             child: const AppRestartDialog(),
//           ),
//         );
//       } else if (message.data['type'] == 'callIncoming') {
//         // ✅ Foreground incoming call: skip the system notification entirely.
//         // The in-app IncomingCallController already handles ringtone,
//         // vibration, and Accept/Decline UI — showing the OS notification
//         // too creates two independent ringtones playing at once, and the
//         // system one has no lifecycle tie to the in-app screen so it
//         // keeps ringing even after the screen is up.
//         Utils.showLog("📞 [NS:fbInit] Foreground callIncoming — navigating without system notification");
//         Get.toNamed(AppRoutes.incomingCallScreen, arguments: message.data);
//       } else {
//         Utils.showLog("🔥 [NS:fbInit] Calling showAwesomeNotification");
//         showAwesomeNotification(message);
//       }
//     });
//
//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       Utils.showLog("🔥 [NS:fbInit] onMessageOpenedApp — app opened from notification");
//       Utils.showLog("🔥 [NS:fbInit] Data: ${message.data}");
//       onHandleNotificationNavigation(message.data);
//     });
//
//     Utils.showLog("✅ [NS:fbInit] firebaseInit listeners registered");
//   }  static Future<void> dismissCallNotification() async {
//     Utils.showLog("🔔 [NS:dismiss] Dismissing call_channel_v2 notifications...");
//     try {
//       await AwesomeNotifications()
//           .cancelNotificationsByChannelKey('call_channel_v2');
//       Utils.showLog("✅ [NS:dismiss] Call notifications dismissed successfully");
//     } catch (e) {
//       Utils.showLog("❌ [NS:dismiss] Error dismissing call notifications: $e");
//     }
//   }
// }
//
// // ─── Background FCM handler ───────────────────────────────────────────────────
// @pragma('vm:entry-point')
// Future<void> backgroundNotification(RemoteMessage message) async {
//   print("🔔 [BG] ===== Background message received =====");
//   print("🔔 [BG] Message ID: ${message.messageId}");
//   print("🔔 [BG] Data: ${message.data}");
//   print("🔔 [BG] Notification title: ${message.notification?.title}");
//   print("🔔 [BG] Notification body: ${message.notification?.body}");
//   print("🔔 [BG] Has notification block: ${message.notification != null}");
//   print("🔔 [BG] Has data block: ${message.data.isNotEmpty}");
//
//   await Firebase.initializeApp();
//   print("✅ [BG] Firebase initialized");
//
//   await AwesomeNotifications().initialize(
//     null,
//     [
//       NotificationChannel(
//         channelKey: 'call_channel_v2',
//         channelName: 'Call Channel v2',
//         channelDescription: 'Channel for incoming call notifications',
//         defaultColor: Colors.green,
//         importance: NotificationImportance.Max,
//         locked: true,
//         playSound: true,
//         soundSource: 'resource://raw/ringtone',
//         enableVibration: true,
//       ),
//       NotificationChannel(
//         channelKey: 'chat_channel',
//         channelName: 'Chat Channel',
//         channelDescription: 'Channel for chat notifications',
//         defaultColor: Colors.blue,
//         importance: NotificationImportance.High,
//         playSound: true,
//         enableVibration: true,
//       ),
//     ],
//     debug: true,
//   );
//   print("✅ [BG] AwesomeNotifications initialized");
//
//   try {
//     print("🔔 [BG] Calling showAwesomeNotification...");
//     await NotificationServices.showAwesomeNotification(message);
//     print("✅ [BG] showAwesomeNotification completed successfully");
//   } catch (e, stack) {
//     print("❌ [BG] showAwesomeNotification FAILED: $e");
//     print("❌ [BG] StackTrace: $stack");
//   }
//
//   print("🔔 [BG] ===== Background handler done =====");
// }


import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:talk_in/custom/dialog/app_restart_dialog.dart';
import 'package:talk_in/main.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/services/permission_handler/permission_handler.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';
import '../../socket/socket_service.dart';

class NotificationServices {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    Utils.showLog("🔧 [NS:init] Starting NotificationServices.init()");

    Utils.showLog("🔧 [NS:init] Removing old channels...");
    await AwesomeNotifications().removeChannel('call_channel');
    await AwesomeNotifications().removeChannel('call_channel_v2');
    await AwesomeNotifications().removeChannel('chat_channel');
    Utils.showLog("✅ [NS:init] Old channels removed");

    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'call_channel_v2',
          channelName: 'Call Channel v2',
          channelDescription: 'Channel for incoming call notifications',
          defaultColor: Colors.green,
          importance: NotificationImportance.Max,
          locked: true,
          channelShowBadge: true,
          playSound: true,
          soundSource: 'resource://raw/ringtone',
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'chat_channel',
          channelName: 'Chat Channel',
          channelDescription: 'Channel for chat notifications',
          defaultColor: Colors.blue,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
      ],
      debug: true,
    );
    Utils.showLog("✅ [NS:init] AwesomeNotifications initialized");

    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    Utils.showLog("🔧 [NS:init] Notification permission allowed: $isAllowed");
    if (!isAllowed) {
      Utils.showLog("⚠️ [NS:init] Requesting notification permission...");
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onAwesomeNotificationActionReceived,
    );
    Utils.showLog("✅ [NS:init] Listeners set");

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );
    Utils.showLog("✅ [NS:init] FCM permission requested");

    // 🔍 Log current FCM token
    final token = await messaging.getToken();
    Utils.showLog("📱 [NS:init] Current FCM token: $token");
    Utils.showLog("📱 [NS:init] Stored FCM token: ${Database.fcmToken}");
    Utils.showLog("📱 [NS:init] Tokens match: ${token == Database.fcmToken}");

    Utils.showLog("✅ [NS:init] NotificationServices.init() complete");
  }

  static Future<void> onAwesomeNotificationActionReceived(
      ReceivedAction receivedAction) async {
    Utils.showLog("📦 [NS:action] ===== Notification action received =====");
    Utils.showLog("📦 [NS:action] Payload: ${receivedAction.payload}");
    Utils.showLog("📦 [NS:action] Button pressed: ${receivedAction.buttonKeyPressed}");
    Utils.showLog("📦 [NS:action] Notification ID: ${receivedAction.id}");
    Utils.showLog("📦 [NS:action] Channel: ${receivedAction.channelKey}");

    if (receivedAction.payload != null && receivedAction.payload!.isNotEmpty) {
      final data = receivedAction.payload!;
      Utils.showLog("📦 [NS:action] Data type: ${data['type']}");
      Utils.showLog("📦 [NS:action] CallerId: ${data['callerId']}");
      Utils.showLog("📦 [NS:action] ReceiverId: ${data['receiverId']}");
      Utils.showLog("📦 [NS:action] CallId: ${data['callId']}");

      if (receivedAction.buttonKeyPressed == 'ACCEPT' ||
          receivedAction.buttonKeyPressed == 'DECLINE') {
        Utils.showLog("🔘 [NS:action] Call button pressed: ${receivedAction.buttonKeyPressed}");

        await AwesomeNotifications().dismiss(receivedAction.id!);
        Utils.showLog("✅ [NS:action] Notification dismissed");

        // ✅ Reconnect socket if not connected
        Utils.showLog("🔌 [NS:action] Socket connected: ${SocketEmit.isConnected()}");
        if (!SocketEmit.isConnected()) {
          Utils.showLog("🔌 [NS:action] Socket not connected, reconnecting...");
          final identity = (await MobileDeviceIdentifier().getDeviceId())!;
          final fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
          Utils.showLog("📱 [NS:action] Fresh FCM token for reconnect: $fcmToken");
          await Database.init(identity, fcmToken);
          await Future.delayed(const Duration(milliseconds: 500));
          await SocketService.socketConnect();
          Utils.showLog("🔌 [NS:action] Socket connect called, waiting...");

          int retries = 0;
          while (!SocketEmit.isConnected() && retries < 10) {
            await Future.delayed(const Duration(milliseconds: 500));
            retries++;
            Utils.showLog("⏳ [NS:action] Waiting for socket... attempt $retries/10");
          }

          if (!SocketEmit.isConnected()) {
            Utils.showLog("❌ [NS:action] Socket FAILED to connect after 10 retries");
            return;
          }
          Utils.showLog("✅ [NS:action] Socket connected after $retries retries");
        }

        final isAccept = receivedAction.buttonKeyPressed == 'ACCEPT';
        Utils.showLog("📞 [NS:action] Emitting call response: isAccept=$isAccept");

        if (!SocketEmit.isConnected()) {
          Utils.showLog("❌ [NS:action] Socket still not connected, cannot emit");
          return;
        }

        if (isAccept) {
          Utils.showLog("✅ [NS:action] Requesting camera & mic permission before accept...");
          PermissionHandler.onGetCameraPermission(
            onGranted: () {
              Utils.showLog("✅ [NS:action] Camera granted, requesting mic...");
              PermissionHandler.onGetMicrophonePermission(
                onGranted: () {
                  Utils.showLog("✅ [NS:action] Mic granted, emitting ACCEPT...");
                  SocketEmit.emitCallResponseProcessed(
                    callerId: data['callerId']!,
                    receiverId: data['receiverId']!,
                    callId: data['callId']!,
                    isAccept: true,
                    callType: data['callType'] ?? 'audio',
                    callMode: data['callMode'] ?? 'private',
                    callerRole: data['callerRole'] ?? '',
                    receiverRole: data['receiverRole'] ?? '',
                    receiverName: data['receiverName'] ?? '',
                    receiverImage: data['receiverImage'] ?? '',
                    callerName: data['callerfullName'] ?? '',
                    callerImage: data['callerImage'] ?? '',
                  );
                  Utils.showLog("✅ [NS:action] ACCEPT emitted to socket");
                },
              );
            },
          );
        } else {
          Utils.showLog("❌ [NS:action] Emitting DECLINE to socket...");
          SocketEmit.emitCallResponseProcessed(
            callerId: data['callerId']!,
            receiverId: data['receiverId']!,
            callId: data['callId']!,
            isAccept: false,
            callType: data['callType'] ?? 'audio',
            callMode: data['callMode'] ?? 'private',
            callerRole: data['callerRole'] ?? '',
            receiverRole: data['receiverRole'] ?? '',
            receiverName: data['receiverName'] ?? '',
            receiverImage: data['receiverImage'] ?? '',
            callerName: data['callerfullName'] ?? '',
            callerImage: data['callerImage'] ?? '',
          );
          Utils.showLog("✅ [NS:action] DECLINE emitted to socket");
        }
      } else {
        Utils.showLog("🔔 [NS:action] Notification tapped (no button), navigating...");
        onHandleNotificationNavigation(data);
      }
    } else {
      Utils.showLog("⚠️ [NS:action] Payload is null or empty — cannot process");
    }
  }

  static void onHandleNotificationNavigation(Map<String, dynamic> data) {
    Utils.showLog("🧭 [NS:nav] Handling navigation for type: ${data['type']}");

    if (data["type"] == "CHAT") {
      Utils.showLog("💬 [NS:nav] Navigating to chat screen");
      Utils.showLog("💬 [NS:nav] isListener: ${Database.fetchLoginUserProfileModel?.user?.isListener}");

      if (Database.fetchLoginUserProfileModel?.user?.isListener == false) {
        Utils.showLog("💬 [NS:nav] → User chat screen");
        Get.toNamed(
          AppRoutes.personalChatScreen,
          arguments: [
            data['senderId'],
            data['senderName'],
            data['isOnline'],
            data['senderProfilePic'],
            data['ratePrivateAudioCall'],
            data['ratePrivateVideoCall'],
            data['isFake'] ?? false,
            data['video'],
            data['isAvailableForPrivateVideoCall'],
            data['isAvailableForPrivateAudioCall'],
          ],
        );
      } else if (data["type"] == "missed_call") {
        Utils.showLog("📞 [NS:nav] Navigating to missed call profile: ${data['callerId']}");
        Get.toNamed(AppRoutes.profileDetailScreenView, arguments: data['callerId']);
      } else if (data["type"] == "callIncoming") {
        Utils.showLog("📞 [NS:nav] Navigating to incoming call screen");
        Get.toNamed(AppRoutes.incomingCallScreen, arguments: data);
      } else {
        Utils.showLog("⚠️ [NS:nav] Unknown notification type: ${data['type']}");
      }
    } else if (data["type"] == "missed_call") {
      Utils.showLog("📞 [NS:nav] Navigating to missed call profile: ${data['callerId']}");
      Get.toNamed(AppRoutes.profileDetailScreenView, arguments: data['callerId']);
    } else {
      Utils.showLog("⚠️ [NS:nav] Unknown notification type: ${data['type']}");
    }
  }

  static Future<void> showAwesomeNotification(RemoteMessage message) async {
    Utils.showLog("🔔 [NS:show] ===== showAwesomeNotification called =====");
    Utils.showLog("🔔 [NS:show] Full data: ${message.data}");
    Utils.showLog("🔔 [NS:show] Type: ${message.data['type']}");
    Utils.showLog("🔔 [NS:show] Title: ${message.data['title']}");
    Utils.showLog("🔔 [NS:show] Body: ${message.data['body']}");
    Utils.showLog("🔔 [NS:show] Has notification block: ${message.notification != null}");

    String type = message.data['type'] ?? '';
    String channelKey = 'chat_channel';
    NotificationCategory category = NotificationCategory.Message;
    List<NotificationActionButton> actions = [];

    if (type == 'callIncoming') {
      Utils.showLog("📞 [NS:show] Type is callIncoming → using call_channel_v2");
      channelKey = 'call_channel_v2';
      category = NotificationCategory.Call;
      actions = [
        NotificationActionButton(
            key: 'ACCEPT', label: 'Accept', color: Colors.green),
        NotificationActionButton(
            key: 'DECLINE', label: 'Decline', color: Colors.red),
      ];
    } else {
      Utils.showLog("💬 [NS:show] Type is '$type' → using chat_channel");
    }

    int getUniqueNotificationId() {
      var randomNumber = Random();
      var resultOne = randomNumber.nextInt(2000);
      var resultTwo = randomNumber.nextInt(100);
      if (resultTwo >= resultOne) resultTwo += 1;
      return resultTwo;
    }

    final notifId = getUniqueNotificationId();
    Utils.showLog("🔔 [NS:show] Creating notification — ID: $notifId, Channel: $channelKey");

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notifId,
          channelKey: channelKey,
          title: message.data['title'] ?? 'Notification',
          body: message.data['body'] ?? 'You have a new message',
          category: category,
          icon: 'resource://drawable/ic_notification',
          payload: message.data
              .map((k, v) => MapEntry(k.toString(), v.toString())),
          notificationLayout: NotificationLayout.Default,
          displayOnForeground: true,
          displayOnBackground: true,
          wakeUpScreen: (channelKey == 'call_channel_v2'),
          fullScreenIntent: (channelKey == 'call_channel_v2'),
          criticalAlert: (channelKey == 'call_channel_v2'),
          autoDismissible: (channelKey != 'call_channel_v2'),
          timeoutAfter: (channelKey == 'call_channel_v2')
              ? const Duration(seconds: 30)
              : null,
        ),
        actionButtons: actions,
      );
      Utils.showLog("✅ [NS:show] createNotification SUCCESS — ID: $notifId");
    } catch (e, stack) {
      Utils.showLog("❌ [NS:show] createNotification FAILED: $e");
      Utils.showLog("❌ [NS:show] StackTrace: $stack");
    }

    Utils.showLog("🔔 [NS:show] ===== showAwesomeNotification done =====");
  }

  static Future<void> firebaseInit() async {
    Utils.showLog("🔥 [NS:fbInit] ===== firebaseInit called =====");

    FirebaseMessaging.onMessage.listen((message) {
      Utils.showLog("🔥 [NS:fbInit] onMessage received");
      Utils.showLog("🔥 [NS:fbInit] Data: ${message.data}");
      Utils.showLog("🔥 [NS:fbInit] Type: ${message.data['type']}");

      // ✅ FIX: server-side signal that the call was answered/declined/ended/
      // timed out somewhere else. This is the ONLY reliable way to stop the
      // ringtone when the app is backgrounded and the socket connection is
      // dead — sockets don't survive Doze/App Standby on real devices, but
      // FCM data messages still get delivered. Handle it before anything else.
      if (message.data['type'] == 'callCancel') {
        Utils.showLog("📞 [NS:fbInit] callCancel received (foreground) — dismissing call notification");
        dismissCallNotification();
        return;
      }

      if ((Get.currentRoute == AppRoutes.personalChatScreen ||
          Get.currentRoute == AppRoutes.hostPersonalChatScreen) &&
          message.data["type"] == "CHAT") {
        Utils.showLog("💬 [NS:fbInit] Already on chat screen — suppressing notification");
      } else if (message.data['type'] == 'listener_verified') {
        Utils.showLog("✅ [NS:fbInit] listener_verified — showing restart dialog");
        Get.dialog(
          barrierDismissible: false,
          barrierColor: AppColors.black.withValues(alpha: 0.8),
          Dialog(
            backgroundColor: AppColors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: const AppRestartDialog(),
          ),
        );
      } else if (message.data['type'] == 'callIncoming') {
        // ✅ Foreground incoming call: skip the system notification entirely.
        // The in-app IncomingCallController already handles ringtone,
        // vibration, and Accept/Decline UI — showing the OS notification
        // too creates two independent ringtones playing at once, and the
        // system one has no lifecycle tie to the in-app screen so it
        // keeps ringing even after the screen is up.
        Utils.showLog("📞 [NS:fbInit] Foreground callIncoming — navigating without system notification");
        Get.toNamed(AppRoutes.incomingCallScreen, arguments: message.data);
      } else {
        Utils.showLog("🔥 [NS:fbInit] Calling showAwesomeNotification");
        showAwesomeNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Utils.showLog("🔥 [NS:fbInit] onMessageOpenedApp — app opened from notification");
      Utils.showLog("🔥 [NS:fbInit] Data: ${message.data}");
      onHandleNotificationNavigation(message.data);
    });

    Utils.showLog("✅ [NS:fbInit] firebaseInit listeners registered");
  }

  static Future<void> dismissCallNotification() async {
    Utils.showLog("🔔 [NS:dismiss] Dismissing call_channel_v2 notifications...");
    try {
      await AwesomeNotifications()
          .cancelNotificationsByChannelKey('call_channel_v2');
      Utils.showLog("✅ [NS:dismiss] Call notifications dismissed successfully");
    } catch (e) {
      Utils.showLog("❌ [NS:dismiss] Error dismissing call notifications: $e");
    }
  }
}

// ─── Background FCM handler ───────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> backgroundNotification(RemoteMessage message) async {
  print("🔔 [BG] ===== Background message received =====");
  print("🔔 [BG] Message ID: ${message.messageId}");
  print("🔔 [BG] Data: ${message.data}");
  print("🔔 [BG] Notification title: ${message.notification?.title}");
  print("🔔 [BG] Notification body: ${message.notification?.body}");
  print("🔔 [BG] Has notification block: ${message.notification != null}");
  print("🔔 [BG] Has data block: ${message.data.isNotEmpty}");

  await Firebase.initializeApp();
  print("✅ [BG] Firebase initialized");

  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'call_channel_v2',
        channelName: 'Call Channel v2',
        channelDescription: 'Channel for incoming call notifications',
        defaultColor: Colors.green,
        importance: NotificationImportance.Max,
        locked: true,
        playSound: true,
        soundSource: 'resource://raw/ringtone',
        enableVibration: true,
      ),
      NotificationChannel(
        channelKey: 'chat_channel',
        channelName: 'Chat Channel',
        channelDescription: 'Channel for chat notifications',
        defaultColor: Colors.blue,
        importance: NotificationImportance.High,
        playSound: true,
        enableVibration: true,
      ),
    ],
    debug: true,
  );
  print("✅ [BG] AwesomeNotifications initialized");

  // ✅ FIX: handle the cancel signal inside the background isolate itself.
  // This is the path that actually stops the ringtone/notification when the
  // call was answered, declined, ended, or timed out while the app was
  // backgrounded or the screen was locked — the socket-based handlers in
  // SocketListen never run in this isolate, so this FCM message is the only
  // thing that can reach it.
  if (message.data['type'] == 'callCancel') {
    print("📞 [BG] callCancel received — cancelling call_channel_v2 notifications");
    try {
      await AwesomeNotifications()
          .cancelNotificationsByChannelKey('call_channel_v2');
      print("✅ [BG] call_channel_v2 notifications cancelled");
    } catch (e) {
      print("❌ [BG] Error cancelling call notifications: $e");
    }
    print("🔔 [BG] ===== Background handler done (callCancel) =====");
    return;
  }

  try {
    print("🔔 [BG] Calling showAwesomeNotification...");
    await NotificationServices.showAwesomeNotification(message);
    print("✅ [BG] showAwesomeNotification completed successfully");
  } catch (e, stack) {
    print("❌ [BG] showAwesomeNotification FAILED: $e");
    print("❌ [BG] StackTrace: $stack");
  }

  print("🔔 [BG] ===== Background handler done =====");
}