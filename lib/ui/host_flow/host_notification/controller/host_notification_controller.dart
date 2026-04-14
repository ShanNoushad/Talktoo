import 'dart:developer';

import 'package:flutter/cupertino.dart' hide Notification;
import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_notification/api/host_notification_api.dart';
import 'package:talk_in/ui/host_flow/host_notification/api/host_notification_clear_api.dart';
import 'package:talk_in/ui/host_flow/host_notification/model/host_notification_clear_model.dart';
import 'package:talk_in/ui/host_flow/host_notification/model/host_notification_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/utils.dart';

class HostNotificationController extends GetxController {
  bool isLoading = false;
  HostNotificationModel? hostNotificationModel;
  HostNotificationClearModel? hostNotificationClearModel;
  List<Notification> hostNotificationList = [];
  ScrollController scrollController = ScrollController();
  bool isPaginationLoading = false;
  bool hasMoreData = true; // stop pagination

  @override
  void onInit() {
    scrollController.addListener(_paginationListener);
    _initialLoad();
    super.onInit();
  }

  /// First load / refresh
  Future<void> _initialLoad() async {
    isLoading = true;
    hasMoreData = true;
    HostNotificationApi.startPagination = 1;
    hostNotificationList.clear();
    update([Constant.idUserNotification]);

    await _fetchNotifications(isPagination: false);

    isLoading = false;
    update([Constant.idUserNotification]);
  }

  Future<void> _fetchNotifications({required bool isPagination}) async {
    try {
      final result = await HostNotificationApi.callApi();
      final fetchedList = result?.notification ?? [];

      if (fetchedList.isEmpty) {
        hasMoreData = false;
        return;
      }

      hostNotificationList.addAll(fetchedList);
    } catch (e) {
      log("Notification error => $e");
    }
  }

  Future<void> _paginationListener() async {
    if (!hasMoreData || isPaginationLoading || isLoading) return;

    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100) {
      isPaginationLoading = true;
      update([Constant.idPaginationListener]);

      await _fetchNotifications(isPagination: true);

      isPaginationLoading = false;
      update([Constant.idPaginationListener]);
      update([Constant.idUserNotification]);
    }
  }

  /// get notification listener
  Future<void> getNotificationListener() async {
    isLoading = true;
    update([Constant.idUserNotification]);

    try {
      hostNotificationList.clear();

      hostNotificationModel = await HostNotificationApi.callApi();
      final fetchedList = hostNotificationModel?.notification ?? [];

      hostNotificationList.addAll(fetchedList);

      log("Fetched notifications: ${fetchedList.length}");
    } catch (e) {
      log("Error fetching notifications: $e");
      Utils.showToast(Get.context!, "Failed to fetch notifications.");
    } finally {
      isLoading = false;
      update([Constant.idUserNotification]);
    }
  }

  /// clear notification listener
  Future<void> clearNotificationListener() async {
    isLoading = true;
    update([Constant.idUserNotification]);

    try {
      hostNotificationClearModel = await HostNotificationClearApi.callApi();

      if (hostNotificationClearModel?.status == true) {
        hostNotificationList.clear(); // Clear UI immediately
        update([Constant.idUserNotification]);

        await getNotificationListener(); // Wait for fresh data

        Utils.showToast(
          Get.context!,
          hostNotificationClearModel?.message ?? "Notification history cleared.",
        );
      } else {
        Utils.showToast(
          Get.context!,
          hostNotificationClearModel?.message ?? "Notification history not found.",
        );
      }
    } catch (e) {
      Utils.showToast(Get.context!, "Error clearing notifications.");
      log("Clear error: $e");
    } finally {
      isLoading = false;
      update([Constant.idUserNotification]);
    }
  }

  /// refresh
  Future<void> onRefresh() async {
    await _initialLoad();
  }
}
