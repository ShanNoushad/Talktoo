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
    await AwesomeNotifications().removeChannel('call_channel');
    await AwesomeNotifications().removeChannel('call_channel_v2');
    await AwesomeNotifications().removeChannel('chat_channel');
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

    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onAwesomeNotificationActionReceived,
    );

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );
  }
  static Future<void> onAwesomeNotificationActionReceived(
      ReceivedAction receivedAction) async {
    Utils.showLog("📦 Notification payload: ${receivedAction.payload}");
    Utils.showLog("🔘 Button pressed: ${receivedAction.buttonKeyPressed}");
    Utils.showLog("🆔 Notification ID: ${receivedAction.id}");

    if (receivedAction.payload != null && receivedAction.payload!.isNotEmpty) {
      final data = receivedAction.payload!;

      if (receivedAction.buttonKeyPressed == 'ACCEPT' ||
          receivedAction.buttonKeyPressed == 'DECLINE') {

        await AwesomeNotifications().dismiss(receivedAction.id!);

        // ✅ Reconnect socket if not connected
        if (!SocketEmit.isConnected()) {
          final identity = (await MobileDeviceIdentifier().getDeviceId())!;
          final fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
          await Database.init(identity, fcmToken);
          await Future.delayed(const Duration(milliseconds: 500));
          await SocketService.socketConnect();

          // ✅ Retry loop — wait up to 5 seconds
          int retries = 0;
          while (!SocketEmit.isConnected() && retries < 10) {
            await Future.delayed(const Duration(milliseconds: 500));
            retries++;
            Utils.showLog("⏳ Waiting for socket... attempt $retries");
          }

          if (!SocketEmit.isConnected()) {
            Utils.showLog("❌ Socket failed to connect after retries.");
            return;
          }

          Utils.showLog("✅ Socket ready after $retries retries");
        }

        final isAccept = receivedAction.buttonKeyPressed == 'ACCEPT';

        if (!SocketEmit.isConnected()) {
          Utils.showLog("❌ Socket still not connected, cannot emit");
          return;
        }

        if (isAccept) {
          PermissionHandler.onGetCameraPermission(
            onGranted: () {
              PermissionHandler.onGetMicrophonePermission(
                onGranted: () {
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
                },
              );
            },
          );
        } else {
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
        }

      } else {
        onHandleNotificationNavigation(data);
      }
    }
  }

  static void onHandleNotificationNavigation(Map<String, dynamic> data) {
    if (data["type"] == "CHAT") {
      Utils.showLog("Enter in notification tap chat********************");

      if (Database.fetchLoginUserProfileModel?.user?.isListener == false) {
        Utils.showLog("User chat screen *******************************");
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
      } else {
        Utils.showLog("Listener chat screen *******************************");
        Get.toNamed(
          AppRoutes.hostPersonalChatScreen,
          arguments: [
            data['senderId'],
            data['senderName'],
            data['isOnline'],
            data['senderProfilePic'],
          ],
        );
      }
    } else if (data["type"] == "missed_call") {
      Get.toNamed(AppRoutes.profileDetailScreenView,
          arguments: data['callerId']);
    } else {
      Utils.showLog("Enter in else****************************");
    }
  }

  static Future<void> showAwesomeNotification(RemoteMessage message) async {
    Utils.showLog("show awesome notification AAA");

    String type = message.data['type'] ?? '';
    String channelKey = 'chat_channel';
    NotificationCategory category = NotificationCategory.Message;
    List<NotificationActionButton> actions = [];

    if (type == 'callIncoming') {
      Utils.showLog("callIncoming notification ........");
      channelKey = 'call_channel_v2'; // ✅ changed
      category = NotificationCategory.Call;
      actions = [
        NotificationActionButton(
            key: 'ACCEPT', label: 'Accept', color: Colors.green),
        NotificationActionButton(
            key: 'DECLINE', label: 'Decline', color: Colors.red),
      ];
    }

    int getUniqueNotificationId() {
      var randomNumber = Random();
      var resultOne = randomNumber.nextInt(2000);
      var resultTwo = randomNumber.nextInt(100);
      if (resultTwo >= resultOne) resultTwo += 1;
      return resultTwo;
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: getUniqueNotificationId(),
        channelKey: channelKey,
        title: message.data['title'] ?? 'Notification',
        body: message.data['body'] ?? 'You have a new message',
        category: category,
        icon: 'resource://drawable/ic_notification',
        payload: message.data.map((k, v) => MapEntry(k.toString(), v.toString())),
        notificationLayout: NotificationLayout.Default,
        displayOnForeground: true,
        displayOnBackground: true,
        wakeUpScreen: (channelKey == 'call_channel_v2'),
        fullScreenIntent: (channelKey == 'call_channel_v2'),
        criticalAlert: (channelKey == 'call_channel_v2'),
        autoDismissible: (channelKey != 'call_channel_v2'),
        timeoutAfter: (channelKey == 'call_channel_v2')
            ? const Duration(seconds: 30)
            : null,  // ✅ changed
      ),
      actionButtons: actions,
    );
  }
  static Future<void> firebaseInit() async {
    Utils.showLog("notification firebase init");

    FirebaseMessaging.onMessage.listen((message) {
      Utils.showLog(
          "Notification service firebase init => $currentAppLifecycleState");
      Utils.showLog("Notification AAA => ${message.data}");
      Utils.showLog("Notification => ${message.data["type"]}");
      Utils.showLog("Data Title => ${message.data['title']}");
      Utils.showLog("Data Body => ${message.data['body']}");

      if (currentAppLifecycleState == AppLifecycleState.resumed) {
        Utils.showLog("app is in the foreground.");

        if ((Get.currentRoute == AppRoutes.personalChatScreen ||
            Get.currentRoute == AppRoutes.hostPersonalChatScreen) &&
            message.data["type"] == "CHAT") {
          Utils.showLog("User is already on chat screen. Suppressing.");
        } else if (message.data['type'] == 'listener_verified') {
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
        } else {
          showAwesomeNotification(message);
        }
      } else if (currentAppLifecycleState == AppLifecycleState.paused) {
        Utils.showLog("app is in background/paused.");
        showAwesomeNotification(message);
      }
    });

    FirebaseMessaging.onBackgroundMessage(backgroundNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Utils.showLog("App opened from notification: ${message.data}");
      onHandleNotificationNavigation(message.data);
    });
  }

  static Future<void> dismissCallNotification() async {
    try {
      await AwesomeNotifications()
          .cancelNotificationsByChannelKey('call_channel');
      Utils.showLog("✅ Call notifications dismissed successfully");
    } catch (e) {
      Utils.showLog("❌ Error dismissing call notifications: $e");
    }
  }
}

@pragma('vm:entry-point')
Future<void> backgroundNotification(RemoteMessage message) async {
  await Firebase.initializeApp();
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'call_channel',
        channelName: 'Call Channel',
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
    debug: false,
  );
  await NotificationServices.showAwesomeNotification(message);
}