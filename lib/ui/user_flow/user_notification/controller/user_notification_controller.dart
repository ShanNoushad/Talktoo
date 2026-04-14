import 'dart:developer';

import 'package:flutter/cupertino.dart' hide Notification;
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/user_notification/api/notification_clear_api.dart';
import 'package:talk_in/ui/user_flow/user_notification/api/user_notification_api.dart';
import 'package:talk_in/ui/user_flow/user_notification/model/user_notification_clear_model.dart';
import 'package:talk_in/ui/user_flow/user_notification/model/user_notification_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/utils.dart';

class UserNotificationController extends GetxController {
  bool isLoading = false;
  UserNotificationModel? userNotificationModel;
  NotificationClearModel? notificationClearModel;
  List<Notification> notificationList = [];
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
    UserNotificationApi.startPagination = 1;
    notificationList.clear();
    update([Constant.idUserNotification]);

    await _fetchNotifications(isPagination: false);

    isLoading = false;
    update([Constant.idUserNotification]);
  }

  Future<void> _fetchNotifications({required bool isPagination}) async {
    try {
      final result = await UserNotificationApi.callApi();
      final fetchedList = result?.notification ?? [];

      if (fetchedList.isEmpty) {
        hasMoreData = false;
        return;
      }

      notificationList.addAll(fetchedList);
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

  /// get user notification
  Future<void> getNotificationUser() async {
    isLoading = true;
    update([Constant.idUserNotification]);

    try {
      userNotificationModel = await UserNotificationApi.callApi();
      notificationList.clear();
      notificationList.addAll(userNotificationModel?.notification ?? []);
    } catch (e) {
      Utils.showToast(Get.context!, "Failed to fetch notifications.");
    } finally {
      isLoading = false;
      update([Constant.idUserNotification]);
    }
  }

  /// clear user notification
  Future<void> clearNotificationUser() async {
    isLoading = true;
    update([Constant.idUserNotification]);

    try {
      notificationClearModel = await NotificationClearApi.callApi();

      if (notificationClearModel?.status == true) {
        notificationList.clear(); // Clear UI list immediately
        update([Constant.idUserNotification]);

        await getNotificationUser(); // Ensure this completes after clear

        Utils.showToast(
          Get.context!,
          notificationClearModel?.message ?? "Notification history cleared.",
        );
      } else {
        Utils.showToast(
          Get.context!,
          notificationClearModel?.message ?? "Notification history not found.",
        );
      }
    } catch (e) {
      Utils.showToast(Get.context!, "Failed to clear notifications.");
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
