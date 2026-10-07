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
  bool hasMoreData = true;

  int unreadCount = 0;
  static const String _lastSeenKey = "notification_last_seen_at";

  @override
  void onInit() {
    scrollController.addListener(_paginationListener);
    _initialLoad();
    super.onInit();
  }

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
    log("🔔 [_fetchNotifications] calling API... isPagination=$isPagination");
    try {
      final result = await UserNotificationApi.callApi();


      final fetchedList = result?.notification ?? [];

      if (fetchedList.isEmpty) {
        hasMoreData = false;
        return;
      }

      // ✅ log each item's id/createdAt so you can see if createdAt is null (breaks unread calc)
      for (final n in fetchedList) {
        log("🔔   -> id=${n.id}, title=${n.title}, createdAt=${n.createdAt}");
      }

      notificationList.addAll(fetchedList);
      _recalculateUnreadCount();
    } catch (e, stack) {
      log("❌ [_fetchNotifications] ERROR: $e");
      log("❌ [_fetchNotifications] STACK: $stack");
    }
  }

  void _recalculateUnreadCount() {
    final lastSeenMillis = Constant.storage.read(_lastSeenKey) as int?;
    final lastSeen = lastSeenMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(lastSeenMillis)
        : null;

    log("🔔 [_recalculateUnreadCount] lastSeenMillis=$lastSeenMillis, lastSeen=$lastSeen");

    if (lastSeen == null) {
      unreadCount = notificationList.where((n) => n.createdAt != null).length;
      log("🔔 [_recalculateUnreadCount] no lastSeen stored -> treating all as unread. Count with non-null createdAt: $unreadCount (out of ${notificationList.length} total)");
    } else {
      unreadCount = notificationList
          .where((n) => n.createdAt != null && n.createdAt!.isAfter(lastSeen))
          .length;
      log("🔔 [_recalculateUnreadCount] filtered by lastSeen -> unreadCount=$unreadCount");
    }

    log("🔔 [_recalculateUnreadCount] calling update([idNotificationBadge]) now. isRegistered=${Get.isRegistered<UserNotificationController>()}");
    update([Constant.idNotificationBadge]);
  }

  void markAllAsSeen() {
    log("🔔 [markAllAsSeen] clearing badge, writing timestamp");
    Constant.storage.write(_lastSeenKey, DateTime.now().millisecondsSinceEpoch);
    unreadCount = 0;
    update([Constant.idNotificationBadge]);
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

  Future<void> getNotificationUser() async {
    isLoading = true;
    update([Constant.idUserNotification]);

    try {
      userNotificationModel = await UserNotificationApi.callApi();
      log("🔔 [getNotificationUser] fetched ${userNotificationModel?.notification?.length ?? 0} items");
      notificationList.clear();
      notificationList.addAll(userNotificationModel?.notification ?? []);
      _recalculateUnreadCount();
    } catch (e) {
      log("❌ [getNotificationUser] ERROR: $e");
      Utils.showToast(Get.context!, "Failed to fetch notifications.");
    } finally {
      isLoading = false;
      update([Constant.idUserNotification]);
    }
  }

  Future<void> clearNotificationUser() async {
    isLoading = true;
    update([Constant.idUserNotification]);

    try {
      notificationClearModel = await NotificationClearApi.callApi();

      if (notificationClearModel?.status == true) {
        notificationList.clear();
        unreadCount = 0;
        update([Constant.idUserNotification, Constant.idNotificationBadge]);

        await getNotificationUser();

        Utils.showToast(Get.context!, notificationClearModel?.message ?? "Notification history cleared.");
      } else {
        Utils.showToast(Get.context!, notificationClearModel?.message ?? "Notification history not found.");
      }
    } catch (e) {
      log("❌ [clearNotificationUser] ERROR: $e");
      Utils.showToast(Get.context!, "Failed to clear notifications.");
    } finally {
      isLoading = false;
      update([Constant.idUserNotification]);
    }
  }

  Future<void> onRefresh() async {
    await _initialLoad();
  }
}