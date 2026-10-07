import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/all_listeners_screen/api/all_listeners_api.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:talk_in/utils/constant.dart';

class AllListenersController extends GetxController {
  bool isLoading = false;
  TopListenersModel? topListenersModel;
  List<TopListeners> allListener = [];
  ScrollController scrollController = ScrollController();
  bool isPaginationLoading = false;
  bool isBackProfile = false;

  Timer? _statusPollTimer;
  bool _isPolling = false;

  // Same interval as HomeScreenController — adjust here if you want it different.
  static const Duration _statusPollInterval = Duration(seconds: 1);

  @override
  void onInit() {
    init();
    _startStatusPolling();
    super.onInit();
  }

  init() async {
    log("Enter In all listener screen Controller");
    scrollController.addListener(onTopListenersPagination);

    AllListenersApi.startPagination = 0;
    await allListeners();
  }

  /// all listener api
  allListeners() async {
    isLoading = true;
    update([Constant.idGetListener]);

    topListenersModel = await AllListenersApi.callApi(searchString: "All");
    allListener.addAll(topListenersModel?.data ?? []);

    isLoading = false;

    update([Constant.idGetListener]);
  }

  /// pagination
  Future<void> onTopListenersPagination() async {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      isPaginationLoading = true;
      update([Constant.idPaginationListener, Constant.idGetListener]);

      topListenersModel = await AllListenersApi.callApi(searchString: "All");
      allListener.addAll(topListenersModel?.data ?? []);

      isPaginationLoading = false;
      update([Constant.idPaginationListener, Constant.idGetListener]);
    }
  }

  /// refresh
  Future<void> onRefresh() async {
    AllListenersApi.startPagination = 0;
    allListener.clear();
    await allListeners();
  }

  // ── Background status polling — updates online/offline live ──────────
  // Same safe pattern as HomeScreenController:
  //  - Resets the shared static pagination cursor before polling, and
  //    restores it after, so polling never fetches whatever page the user
  //    scrolled to (which would break id-matching and silently do nothing).
  //  - Updates matching listeners IN PLACE instead of clearing the list,
  //    so there's no flicker and scroll position is never disturbed.
  //  - Only calls update() if something actually changed.
  void _startStatusPolling() {
    _statusPollTimer?.cancel();
    _statusPollTimer = Timer.periodic(_statusPollInterval, (_) {
      _pollStatusSilently();
    });
  }

  Future<void> _pollStatusSilently() async {
    if (_isPolling) return; // avoid overlapping calls if API is slow
    _isPolling = true;

    final savedPagination = AllListenersApi.startPagination;
    AllListenersApi.startPagination = 0;

    try {
      final freshData = await AllListenersApi.callApi(searchString: "All");

      if (freshData?.data == null) return;

      final freshList = freshData!.data!;
      bool didChange = false;

      final freshById = {
        for (final l in freshList)
          if (l.id != null) l.id!: l,
      };

      // Update existing entries in place if their status changed.
      for (int i = 0; i < allListener.length; i++) {
        final current = allListener[i];
        final updated = freshById[current.id];
        if (updated != null && updated.statusLabel != current.statusLabel) {
          allListener[i] = updated;
          didChange = true;
        }
      }

      // Add any brand-new listeners not yet in the list.
      final existingIds = allListener.map((l) => l.id).toSet();
      final newOnes = freshList.where((l) => l.id != null && !existingIds.contains(l.id)).toList();
      if (newOnes.isNotEmpty) {
        allListener.addAll(newOnes);
        didChange = true;
      }

      if (didChange) {
        update([Constant.idGetListener]);
      }
    } catch (e) {
      log("All listeners status poll error: $e");
      // Silent failure — don't disrupt the UI for a background poll issue.
    } finally {
      AllListenersApi.startPagination = savedPagination; // restore user's real pagination position
      _isPolling = false;
    }
  }

  @override
  void onClose() {
    _statusPollTimer?.cancel();
    scrollController.removeListener(onTopListenersPagination);
    scrollController.dispose();
    super.onClose();
  }
}