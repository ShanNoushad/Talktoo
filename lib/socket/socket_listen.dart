//     import 'dart:async';
//     import 'dart:developer';
//
//     import 'package:get/get.dart';
//     import 'package:proximity_screen_lock/proximity_screen_lock.dart';
//     import 'package:talk_in/routes/app_routes.dart';
//     import 'package:talk_in/socket/socket_emit.dart';
//     import 'package:talk_in/socket/socket_service.dart';
//     import 'package:talk_in/ui/host_flow/host_home_screen/api/host_coin_api.dart';
//     import 'package:talk_in/ui/host_flow/host_home_screen/controller/host_home_screen_controller.dart';
//     import 'package:talk_in/ui/host_flow/host_home_screen/model/listener_coin_model.dart';
//     import 'package:talk_in/ui/host_flow/host_personal_chat_screen/controller/host_personal_chat_screen_controller.dart';
//     import 'package:talk_in/ui/host_flow/host_personal_chat_screen/model/host_personal_chat_model.dart';
//     import 'package:talk_in/ui/user_flow/call_cut_screen/controller/call_cut_controller.dart';
//     import 'package:talk_in/ui/user_flow/home_screen/api/user_coin_api.dart';
// import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
//     import 'package:talk_in/ui/user_flow/home_screen/model/user_coin_model.dart';
//     import 'package:talk_in/ui/user_flow/personal_chat_screen/controller/personal_chat_screen_controller.dart';
//     import 'package:talk_in/ui/user_flow/personal_chat_screen/model/personal_chat_model.dart';
//     import 'package:talk_in/ui/user_flow/video_call_screen/controller/video_call_controller.dart';
//     import 'package:talk_in/ui/user_flow/voice_call_screen/controller/voice_call_controller.dart';
//     import 'package:talk_in/utils/constant.dart';
//     import 'package:talk_in/utils/database.dart';
//     import 'package:talk_in/utils/socket_events.dart';
//     import 'package:talk_in/utils/socket_params.dart';
//     import 'package:talk_in/utils/utils.dart';
//
// import '../services/notification_service/notification_services.dart';
//
//     class SocketListen {
//       static final Map<String, String> _latestMessageIdPerChat = {};
//       static Timer? _seenEmitTimer;
//       static bool _listenersRegistered = false;
//
//
//       static void registerListeners() {
//         if (socket == null) return;
//
//         // Prevent duplicate registration
//         if (_listenersRegistered) {
//           Utils.showLog("Socket listeners already registered.");
//           return;
//         }
//
//         _listenersRegistered = true;
//
//         Utils.showLog("Registering socket listeners...");
//
//         // Remove existing listeners (safe even if none exist)
//         socket!
//           ..off(SocketEvents.sendMessage)
//           ..off(SocketEvents.markMessageSeen)
//           ..off(SocketEvents.callOutgoingRinging)
//           ..off(SocketEvents.outGoingCall)
//           ..off(SocketEvents.incomingCall)
//           ..off(SocketEvents.callResponseProcessed)
//           ..off(SocketEvents.callDeclined)
//           ..off(SocketEvents.callAnswered)
//           ..off(SocketEvents.callTimedOut)
//           ..off(SocketEvents.callEnded)
//           ..off(SocketEvents.callerCallCut)
//           ..off(SocketEvents.callTerminated)
//           ..off(SocketEvents.randomCallRinging)
//           ..off(SocketEvents.notEnoughCoins)
//           ..off(SocketEvents.callCoinsDeducted)
//           ..off(SocketEvents.callCutData);
//
//         // Register listeners
//         socket!
//           ..on(SocketEvents.sendMessage, handleSendMessage)
//           ..on(SocketEvents.markMessageSeen, handleMarkMessageSeen)
//           ..on(SocketEvents.callOutgoingRinging, handleCallOutgoingRinging)
//           ..on(SocketEvents.outGoingCall, handleOutGoingCall)
//           ..on(SocketEvents.incomingCall, handleIncomingCall)
//           ..on(SocketEvents.callResponseProcessed, handleCallResponseProcessed)
//           ..on(SocketEvents.callDeclined, handleCallDeclined)
//           ..on(SocketEvents.callAnswered, handleCallAnswered)
//           ..on(SocketEvents.callTimedOut, handleCallTimedOut)
//           ..on(SocketEvents.callEnded, handleCallEnded)
//           ..on(SocketEvents.callerCallCut, handleCallRejected)
//           ..on(SocketEvents.callTerminated, handleCallTerminated)
//           ..on(SocketEvents.randomCallRinging, handleRandomCallRinging)
//           ..on(SocketEvents.notEnoughCoins, handleNotEnoughCoins)
//           ..on(SocketEvents.callCoinsDeducted, handleCallCoinsDeducted)
//           ..on(SocketEvents.callCutData, handleCallCutData);
//
//         // Optional: Log reconnects
//         socket!.on("connect", (_) {
//           Utils.showLog("Socket connected: ${socket!.id}");
//         });
//
//         socket!.on("disconnect", (_) {
//           Utils.showLog("Socket disconnected");
//         });
//
//         Utils.showLog("Socket listeners registered successfully.");
//       }
//       static void handleSendMessage(dynamic message) {
//         Utils.showLog("Received messageDispatched: $message");
//
//         try {
//           final Map<String, dynamic> data = message['data'];
//           final String chatTopicId = data['chatTopicId'] ?? '';
//
//           if (Get.isRegistered<HostPersonalChatScreenController>()) {
//             final hostController = Get.find<HostPersonalChatScreenController>();
//             if (chatTopicId == hostController.chatTopicId) {
//               final newMsg = ListenerChat.fromJson(data);
//
//               if (data["senderId"] == Database.fetchListenerProfileModel?.data?.id && data['messageType'] == 3) {
//                 hostController.oldChatListener.removeAt(0);
//               }
//
//               hostController.isLoadingAudio = false;
//               hostController.update([Constant.idGetOldChat]);
//
//               // hostController.oldChatListener.insert(0, newMsg);
//               // Try to find and replace the optimistic message
//               final index = hostController.oldChatListener.indexWhere(
//                   (msg) => msg.senderId == Database.loginUserId && msg.message == newMsg.message && msg.id?.length == 13 // temporary ID is a timestamp
//                   );
//
//               if (index != -1) {
//                 hostController.oldChatListener[index] = newMsg;
//               } else {
//                 hostController.oldChatListener.insert(0, newMsg);
//               }
//
//               hostController.onScrollDown();
//               hostController.update([Constant.idGetOldChat]);
//
//               if (Get.currentRoute == AppRoutes.hostPersonalChatScreen || Get.currentRoute == AppRoutes.personalChatScreen) {
//                 final String messageId = message['messageId']; // ✅ Extract messageId
//
//                 if (data["senderId"] != Database.fetchListenerProfileModel?.data?.id &&
//                     data['receiverId'] == Database.fetchListenerProfileModel?.data?.id) {
//                   // Future.delayed(const Duration(seconds: 1), () {
//                   //   Utils.showLog("Message seen event");
//                   //   SocketEmit.onMessageSeen({
//                   //     SocketParams.messageId: messageId,
//                   //     SocketParams.senderId: data["senderId"],
//                   //   });
//                   // });
//
//                   _latestMessageIdPerChat[chatTopicId] = messageId;
//
//     // Cancel previous timer if running
//                   _seenEmitTimer?.cancel();
//
//     // Start a new short timer to emit only once after all messages received
//                   _seenEmitTimer = Timer(const Duration(milliseconds: 500), () {
//                     final latestMsgId = _latestMessageIdPerChat[chatTopicId];
//                     if (latestMsgId != null) {
//                       Utils.showLog("🔥 Emitting seen for last messageId: $latestMsgId");
//
//                       SocketEmit.onMessageSeen({
//                         SocketParams.messageId: latestMsgId,
//                         SocketParams.senderId: data["senderId"],
//                       });
//
//                       _latestMessageIdPerChat.remove(chatTopicId); // Clear after use
//                     }
//                   });
//                 } else {
//                   Utils.showLog("Message not for current user");
//                 }
//               }
//               return;
//             }
//           }
//
//           if (Get.isRegistered<PersonalChatScreenController>()) {
//             final userController = Get.find<PersonalChatScreenController>();
//             if (chatTopicId == userController.chatTopicId) {
//               final newMsg = PersonalChat.fromJson(data);
//
//               if (data["senderId"] == Database.loginUserId && data['messageType'] == 3) {
//                 userController.oldChat.removeAt(0);
//               }
//
//               userController.isLoadingAudio = false;
//               userController.update([Constant.idGetOldChat]);
//
//               // userController.oldChat.insert(0, newMsg);
//
//               // Try to find and replace the optimistic message
//               final index = userController.oldChat.indexWhere(
//                   (msg) => msg.senderId == Database.loginUserId && msg.message == newMsg.message && msg.id?.length == 13 // temporary ID is a timestamp
//                   );
//
//               if (index != -1) {
//                 userController.oldChat[index] = newMsg;
//               } else {
//                 userController.oldChat.insert(0, newMsg);
//               }
//
//               userController.onScrollDown();
//               userController.update([Constant.idGetOldChat]);
//
//               if (Get.currentRoute == AppRoutes.hostPersonalChatScreen || Get.currentRoute == AppRoutes.personalChatScreen) {
//                 final String messageId = message['messageId']; // ✅ Extract messageId
//
//                 if (data["senderId"] != Database.fetchLoginUserProfileModel?.user?.id &&
//                     data['receiverId'] == Database.fetchLoginUserProfileModel?.user?.id) {
//                   // Future.delayed(const Duration(seconds: 1), () {
//                   //   SocketEmit.onMessageSeen({
//                   //     SocketParams.messageId: messageId,
//                   //     SocketParams.senderId: data["senderId"],
//                   //   });
//                   // });
//
//                   _latestMessageIdPerChat[chatTopicId] = messageId;
//
//     // Cancel previous timer if running
//                   _seenEmitTimer?.cancel();
//
//     // Start a new short timer to emit only once after all messages received
//                   _seenEmitTimer = Timer(const Duration(milliseconds: 500), () {
//                     final latestMsgId = _latestMessageIdPerChat[chatTopicId];
//                     if (latestMsgId != null) {
//                       Utils.showLog("🔥 Emitting seen for last messageId: $latestMsgId");
//
//                       SocketEmit.onMessageSeen({
//                         SocketParams.messageId: latestMsgId,
//                         SocketParams.senderId: data["senderId"],
//                       });
//
//                       _latestMessageIdPerChat.remove(chatTopicId); // Clear after use
//                     }
//                   });
//                 } else {
//                   Utils.showLog("Message not for current user");
//                 }
//               }
//
//               return;
//             }
//           }
//
//           Utils.showLog(" Message not for current chat topic");
//         } catch (e) {
//           Utils.showLog(" Error parsing socket message: $e");
//         }
//       }
//       static void handleMarkMessageSeen(dynamic data) {
//         Utils.showLog("Received markMessageSeen: $data");
//     /*
//         if (Get.isRegistered<HostPersonalChatScreenController>()) {
//           final hostController = Get.find<HostPersonalChatScreenController>();
//           Utils.showLog("hostController.isMsgSeen111: ${hostController.isMsgSeen}");
//           hostController.isMsgSeen = true;
//           Utils.showLog("hostController.isMsgSeen222: ${hostController.isMsgSeen}");
//
//           hostController.update();
//           Utils.showLog("hostController.isMsgSeen33: ${hostController.isMsgSeen}");
//         }
//         if (Get.isRegistered<PersonalChatScreenController>()) {
//           final Controller = Get.find<PersonalChatScreenController>();
//           Utils.showLog("hostController.isMsgSeen111: ${Controller.isMsgSeen}");
//           Controller.isMsgSeen = true;
//           Utils.showLog("hostController.isMsgSeen222: ${Controller.isMsgSeen}");
//
//           Controller.update();
//           Utils.showLog("hostController.isMsgSeen33: ${Controller.isMsgSeen}");
//         }
//     */
//       }
//
//       // static void handleMarkMessageSeen(dynamic data) {
//       //   Utils.showLog("Received markMessageSeen: $data");
//       //
//       //   try {
//       //     final parsed = jsonDecode(data);
//       //     final messageId = parsed['messageId'];
//       //
//       //     if (Get.isRegistered<PersonalChatScreenController>()) {
//       //       final controller = Get.find<PersonalChatScreenController>();
//       //
//       //       for (var msg in controller.oldChat) {
//       //         if (msg.senderId == Database.loginUserId) {
//       //           msg.isRead = true;
//       //         }
//       //       }
//       //
//       //       controller.update([Constant.idGetOldChat]);
//       //     }
//       //   } catch (e) {
//       //     Utils.showLog("Error in markMessageSeen handler: $e");
//       //   }
//       // }
//
//       /// when caller call then caller this event listen
//       static void handleOutGoingCall(dynamic data) {
//         Get.back();
//         Utils.showLog("Socket Listen => callEstablished event: $data");
//         if (data['callType'] == "audio") {
//           Get.toNamed(AppRoutes.outgoingAudioCallScreen, arguments: data);
//         } else {
//           Get.toNamed(AppRoutes.outgoingCallScreen, arguments: data);
//         }
//       }
//
//       /// when caller call then receiver this event listen
//       static Future<void> handleIncomingCall(dynamic data) async {
//         Utils.showLog("Socket Listen => incomingCall event: $data");
//
//         Get.toNamed(AppRoutes.incomingCallScreen, arguments: data);
//       }
//
//       /// If any error like busy, caller or receiver not found then listen always in callOutgoingRinging event
//       static void handleCallOutgoingRinging(dynamic data) {
//         Utils.showLog("Socket Listen => callOutgoingRinging (error or status): $data");
//         // Get.back();
//         Utils.showToast(Get.context!, data['message']);
//       }
//
//       /// receiver call cut listen this event
//       static void handleCallDeclined(dynamic data) {
//         Utils.showLog("Socket Listen => callDeclined event: $data");
//         if (Get.currentRoute == AppRoutes.outgoingCallScreen ||
//             Get.currentRoute == AppRoutes.incomingCallScreen ||
//             Get.currentRoute == AppRoutes.outgoingAudioCallScreen) {
//           log(" <<<<<<<<<<<<<<<<<<<<<<<<< ${Get.currentRoute}");
//           Get.back();
//         }
//       }
//
//       /// caller call and receiver call answer then this event listen
//       static void handleCallAnswered(dynamic data) {
//         NotificationServices.dismissCallNotification();
//         Utils.showLog("Socket Listen => callAnswered event: $data");
//         Get.back();
//
//         // Utils.showToast(Get.context!, data['message']);
//         // if (Get.isRegistered<OutgoingCallController>()) {
//         Utils.showLog("ooooooooooooooooooooooooooo");
//
//         if (data['callType'] == "audio") {
//           // if (!Get.isRegistered<OutgoingCallController>()) {
//           //   Get.put<OutgoingCallController>(OutgoingCallController());
//           // }
//           // final controller = Get.find<OutgoingCallController>();
//
//           Utils.showLog("vvvvvvvvvvvvvvvvvvvvvvvvvv");
//
//           Get.toNamed(AppRoutes.voiceCallScreen, arguments: {
//             "callerId": data['callerId'],
//             "receiverId": data['receiverId'],
//             "callType": data['callType'],
//             "callerRole": data['callerRole'],
//             "receiverRole": data['receiverRole'],
//             "callId": data['callId'],
//             "receiverName": data['receiverName'],
//             "callerfullName": data['callerfullName'],
//             "receiverImage": data['receiverImage'],
//             "callerImage": data['callerImage'],
//             "isAccept": data['isAccept'],
//             "callMode": data['callMode'],
//             // "micMute": controller.micMute,
//             // "micMute": controller.micMute,
//             // "speakerOn": controller.isSpeakerOn,
//           });
//         } else {
//           Get.toNamed(AppRoutes.videoCallScreen, arguments: data);
//         }
//         // }
//       }
//
//       /// when caller call then Invalid caller, receiver, or call history then listen this event
//       static void handleCallResponseProcessed(dynamic data) {
//         Utils.showLog("Socket Listen => callResponseProcessed event: $data");
//         Utils.showToast(Get.context!, data['message']);
//       }
//
//       /// if callId not match then listen also in callTimedOut ( to receiver )
//       static void handleCallTimedOut(dynamic data) {
//         Utils.showLog("Socket Listen => callTimedOut event: $data");
//         // Utils.showToast(Get.context!, data['message']);
//         if (Get.isRegistered<VideoCallController>()) {
//           final videoCallController = Get.find<VideoCallController>();
//
//           SocketEmit.emitCallTerminated(
//             callerId: videoCallController.callerId.toString(),
//             receiverId: videoCallController.receiverId.toString(),
//             callId: videoCallController.callId.toString(),
//             callType: videoCallController.callType.toString(),
//             callMode: videoCallController.callMode.toString(),
//             callerRole: videoCallController.callerRole.toString(),
//             receiverRole: videoCallController.receiverRole.toString(),
//             receiverName: videoCallController.receiverName.toString(),
//             receiverImage: videoCallController.receiverImage.toString(),
//           );
//         }
//       }
//
//       /// when caller cut call then this event listen
//       // static void handleCallEnded(dynamic data) {
//       //   Utils.showLog("Socket Listen => callEnded event: $data");
//       //   if (Get.currentRoute == AppRoutes.incomingCallScreen) {
//       //     log("***************************${Get.currentRoute == AppRoutes.incomingCallScreen}");
//       //     Get.back();
//       //   }
//       // }
//
//
//
//       /// when caller cut call then this event listen
//       static void handleCallEnded(dynamic data) {
//         Utils.showLog("Socket Listen => callEnded event: $data");
//         // Dismiss call notification
//         NotificationServices.dismissCallNotification();
//
//         if (Get.currentRoute == AppRoutes.incomingCallScreen) {
//           log("***************************${Get.currentRoute == AppRoutes.incomingCallScreen}");
//           Get.back();
//         }
//       }
//
//       /// if Invalid caller, receiver, or call history then listen also in callRejected event
//       static void handleCallRejected(dynamic data) {
//         Utils.showLog("Socket Listen => callRejected event: $data");
//       }
//
//       /// both join call and then cut call this event listen
//       // static Future<void> handleCallTerminated(dynamic data) async {
//       //   UserCoinModel? userCoinModel;
//       //   ListenerCoinModel? listenerCoinModel;
//       //   Utils.showLog("Socket Listen => callTerminated event: $data");
//       //
//       //   final callerRole = data['callerRole'];
//       //   final callMode = data['callMode'];
//       //   if (Database.fetchLoginUserProfileModel?.user?.isListener == false && callMode == "random") {
//       //     // Get.close(2);
//       //     if (Get.currentRoute == AppRoutes.videoCallScreen || Get.currentRoute == AppRoutes.voiceCallScreen) {
//       //       StreamSubscription<bool>? subsProximity;
//       //
//       //       await ProximityScreenLock.setActive(false);
//       //       // Subscribe to proximity states
//       //       subsProximity = ProximityScreenLock.proximityStates.listen((objectDetected) {
//       //         log("call cut screen controller Proximity event (even though disabled): $objectDetected   $subsProximity");
//       //       });
//       //
//       //       Get.back();
//       //     }
//       //
//       //     log("is listener ${Database.fetchLoginUserProfileModel?.user?.isListener}");
//       //     log("call mode  $callMode");
//       //   } else {
//       //     if (Get.currentRoute == AppRoutes.videoCallScreen || Get.currentRoute == AppRoutes.voiceCallScreen) {
//       //       Get.back();
//       //     }
//       //   }
//       //   if (Database.fetchLoginUserProfileModel?.user?.isListener == false && callerRole == "user") {
//       //     Get.toNamed(AppRoutes.callCutScreen, arguments: data);
//       //   }
//       //
//       //   userCoinModel = await UserCoinApi.callApi();
//       //   Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");
//       //
//       //   if (Get.isRegistered<HostHomeScreenController>()) {
//       //     final hostHomeScreenController = Get.find<HostHomeScreenController>();
//       //
//       //     hostHomeScreenController.isCoinLoading = true;
//       //     hostHomeScreenController.update([Constant.idCoinUpdate]);
//       //     listenerCoinModel = await HostCoinApi.callApi();
//       //     Database.onSetListenerCoin(listenerCoinModel!.coin.toString());
//       //     hostHomeScreenController.isCoinLoading = false;
//       //     hostHomeScreenController.update([Constant.idCoinUpdate]);
//       //   }
//       // }
//
//       static Future<void> handleCallTerminated(dynamic data) async {
//         UserCoinModel? userCoinModel;
//         ListenerCoinModel? listenerCoinModel;
//         Utils.showLog("Socket Listen => callTerminated event: $data");
//         VoiceCallController? controller;
//         if (Get.currentRoute == AppRoutes.voiceCallScreen && Get.isRegistered<VoiceCallController>()) {
//           controller = Get.find<VoiceCallController>();
//         } else {
//           log("⚠️ VoiceCallController not registered, skipping cleanup.");
//         }
//         final callerRole = data['callerRole'];
//         final callMode = data['callMode'];
//
//         // ✅ First, properly cleanup proximity sensor and screen lock
//         try {
//           await ProximityScreenLock.setActive(false);
//           // ✅ Force screen to turn ON if it was locked by proximity
//           controller?.isProximitySupported = false;
//           controller?.isObjectNear = false;
//           controller?.userEnabledSpeaker = false;
//           log("✅ Proximity sensor deactivated and screen unlocked  userEnabledSpeaker = ${controller?.userEnabledSpeaker} isObjectNear = ${controller?.isObjectNear} isProximitySupported = ${controller?.isProximitySupported}");
//         } catch (e) {
//           log("❌ Error deactivating proximity sensor: $e");
//         }
//
//         if (Database.fetchLoginUserProfileModel?.user?.isListener == false && callMode == "random") {
//           if (Get.currentRoute == AppRoutes.videoCallScreen || Get.currentRoute == AppRoutes.voiceCallScreen) {
//             Get.back();
//           }
//
//           log("is listener ${Database.fetchLoginUserProfileModel?.user?.isListener}");
//           log("call mode  $callMode");
//         } else {
//           if (Get.currentRoute == AppRoutes.videoCallScreen || Get.currentRoute == AppRoutes.voiceCallScreen) {
//             Get.back();
//           }
//         }
//
//         if (Database.fetchLoginUserProfileModel?.user?.isListener == false && callerRole == "user") {
//           Get.toNamed(AppRoutes.callCutScreen, arguments: data);
//         }
//
//         userCoinModel = await UserCoinApi.callApi();
//         Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");
//
//
//         print("user coin listen ::::::::::::::::::${userCoinModel?.coin}");
//         print("user coin listen ::::::::::::::::::${Database.userCoin}");
//
//         if (Get.isRegistered<HostHomeScreenController>()) {
//           final hostHomeScreenController = Get.find<HostHomeScreenController>();
//           hostHomeScreenController.isCoinLoading = true;
//           hostHomeScreenController.update([Constant.idCoinUpdate]);
//           listenerCoinModel = await HostCoinApi.callApi();
//           Database.onSetListenerCoin(listenerCoinModel!.coin.toString());
//           hostHomeScreenController.isCoinLoading = false;
//           hostHomeScreenController.update([Constant.idCoinUpdate]);
//
//         }
//
//         if (Get.isRegistered<HomeScreenController>()) {
//           Get.find<HomeScreenController>()
//               .update([Constant.idCoinUpdate]);}
//       }
//
//       /// random call If any error like busy, caller or receiver not found then listen always in incomingRingingStarted event
//       static void handleRandomCallRinging(dynamic data) {
//         Utils.showLog("Socket Listen => random call incomingRingingStarted (error or status): $data");
//         Utils.showToast(Get.context!, data['message']);
//       }
//
//       static void handleNotEnoughCoins(dynamic data) {
//         Utils.showLog("Socket Listen => handleNotEnoughCoins: $data");
//         if (Get.isRegistered<VideoCallController>()) {
//           final videoCallController = Get.find<VideoCallController>();
//
//           SocketEmit.emitCallTerminated(
//             callerId: videoCallController.callerId.toString(),
//             receiverId: videoCallController.receiverId.toString(),
//             callId: videoCallController.callId.toString(),
//             callType: videoCallController.callType.toString(),
//             callMode: videoCallController.callMode.toString(),
//             callerRole: videoCallController.callerRole.toString(),
//             receiverRole: videoCallController.receiverRole.toString(),
//             receiverName: videoCallController.receiverName.toString(),
//             receiverImage: videoCallController.receiverImage.toString(),
//           );
//         }
//         if (Get.isRegistered<VoiceCallController>()) {
//           final voiceCallController = Get.find<VoiceCallController>();
//
//           SocketEmit.emitCallTerminated(
//             callerId: voiceCallController.callerId.toString(),
//             receiverId: voiceCallController.receiverId.toString(),
//             callId: voiceCallController.callId.toString(),
//             callType: voiceCallController.callType.toString(),
//             callMode: voiceCallController.callMode.toString(),
//             callerRole: voiceCallController.callerRole.toString(),
//             receiverRole: voiceCallController.receiverRole.toString(),
//             receiverName: voiceCallController.receiverName.toString(),
//             receiverImage: voiceCallController.receiverImage.toString(),
//           );
//         }
//         Utils.showToast(Get.context!, data);
//       }
//
//       /// if Invalid callerRole or receiverRole  or Caller, Receiver, or CallHistory not found then listen also in coinDeductionError
//       static void handleCallCoinsDeducted(dynamic data) {
//         Utils.showLog("Socket Listen => callCoinsDeducted: $data");
//         Utils.showToast(Get.context!, data['message']);
//         if (Get.isRegistered<VideoCallController>()) {
//           final videoCallController = Get.find<VideoCallController>();
//
//           SocketEmit.emitCallTerminated(
//             callerId: videoCallController.callerId.toString(),
//             receiverId: videoCallController.receiverId.toString(),
//             callId: videoCallController.callId.toString(),
//             callType: videoCallController.callType.toString(),
//             callMode: videoCallController.callMode.toString(),
//             callerRole: videoCallController.callerRole.toString(),
//             receiverRole: videoCallController.receiverRole.toString(),
//             receiverName: videoCallController.receiverName.toString(),
//             receiverImage: videoCallController.receiverImage.toString(),
//           );
//         }
//       }
//
//       /// call cut data listen this event
//       static void handleCallCutData(dynamic data) {
//         try {
//           Utils.showLog("Socket Listen => callCutData: $data");
//
//           // Inject if not already present
//           if (!Get.isRegistered<CallCutController>()) {
//             Get.put(CallCutController());
//           }
//
//           Get.find<CallCutController>().setCallCutData(data);
//         } catch (e, st) {
//           Utils.showLog("❌ Error in handleCallCutData: $e\n$st");
//         }
//       }
//     }
//
//     class CallCutDataStorage {
//       static String? callId;
//       static String? date;
//       static String? balanceUsed;
//       static String? duration;
//     }
import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:proximity_screen_lock/proximity_screen_lock.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/socket/socket_service.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/api/host_coin_api.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/controller/host_home_screen_controller.dart';
import 'package:talk_in/ui/host_flow/host_home_screen/model/listener_coin_model.dart';
import 'package:talk_in/ui/host_flow/host_personal_chat_screen/controller/host_personal_chat_screen_controller.dart';
import 'package:talk_in/ui/host_flow/host_personal_chat_screen/model/host_personal_chat_model.dart';
import 'package:talk_in/ui/user_flow/call_cut_screen/controller/call_cut_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/api/user_coin_api.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/user_coin_model.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/controller/personal_chat_screen_controller.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/model/personal_chat_model.dart';
import 'package:talk_in/ui/user_flow/video_call_screen/controller/video_call_controller.dart';
import 'package:talk_in/ui/user_flow/voice_call_screen/controller/voice_call_controller.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/socket_events.dart';
import 'package:talk_in/utils/socket_params.dart';
import 'package:talk_in/utils/utils.dart';

import '../services/notification_service/notification_services.dart';

class SocketListen {
  static final Map<String, String> _latestMessageIdPerChat = {};
  static Timer? _seenEmitTimer;
  static bool _listenersRegistered = false;

  // ─────────────────────────────────────────────────────────────
  // NEW: dedup guards for call-lifecycle events that must only be
  // acted on once per callId. The server/socket transport can
  // redeliver events (commonly around a reconnect), and without
  // these guards a duplicate `callAnswered` causes a second
  // Get.back() + Get.toNamed(voiceCallScreen)/videoCallScreen,
  // which creates a second call controller mid-setup of the first
  // one — leaking timers/ZEGO sessions or breaking the call.
  // ─────────────────────────────────────────────────────────────
  static String? _lastHandledAnsweredCallId;
  static String? _lastHandledTerminatedCallId;

  static void registerListeners() {
    if (socket == null) return;

    // Prevent duplicate registration
    if (_listenersRegistered) {
      Utils.showLog("Socket listeners already registered.");
      return;
    }

    _listenersRegistered = true;

    Utils.showLog("Registering socket listeners...");

    // Remove existing listeners (safe even if none exist)
    socket!
      ..off(SocketEvents.sendMessage)
      ..off(SocketEvents.markMessageSeen)
      ..off(SocketEvents.callOutgoingRinging)
      ..off(SocketEvents.outGoingCall)
      ..off(SocketEvents.incomingCall)
      ..off(SocketEvents.callResponseProcessed)
      ..off(SocketEvents.callDeclined)
      ..off(SocketEvents.callAnswered)
      ..off(SocketEvents.callTimedOut)
      ..off(SocketEvents.callEnded)
      ..off(SocketEvents.callerCallCut)
      ..off(SocketEvents.callTerminated)
      ..off(SocketEvents.randomCallRinging)
      ..off(SocketEvents.notEnoughCoins)
      ..off(SocketEvents.callCoinsDeducted)
      ..off(SocketEvents.callCutData);

    // Register listeners
    socket!
      ..on(SocketEvents.sendMessage, handleSendMessage)
      ..on(SocketEvents.markMessageSeen, handleMarkMessageSeen)
      ..on(SocketEvents.callOutgoingRinging, handleCallOutgoingRinging)
      ..on(SocketEvents.outGoingCall, handleOutGoingCall)
      ..on(SocketEvents.incomingCall, handleIncomingCall)
      ..on(SocketEvents.callResponseProcessed, handleCallResponseProcessed)
      ..on(SocketEvents.callDeclined, handleCallDeclined)
      ..on(SocketEvents.callAnswered, handleCallAnswered)
      ..on(SocketEvents.callTimedOut, handleCallTimedOut)
      ..on(SocketEvents.callEnded, handleCallEnded)
      ..on(SocketEvents.callerCallCut, handleCallRejected)
      ..on(SocketEvents.callTerminated, handleCallTerminated)
      ..on(SocketEvents.randomCallRinging, handleRandomCallRinging)
      ..on(SocketEvents.notEnoughCoins, handleNotEnoughCoins)
      ..on(SocketEvents.callCoinsDeducted, handleCallCoinsDeducted)
      ..on(SocketEvents.callCutData, handleCallCutData);

    // Optional: Log reconnects
    socket!.on("connect", (_) {
      Utils.showLog("Socket connected: ${socket!.id}");
    });

    socket!.on("disconnect", (_) {
      Utils.showLog("Socket disconnected");
    });

    Utils.showLog("Socket listeners registered successfully.");
  }

  static void handleSendMessage(dynamic message) {
    Utils.showLog("Received messageDispatched: $message");

    try {
      final Map<String, dynamic> data = message['data'];
      final String chatTopicId = data['chatTopicId'] ?? '';

      if (Get.isRegistered<HostPersonalChatScreenController>()) {
        final hostController = Get.find<HostPersonalChatScreenController>();
        if (chatTopicId == hostController.chatTopicId) {
          final newMsg = ListenerChat.fromJson(data);

          if (data["senderId"] == Database.fetchListenerProfileModel?.data?.id && data['messageType'] == 3) {
            hostController.oldChatListener.removeAt(0);
          }

          hostController.isLoadingAudio = false;
          hostController.update([Constant.idGetOldChat]);

          final index = hostController.oldChatListener.indexWhere(
                  (msg) => msg.senderId == Database.loginUserId && msg.message == newMsg.message && msg.id?.length == 13);

          if (index != -1) {
            hostController.oldChatListener[index] = newMsg;
          } else {
            hostController.oldChatListener.insert(0, newMsg);
          }

          hostController.onScrollDown();
          hostController.update([Constant.idGetOldChat]);

          if (Get.currentRoute == AppRoutes.hostPersonalChatScreen || Get.currentRoute == AppRoutes.personalChatScreen) {
            final String messageId = message['messageId'];

            if (data["senderId"] != Database.fetchListenerProfileModel?.data?.id &&
                data['receiverId'] == Database.fetchListenerProfileModel?.data?.id) {
              _latestMessageIdPerChat[chatTopicId] = messageId;

              _seenEmitTimer?.cancel();

              _seenEmitTimer = Timer(const Duration(milliseconds: 500), () {
                final latestMsgId = _latestMessageIdPerChat[chatTopicId];
                if (latestMsgId != null) {
                  Utils.showLog("🔥 Emitting seen for last messageId: $latestMsgId");

                  SocketEmit.onMessageSeen({
                    SocketParams.messageId: latestMsgId,
                    SocketParams.senderId: data["senderId"],
                  });

                  _latestMessageIdPerChat.remove(chatTopicId);
                }
              });
            } else {
              Utils.showLog("Message not for current user");
            }
          }
          return;
        }
      }

      if (Get.isRegistered<PersonalChatScreenController>()) {
        final userController = Get.find<PersonalChatScreenController>();
        if (chatTopicId == userController.chatTopicId) {
          final newMsg = PersonalChat.fromJson(data);

          if (data["senderId"] == Database.loginUserId && data['messageType'] == 3) {
            userController.oldChat.removeAt(0);
          }

          userController.isLoadingAudio = false;
          userController.update([Constant.idGetOldChat]);

          final index = userController.oldChat.indexWhere(
                  (msg) => msg.senderId == Database.loginUserId && msg.message == newMsg.message && msg.id?.length == 13);

          if (index != -1) {
            userController.oldChat[index] = newMsg;
          } else {
            userController.oldChat.insert(0, newMsg);
          }

          userController.onScrollDown();
          userController.update([Constant.idGetOldChat]);

          if (Get.currentRoute == AppRoutes.hostPersonalChatScreen || Get.currentRoute == AppRoutes.personalChatScreen) {
            final String messageId = message['messageId'];

            if (data["senderId"] != Database.fetchLoginUserProfileModel?.user?.id &&
                data['receiverId'] == Database.fetchLoginUserProfileModel?.user?.id) {
              _latestMessageIdPerChat[chatTopicId] = messageId;

              _seenEmitTimer?.cancel();

              _seenEmitTimer = Timer(const Duration(milliseconds: 500), () {
                final latestMsgId = _latestMessageIdPerChat[chatTopicId];
                if (latestMsgId != null) {
                  Utils.showLog("🔥 Emitting seen for last messageId: $latestMsgId");

                  SocketEmit.onMessageSeen({
                    SocketParams.messageId: latestMsgId,
                    SocketParams.senderId: data["senderId"],
                  });

                  _latestMessageIdPerChat.remove(chatTopicId);
                }
              });
            } else {
              Utils.showLog("Message not for current user");
            }
          }

          return;
        }
      }

      Utils.showLog(" Message not for current chat topic");
    } catch (e) {
      Utils.showLog(" Error parsing socket message: $e");
    }
  }

  static void handleMarkMessageSeen(dynamic data) {
    Utils.showLog("Received markMessageSeen: $data");
  }

  /// when caller call then caller this event listen
  static void handleOutGoingCall(dynamic data) {
    Get.back();
    Utils.showLog("Socket Listen => callEstablished event: $data");
    if (data['callType'] == "audio") {
      Get.toNamed(AppRoutes.outgoingAudioCallScreen, arguments: data);
    } else {
      Get.toNamed(AppRoutes.outgoingCallScreen, arguments: data);
    }
  }

  /// when caller call then receiver this event listen
  static Future<void> handleIncomingCall(dynamic data) async {
    Utils.showLog("Socket Listen => incomingCall event: $data");

    Get.toNamed(AppRoutes.incomingCallScreen, arguments: data);
  }

  /// If any error like busy, caller or receiver not found then listen always in callOutgoingRinging event
  static void handleCallOutgoingRinging(dynamic data) {
    Utils.showLog("Socket Listen => callOutgoingRinging (error or status): $data");
    Utils.showToast(Get.context!, data['message']);
  }

  /// receiver call cut listen this event
  static void handleCallDeclined(dynamic data) {
    Utils.showLog("Socket Listen => callDeclined event: $data");
    if (Get.currentRoute == AppRoutes.outgoingCallScreen ||
        Get.currentRoute == AppRoutes.incomingCallScreen ||
        Get.currentRoute == AppRoutes.outgoingAudioCallScreen) {
      log(" <<<<<<<<<<<<<<<<<<<<<<<<< ${Get.currentRoute}");
      Get.back();
    }
  }
  static final Map<String, DateTime> _handledAnsweredCallIds = {};
  static const _dedupWindow = Duration(seconds: 3);

  static void handleCallAnswered(dynamic data) {
    final String? callId = data['callId']?.toString();

    if (callId != null) {
      final lastHandled = _handledAnsweredCallIds[callId];
      if (lastHandled != null && DateTime.now().difference(lastHandled) < _dedupWindow) {
        Utils.showLog("⚠️ Duplicate callAnswered event for callId=$callId — ignoring.");
        return;
      }
    }

    NotificationServices.dismissCallNotification();
    Utils.showLog("Socket Listen => callAnswered event: $data");

    try {
      if (data['callType'] == "audio") {
        Get.offNamed(AppRoutes.voiceCallScreen, arguments: {
          "callerId": data['callerId'],
          "receiverId": data['receiverId'],
          "callType": data['callType'],
          "callerRole": data['callerRole'],
          "receiverRole": data['receiverRole'],
          "callId": data['callId'],
          "receiverName": data['receiverName'],
          "callerfullName": data['callerfullName'],
          "receiverImage": data['receiverImage'],
          "callerImage": data['callerImage'],
          "isAccept": data['isAccept'],
          "callMode": data['callMode'],
        });
      } else {
        Get.offNamed(AppRoutes.videoCallScreen, arguments: data);
      }

      // ✅ Only mark as handled AFTER navigation actually succeeded —
      // so a genuinely failed first attempt can still be retried by
      // a redelivered event instead of being permanently dropped.
      if (callId != null) {
        _handledAnsweredCallIds[callId] = DateTime.now();
      }
    } catch (e, st) {
      Utils.showLog("❌ handleCallAnswered navigation failed, NOT marking as handled: $e\n$st");
      // deliberately don't set the dedup entry — allow retry
    }
  }

  // Call this from handleCallEnded / handleCallTerminated so the map
  // doesn't grow forever and so a callId is fully released once the
  // call is actually over.
  static void _clearAnsweredDedup(String? callId) {
    if (callId != null) _handledAnsweredCallIds.remove(callId);
  }
  /// caller call and receiver call answer then this event listen
  // static void handleCallAnswered(dynamic data) {
  //   final String? callId = data['callId']?.toString();
  //
  //   // ✅ Dedup guard: the server/socket transport can deliver this event
  //   // twice for the same call (e.g. around a reconnect). Without this,
  //   // each duplicate causes a second Get.back() + Get.toNamed(voiceCallScreen),
  //   // which creates and immediately disposes a second call controller
  //   // mid-setup — leaking timers/coins or breaking the call entirely.
  //   if (callId != null && callId == _lastHandledAnsweredCallId) {
  //     Utils.showLog("⚠️ Duplicate callAnswered event for callId=$callId — ignoring.");
  //     return;
  //   }
  //   _lastHandledAnsweredCallId = callId;
  //
  //   NotificationServices.dismissCallNotification();
  //   Utils.showLog("Socket Listen => callAnswered event: $data");
  //   Get.back();
  //
  //   Utils.showLog("ooooooooooooooooooooooooooo");
  //
  //   if (data['callType'] == "audio") {
  //     Utils.showLog("vvvvvvvvvvvvvvvvvvvvvvvvvv");
  //
  //     Get.toNamed(AppRoutes.voiceCallScreen, arguments: {
  //       "callerId": data['callerId'],
  //       "receiverId": data['receiverId'],
  //       "callType": data['callType'],
  //       "callerRole": data['callerRole'],
  //       "receiverRole": data['receiverRole'],
  //       "callId": data['callId'],
  //       "receiverName": data['receiverName'],
  //       "callerfullName": data['callerfullName'],
  //       "receiverImage": data['receiverImage'],
  //       "callerImage": data['callerImage'],
  //       "isAccept": data['isAccept'],
  //       "callMode": data['callMode'],
  //     });
  //   } else {
  //     Get.toNamed(AppRoutes.videoCallScreen, arguments: data);
  //   }
  // }

  /// when caller call then Invalid caller, receiver, or call history then listen this event
  static void handleCallResponseProcessed(dynamic data) {
    Utils.showLog("Socket Listen => callResponseProcessed event: $data");
    Utils.showToast(Get.context!, data['message']);
  }

  /// if callId not match then listen also in callTimedOut ( to receiver )
  static void handleCallTimedOut(dynamic data) {
    Utils.showLog("Socket Listen => callTimedOut event: $data");
    if (Get.isRegistered<VideoCallController>()) {
      final videoCallController = Get.find<VideoCallController>();

      SocketEmit.emitCallTerminated(
        callerId: videoCallController.callerId.toString(),
        receiverId: videoCallController.receiverId.toString(),
        callId: videoCallController.callId.toString(),
        callType: videoCallController.callType.toString(),
        callMode: videoCallController.callMode.toString(),
        callerRole: videoCallController.callerRole.toString(),
        receiverRole: videoCallController.receiverRole.toString(),
        receiverName: videoCallController.receiverName.toString(),
        receiverImage: videoCallController.receiverImage.toString(),
      );
    }
  }

  /// when caller cut call then this event listen
  static void handleCallEnded(dynamic data) {
    Utils.showLog("Socket Listen => callEnded event: $data");
    // Dismiss call notification
    NotificationServices.dismissCallNotification();

    if (Get.currentRoute == AppRoutes.incomingCallScreen) {
      log("***************************${Get.currentRoute == AppRoutes.incomingCallScreen}");
      Get.back();
    }
  }

  /// if Invalid caller, receiver, or call history then listen also in callRejected event
  static void handleCallRejected(dynamic data) {
    Utils.showLog("Socket Listen => callRejected event: $data");
  }

  /// both join call and then cut call this event listen
  static Future<void> handleCallTerminated(dynamic data) async {
    final String? callId = data['callId']?.toString();

    // ✅ Dedup guard: same rationale as handleCallAnswered above — a
    // redelivered callTerminated should not run the whole teardown +
    // coin-refresh + navigation flow twice for the same call.
    if (callId != null && callId == _lastHandledTerminatedCallId) {
      Utils.showLog("⚠️ Duplicate callTerminated event for callId=$callId — ignoring.");
      return;
    }
    _lastHandledTerminatedCallId = callId;

    UserCoinModel? userCoinModel;
    ListenerCoinModel? listenerCoinModel;
    Utils.showLog("Socket Listen => callTerminated event: $data");
    VoiceCallController? controller;
    if (Get.currentRoute == AppRoutes.voiceCallScreen && Get.isRegistered<VoiceCallController>()) {
      controller = Get.find<VoiceCallController>();
    } else {
      log("⚠️ VoiceCallController not registered, skipping cleanup.");
    }
    final callerRole = data['callerRole'];
    final callMode = data['callMode'];

    // ✅ First, properly cleanup proximity sensor and screen lock
    try {
      await ProximityScreenLock.setActive(false);
      controller?.isProximitySupported = false;
      controller?.isObjectNear = false;
      controller?.userEnabledSpeaker = false;
      log("✅ Proximity sensor deactivated and screen unlocked  userEnabledSpeaker = ${controller?.userEnabledSpeaker} isObjectNear = ${controller?.isObjectNear} isProximitySupported = ${controller?.isProximitySupported}");
    } catch (e) {
      log("❌ Error deactivating proximity sensor: $e");
    }

    if (Database.fetchLoginUserProfileModel?.user?.isListener == false && callMode == "random") {
      if (Get.currentRoute == AppRoutes.videoCallScreen || Get.currentRoute == AppRoutes.voiceCallScreen) {
        Get.back();
      }

      log("is listener ${Database.fetchLoginUserProfileModel?.user?.isListener}");
      log("call mode  $callMode");
    } else {
      if (Get.currentRoute == AppRoutes.videoCallScreen || Get.currentRoute == AppRoutes.voiceCallScreen) {
        Get.back();
      }
    }

    if (Database.fetchLoginUserProfileModel?.user?.isListener == false && callerRole == "user") {
      Get.toNamed(AppRoutes.callCutScreen, arguments: data);
    }

    userCoinModel = await UserCoinApi.callApi();
    Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");

    print("user coin listen ::::::::::::::::::${userCoinModel?.coin}");
    print("user coin listen ::::::::::::::::::${Database.userCoin}");

    if (Get.isRegistered<HostHomeScreenController>()) {
      final hostHomeScreenController = Get.find<HostHomeScreenController>();
      hostHomeScreenController.isCoinLoading = true;
      hostHomeScreenController.update([Constant.idCoinUpdate]);
      listenerCoinModel = await HostCoinApi.callApi();
      Database.onSetListenerCoin(listenerCoinModel!.coin.toString());
      hostHomeScreenController.isCoinLoading = false;
      hostHomeScreenController.update([Constant.idCoinUpdate]);
    }

    if (Get.isRegistered<HomeScreenController>()) {
      Get.find<HomeScreenController>().update([Constant.idCoinUpdate]);
    }
  }

  /// random call If any error like busy, caller or receiver not found then listen always in incomingRingingStarted event
  static void handleRandomCallRinging(dynamic data) {
    Utils.showLog("Socket Listen => random call incomingRingingStarted (error or status): $data");
    Utils.showToast(Get.context!, data['message']);
  }

  static void handleNotEnoughCoins(dynamic data) {
    Utils.showLog("Socket Listen => handleNotEnoughCoins: $data");
    if (Get.isRegistered<VideoCallController>()) {
      final videoCallController = Get.find<VideoCallController>();

      SocketEmit.emitCallTerminated(
        callerId: videoCallController.callerId.toString(),
        receiverId: videoCallController.receiverId.toString(),
        callId: videoCallController.callId.toString(),
        callType: videoCallController.callType.toString(),
        callMode: videoCallController.callMode.toString(),
        callerRole: videoCallController.callerRole.toString(),
        receiverRole: videoCallController.receiverRole.toString(),
        receiverName: videoCallController.receiverName.toString(),
        receiverImage: videoCallController.receiverImage.toString(),
      );
    }
    if (Get.isRegistered<VoiceCallController>()) {
      final voiceCallController = Get.find<VoiceCallController>();

      SocketEmit.emitCallTerminated(
        callerId: voiceCallController.callerId.toString(),
        receiverId: voiceCallController.receiverId.toString(),
        callId: voiceCallController.callId.toString(),
        callType: voiceCallController.callType.toString(),
        callMode: voiceCallController.callMode.toString(),
        callerRole: voiceCallController.callerRole.toString(),
        receiverRole: voiceCallController.receiverRole.toString(),
        receiverName: voiceCallController.receiverName.toString(),
        receiverImage: voiceCallController.receiverImage.toString(),
      );
    }
    Utils.showToast(Get.context!, data);
  }

  /// if Invalid callerRole or receiverRole  or Caller, Receiver, or CallHistory not found then listen also in coinDeductionError
  static void handleCallCoinsDeducted(dynamic data) {
    Utils.showLog("Socket Listen => callCoinsDeducted: $data");
    Utils.showToast(Get.context!, data['message']);
    if (Get.isRegistered<VideoCallController>()) {
      final videoCallController = Get.find<VideoCallController>();

      SocketEmit.emitCallTerminated(
        callerId: videoCallController.callerId.toString(),
        receiverId: videoCallController.receiverId.toString(),
        callId: videoCallController.callId.toString(),
        callType: videoCallController.callType.toString(),
        callMode: videoCallController.callMode.toString(),
        callerRole: videoCallController.callerRole.toString(),
        receiverRole: videoCallController.receiverRole.toString(),
        receiverName: videoCallController.receiverName.toString(),
        receiverImage: videoCallController.receiverImage.toString(),
      );
    }
  }

  /// call cut data listen this event
  static void handleCallCutData(dynamic data) {
    try {
      Utils.showLog("Socket Listen => callCutData: $data");

      // Inject if not already present
      if (!Get.isRegistered<CallCutController>()) {
        Get.put(CallCutController());
      }

      Get.find<CallCutController>().setCallCutData(data);
    } catch (e, st) {
      Utils.showLog("❌ Error in handleCallCutData: $e\n$st");
    }
  }
}

class CallCutDataStorage {
  static String? callId;
  static String? date;
  static String? balanceUsed;
  static String? duration;
}