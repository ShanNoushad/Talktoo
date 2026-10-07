import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/ringtone/ringtone_method.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/utils.dart';
import 'package:vibration/vibration.dart';

import '../../../../services/notification_service/notification_services.dart';
import '../../../../socket/socket_service.dart';


class IncomingCallController extends GetxController with WidgetsBindingObserver {
  late Map<String, dynamic> args;

  String? callerId;
  String? receiverId;
  String? callerImage;
  String? callerName;
  String? receiverName;
  String? receiverImage;
  String? callId;
  String? receiverRole;
  String? callType;
  String? callMode;
  String? callerRole;

  bool isCallResponse = false;
  AudioPlayer audioPlayer = AudioPlayer();
  Timer? vibrationTimer;
  Timer? ringingTimer;

  // ✅ Add these flags to prevent multiple plays
  bool _isAudioPlaying = false;
  bool _isDisposed = false;

  @override
  void onInit() async {
    super.onInit();

    _isDisposed = false;
    args = Get.arguments as Map<String, dynamic>;
    getDataFromArgs();

    // ✅ Setup audio player first
    await _setupAudioPlayer();

    // ✅ Then start everything
    await onPlayAudio();
    onStartVibration();
    onStartRingingTimer();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    _isDisposed = true;

    // ✅ Cancel timers first
    vibrationTimer?.cancel();
    ringingTimer?.cancel();
    vibrationTimer = null;
    ringingTimer = null;

    // ✅ Stop audio properly
    onPauseAudio();

    // ✅ Dispose audio player
    audioPlayer.dispose();

    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // ✅ Setup audio player with proper configuration
  Future<void> _setupAudioPlayer() async {
    try {
      // Set release mode to loop for continuous ringing
      await audioPlayer.setReleaseMode(ReleaseMode.loop);

      // Set volume to maximum
      await audioPlayer.setVolume(1.0);

      // Set audio context for ringtone (Android specific)
      if (Platform.isAndroid) {
        await audioPlayer.setAudioContext(
          AudioContext(
            android: AudioContextAndroid(
              isSpeakerphoneOn: true,
              stayAwake: true,
              contentType: AndroidContentType.sonification,
              usageType: AndroidUsageType.notificationRingtone,
              audioFocus: AndroidAudioFocus.gain,
            ),
          ),
        );
      }

      Utils.showLog("Audio player setup completed");
    } catch (e) {
      Utils.showLog("Audio player setup error: $e");
    }
  }

  getDataFromArgs() {
    callerId = args['callerId'];
    receiverId = args['receiverId'];
    callerImage = args['callerImage'];
    callerName = args['callerfullName'] ?? args['callernickName'];
    receiverName = args['receiverName'];
    receiverImage = args['receiverImage'];
    callId = args['callId'];
    receiverRole = args['receiverRole'];
    callMode = args['callMode'];
    callType = args['callType'];
    callerRole = args['callerRole'];

    log("callerId :: $callerId");
    log("receiverId :: $receiverId");
    log("callerImage :: $callerImage");
    log("callerName :: $callerName");
    log("receiverName :: $receiverName");
    log("receiverImage $receiverImage");
    log("callId :: $callId");
    log("receiverRole :: $receiverRole");
    log("callMode :: $callMode");
    log("callType :: $callType");
    log("callerRole :: $callerRole");
  }

  @override
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Utils.showLog("User Back To App...");

      // ✅ Force immediate socket reconnect — don't wait on backoff
      if (socket != null && !socket!.connected) {
        SocketService.socketConnect();
      } else {
        SocketService.ensureConnected();
      }

      if (Get.currentRoute == AppRoutes.incomingCallScreen && !_isAudioPlaying) {
        onPlayAudio();
      }
    }
    if (state == AppLifecycleState.paused) {
      Utils.showLog("User Minimized App...");
    }
    if (state == AppLifecycleState.inactive) {
      Utils.showLog("User Try To Exit...");
    }
  }
  void onStartVibration() {
    // ✅ Cancel existing timer before creating new one
    vibrationTimer?.cancel();

    vibrationTimer = Timer.periodic(
      Duration(milliseconds: 1000), // ✅ Changed to 1 second interval
      (timer) {
        if (_isDisposed) {
          timer.cancel();
          return;
        }
        Vibration.vibrate(duration: 500, amplitude: 200); // ✅ Longer vibration
      },
    );
  }

  Future<void> onPlayAudio() async {
    if (_isAudioPlaying || _isDisposed) {
      Utils.showLog("Audio already playing or controller disposed");
      return;
    }

    try {
      // ✅ Stop any existing playback first
      await audioPlayer.stop();

      _isAudioPlaying = true;

      // ✅ Play from asset with proper error handling
      await audioPlayer.play(
        AssetSource(AppAsset.ringTone),
        volume: 1.0,
      );

      Utils.showLog("Audio playback started successfully");

      // ✅ Also use RingtoneService as backup
      try {
        RingtoneService.playRingtone();
      } catch (e) {
        Utils.showLog("RingtoneService error (non-critical): $e");
      }

      // ✅ Listen for completion (in case loop fails)
      audioPlayer.onPlayerComplete.listen((event) {
        if (!_isDisposed && Get.currentRoute == AppRoutes.incomingCallScreen) {
          Utils.showLog("Audio completed, restarting...");
          _isAudioPlaying = false;
          onPlayAudio(); // Restart if still on incoming call screen
        }
      });
    } catch (e) {
      _isAudioPlaying = false;
      Utils.showLog("Audio Play Failed !! => $e");

      // ✅ Fallback to RingtoneService only
      try {
        RingtoneService.playRingtone();
      } catch (e2) {
        Utils.showLog("RingtoneService fallback also failed: $e2");
      }
    }
  }

  Future<void> onPauseAudio() async {
    if (!_isAudioPlaying && !_isDisposed) {
      return;
    }

    try {
      _isAudioPlaying = false;

      // ✅ Stop instead of pause for cleaner shutdown
      await audioPlayer.stop();

      Utils.showLog("Audio stopped successfully");
    } catch (e) {
      Utils.showLog("Audio Stop Error => $e");
    }

    // ✅ Always try to stop RingtoneService
    try {
      RingtoneService.stopRingtone();
    } catch (e) {
      Utils.showLog("RingtoneService stop error (non-critical): $e");
    }
  }

  void onStartRingingTimer() {
    // ✅ Cancel existing timer before creating new one
    ringingTimer?.cancel();

    ringingTimer = Timer(
      Duration(seconds: 30), // ✅ 30 seconds auto-decline
      () async {
        if (_isDisposed) return;

        if (Get.currentRoute == AppRoutes.incomingCallScreen) {
          Utils.showLog("Call Auto Decline - Timeout reached");
          await onCallDecline();

          // ✅ Safe navigation check
          if (Get.isRegistered<IncomingCallController>()) {
            Get.back();
          }
        }
      },
    );
  }

  Future<void> onCallDecline() async {
    // ✅ Prevent multiple declines
    if (isCallResponse) {
      Utils.showLog("Call already responded to");
      return;
    }

    try {
      // ✅ Stop audio and vibration immediately
      await onPauseAudio();
      vibrationTimer?.cancel();
      ringingTimer?.cancel();

      // ✅ Dismiss the FCM/system call notification — stopping this
      // screen's own AudioPlayer above does NOT stop the separate
      // OS-level notification (with its own ringtone via
      // soundSource: 'resource://raw/ringtone'), so it keeps ringing
      // until explicitly cancelled here.
      await NotificationServices.dismissCallNotification();

      // ✅ Haptic feedback
      Vibration.vibrate(duration: 50, amplitude: 128);
      await 50.milliseconds.delay();

      isCallResponse = true;

      // ✅ Simplified role check
      final isUserCaller = callerRole == "user";

      SocketEmit.emitCallResponseProcessed(
        callerId: callerId ?? '',
        receiverId: receiverId ?? '',
        callId: callId ?? '',
        isAccept: false,
        callType: callType ?? '',
        callMode: callMode ?? '',
        callerRole: isUserCaller ? 'user' : 'listener',
        receiverRole: isUserCaller ? 'listener' : 'user',
        receiverName: receiverName ?? '',
        receiverImage: receiverImage ?? '',
        callerName: callerName ?? '',
        callerImage: callerImage ?? '',
      );

      Utils.showLog("Call decline emit event sent");
    } catch (e) {
      Utils.showLog("Error in onCallDecline: $e");
    }
  }
  // ✅ Add method for accepting call
  Future<void> onCallAccept() async {
    // ✅ Prevent multiple accepts
    if (isCallResponse) {
      Utils.showLog("Call already responded to");
      return;
    }

    try {
      // ✅ Stop audio and vibration immediately
      await onPauseAudio();
      vibrationTimer?.cancel();
      ringingTimer?.cancel();

      // ✅ Dismiss the FCM/system call notification — stopping this
      // screen's own AudioPlayer above does NOT stop the separate
      // OS-level notification (with its own ringtone via
      // soundSource: 'resource://raw/ringtone'), so it keeps ringing
      // until explicitly cancelled here.
      await NotificationServices.dismissCallNotification();

      // ✅ Haptic feedback
      Vibration.vibrate(duration: 50, amplitude: 128);
      await 50.milliseconds.delay();

      isCallResponse = true;

      final isUserCaller = callerRole == "user";

      SocketEmit.emitCallResponseProcessed(
        callerId: callerId ?? '',
        receiverId: receiverId ?? '',
        callId: callId ?? '',
        isAccept: true, // ✅ Accept = true
        callType: callType ?? '',
        callMode: callMode ?? '',
        callerRole: isUserCaller ? 'user' : 'listener',
        receiverRole: isUserCaller ? 'listener' : 'user',
        receiverName: receiverName ?? '',
        receiverImage: receiverImage ?? '',
        callerName: callerName ?? '',
        callerImage: callerImage ?? '',
      );

      Utils.showLog("Call accept emit event sent");

      // ✅ Navigate to call screen
      // Add your navigation logic here
    } catch (e) {
      Utils.showLog("Error in onCallAccept: $e");
    }
  }}
