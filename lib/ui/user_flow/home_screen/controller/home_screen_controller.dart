import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/home_screen/api/top_listeners_api.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/user_coin_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';

import '../../all_listeners_in_home/widgets/all_listener_widget.dart';

class HomeScreenController extends GetxController {
  bool isLoading = false;
  bool isPaginationLoading = false;
  bool isBackProfile = false;
  TopListenersModel? topListenersModel;
  List<TopListeners> topListeners = [];
  TextEditingController allListenersSearch = TextEditingController();
  ScrollController scrollController = ScrollController();
  UserCoinModel? userCoinModel;
  bool isToastVisible = false;
  bool isCoinLoading = false;

  Timer? _statusPollTimer;
  bool _isPolling = false;

  // Poll interval for refreshing online/offline status.
  // 10s is a reasonable balance between "feels live" and not hammering the API.
  static const Duration _statusPollInterval = Duration(seconds: 10);

  @override
  @override
  void onInit() {
    TopListenersApi.startPagination = 0; // reset cursor, always
    log("Enter home screen controller");

    if (topListeners.isEmpty) {
      getTopListeners(); // only full-fetch if we don't already have data
    }

    init();
    _startStatusPolling(); // this keeps online/offline live regardless
    super.onInit();
  }

  init() async {
    // Single source of truth for the coin balance. Previously this also
    // called FetchCoinPlanApi.callApi() concurrently (unawaited alongside
    // fetchUserCoin()), and both paths wrote Database.userCoin / toggled
    // isCoinLoading independently. Whichever call finished last silently
    // clobbered the other's result and its isCoinLoading state, which is
    // why the coin balance sometimes looked like it never refreshed on
    // this screen. Now there is exactly one awaited call.
    await fetchUserCoin();

    scrollController.addListener(onTopListenersPagination);
  }

  /// Fetches the latest coin balance and updates only the coin chip.
  ///
  /// NOTE: this is the ONLY method that should touch isCoinLoading /
  /// Database.onSetUserCoin for the coin balance. Do not add a second,
  /// parallel coin-fetch path (e.g. calling FetchCoinPlanApi separately)
  /// — that reintroduces the race this fix removed. If a UI needs to
  /// trigger a refresh, it should call this method (and ideally await it,
  /// or at least not call it redundantly on every rebuild).
  Future<void> fetchUserCoin() async {
    isCoinLoading = true;
    update([Constant.idCoinUpdate]);
    await Database.refreshLoginUserProfile();
    final coins = Database.fetchLoginUserProfileModel?.user?.coins;

    isCoinLoading = false;

    if (coins == null) {
      update([Constant.idCoinUpdate]);
      _showRefreshDialog();
      return;
    }

    await Database.onSetUserCoin(coins.toString());
    update([Constant.idCoinUpdate]);
  }

  void _showRefreshDialog() {
    // Avoid stacking multiple copies if this fires more than once
    // (e.g. polling + manual refresh both hitting a null coin at once).
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(
      barrierColor: Colors.black.withValues(alpha: 0.9),
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        child: NewListenersDialog(
          onRefresh: () {
            Get.back(); // close dialog
            getTopListeners();
            fetchUserCoin();
          },
        ),
      ),
    );
  }
  getTopListeners() async {
    final uid = Database.loginUserId;

    isLoading = true;
    update([Constant.idGetListener]);

    final result = await TopListenersApi.callApi(token: Api.secretKey, uid: uid, searchString: "All");
    if (result != null) {
      topListenersModel = result;
      topListeners.addAll(result.data ?? []);
    }

    isLoading = false;
    update([Constant.idGetListener]);
  }

  Future<void> onTopListenersPagination() async {
    final uid = Database.loginUserId;

    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      isPaginationLoading = true;
      update([Constant.idPaginationListener]);

      final result = await TopListenersApi.callApi(token: Api.secretKey, uid: uid, searchString: "All");
      if (result != null) {
        topListenersModel = result;
        topListeners.addAll(result.data ?? []);
      }

      isPaginationLoading = false;
      update([Constant.idPaginationListener]);
    }
  }

  // Manual pull-to-refresh
  onRefresh() async {
    TopListenersApi.startPagination = 0;

    final coinFuture = fetchUserCoin();

    final result = await TopListenersApi.callApi(
      token: Api.secretKey,
      uid: Database.loginUserId,
      searchString: "All",
    );

    if (result != null) {
      topListenersModel = result;
      topListeners
        ..clear()
        ..addAll(result.data ?? []);
    }

    await coinFuture;

    update([Constant.idGetListener]);
  }

  // ── Background status polling — updates online/offline live ──────────
  // Key difference from before: we update listeners IN PLACE by matching
  // on id, instead of clearing the list. This means:
  //  - No flicker (list never goes empty).
  //  - No scroll-position reset.
  //  - Only status/fields that actually changed cause a rebuild.
  void _startStatusPolling() {
    _statusPollTimer?.cancel();
    _statusPollTimer = Timer.periodic(_statusPollInterval, (_) {
      _pollStatusSilently();
    });
  }

  Future<void> _pollStatusSilently() async {
    if (_isPolling) return; // avoid overlapping calls if API is slow
    _isPolling = true;

    // TopListenersApi.startPagination is a SHARED static cursor also advanced
    // by scroll pagination. If we don't reset it before polling, the poll
    // silently fetches whatever page the user last scrolled to instead of
    // page 1 — so ids never match anything in `topListeners` and the list
    // never visibly updates. Save + restore it so polling never disturbs
    // the user's actual scroll/pagination position.
    final savedPagination = TopListenersApi.startPagination;
    TopListenersApi.startPagination = 0;

    try {
      final uid = Database.loginUserId;

      final freshData = await TopListenersApi.callApi(
        token: Api.secretKey,
        uid: uid,
        searchString: "All",
      );

      if (freshData?.data == null) return;

      final freshList = freshData!.data!;
      bool didChange = false;

      // Build a lookup of fresh data by id for fast matching.
      final freshById = {
        for (final l in freshList)
          if (l.id != null) l.id!: l,
      };

      // Update existing entries in place if their status/data changed.
      for (int i = 0; i < topListeners.length; i++) {
        final current = topListeners[i];
        final updated = freshById[current.id];
        if (updated != null && updated.statusLabel != current.statusLabel) {
          topListeners[i] = updated;
          didChange = true;
        }
      }

      // Add any brand-new listeners that weren't in the list before
      // (e.g. a listener that just came online and wasn't previously loaded).
      final existingIds = topListeners.map((l) => l.id).toSet();
      final newOnes = freshList.where((l) => l.id != null && !existingIds.contains(l.id)).toList();
      if (newOnes.isNotEmpty) {
        topListeners.addAll(newOnes);
        didChange = true;
      }

      if (didChange) {
        topListenersModel = freshData;
        update([Constant.idGetListener]); // only rebuilds when something actually changed
      }
    } catch (e) {
      log("Status poll error: $e");
      // Silent failure — don't disrupt the UI for a background poll issue.
    } finally {
      TopListenersApi.startPagination = savedPagination; // restore user's real pagination position
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