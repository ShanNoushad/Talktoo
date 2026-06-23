import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

io.Socket? socket;

class SocketService {
  io.Socket? getSocket() => socket;

  static Future<void> socketDisConnect() async {
    if (socket == null) return;
    Utils.showLog("Socket Disconnect requested : ${socket?.id}");
    socket?.disconnect();
  }

  static Future<void> socketConnect() async {
    log("listener id :::::: ${Database.fetchListenerProfileModel?.data?.id}");
    log("user id :::::: ${Database.loginUserId}");

    try {
      if (socket != null) {
        socket?.clearListeners();
        socket?.disconnect();
        socket?.dispose();
        socket = null;
      }

      socket = io.io(
        Api.baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setQuery({
          "globalRoom":
          "globalRoom:${Database.fetchLoginUserProfileModel?.user?.isListener == true ? Database.fetchListenerProfileModel?.data?.id : Database.loginUserId}"
        })
            .build(),
      );

      socket?.connect();

      socket?.onConnect((_) {
        Utils.showLog("✅ Socket Connected : ${socket?.id}");
      });

      socket?.onReconnect((_) {
        Utils.showLog("🔁 Socket Reconnected : ${socket?.id}");
      });

      socket?.onReconnectAttempt((attempt) {
        Utils.showLog("🔁 Socket Reconnect Attempt : $attempt");
      });

      socket?.onReconnectFailed((_) {
        Utils.showLog("❌ Socket Reconnect Failed after all attempts");
      });

      socket?.on("error", (error) {
        Utils.showLog("❌ Socket Error : $error");
      });

      socket?.on("connect_error", (error) {
        Utils.showLog("❌ Socket Connection Error : $error");
      });

      socket?.on("connect_timeout", (timeout) {
        Utils.showLog("❌ Socket Connection Timeout : $timeout");
      });

      socket?.onDisconnect((reason) {
        Utils.showLog("⚠️ Socket Disconnected : $reason");
      });

      Utils.showLog("Socket instance created. Connected: ${socket?.connected}");
    } catch (e) {
      Utils.showLog("❌ Socket Connection Exception: $e");
    }
  }

  static Future<void> ensureConnected() async {
    if (socket != null && socket!.connected) {
      Utils.showLog("✅ Socket already connected, skipping reconnect");
      return;
    }
    await socketConnect();
  }
}