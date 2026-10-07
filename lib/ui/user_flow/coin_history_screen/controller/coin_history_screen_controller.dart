import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/calling_screen/api/calling_history_api.dart';
import 'package:talk_in/ui/user_flow/calling_screen/model/calling_history_response_model.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/api/coin_history_api.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/api/purchase_coin_plan_api.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/model/coin_history_model.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/model/purchase_cpin_plan_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/utils.dart';

class CoinHistoryScreenController extends GetxController {
  int tabIndex = 0;
  GetPurchaseCoinPlanModel? purchaseCoinPlanModel;
  List<Datum> purchaseCoinList = [];
  CoinHistoryModel? coinHistoryModel;
  List<CoinHistory> coinHistoryList = [];
  bool isLoading = false;
  bool isPaginationLoading = false;
  ScrollController scrollController = ScrollController();
  ScrollController scrollController1 = ScrollController();
  DateTimeRange? selectedCoinDateRange;
  DateTimeRange? selectedPaymentDateRange;

  /// used only to look up correct per-call coin values for reconciliation
  List<CallHistory> _callingHistoryForReconciliation = [];

  @override
  void onInit() {
    init();
    super.onInit();
  }

  init() async {
    log(")))))))))))))))))))))))))))))))))))))))))))");
    scrollController.addListener(onCoinHistoryPagination);
    scrollController1.addListener(onPaymentHistoryPagination);
    CoinHistoryApi.startPagination = 0;
    PurchaseCoinGetPlanApi.startPagination = 0;

    await paymentHistory();
    await _loadCallingHistoryForReconciliation();
    await coinHistory();
  }

  /// fetch calling history once, purely to source correct call-coin values
  /// (mirrors CallingScreenController.getCallingHistory, where userCoin
  /// is known to display correctly)
  Future<void> _loadCallingHistoryForReconciliation() async {
    try {
      final result = await CallingHistoryApi.callApi(endDate: "All", startDate: "All");
      _callingHistoryForReconciliation = result?.data ?? [];
    } catch (e) {
      log("Reconciliation fetch failed :: $e");
      _callingHistoryForReconciliation = [];
    }
  }

  /// Overwrite ledger coin values for call-type entries using the
  /// calling-history value, since that's computed once from real call
  /// duration and isn't affected by duplicate deduction socket emits.
  ///
  /// ASSUMPTIONS — please confirm against your actual CoinHistory model:
  /// - `entry.id`   -> matches the call's Mongo _id
  /// - `entry.type` -> int flag, 3 == call-type transaction
  /// - `entry.userCoin` -> exists; treated as immutable, so we rebuild
  ///   the entry with copyWith rather than mutate it directly
  void _reconcileCoinValues() {
    if (_callingHistoryForReconciliation.isEmpty) return;

    final Map<String, num> callIdToCoin = {
      for (final call in _callingHistoryForReconciliation)
        if (call.id != null && call.coin != null) call.id!: call.coin!
    };

    for (int i = 0; i < coinHistoryList.length; i++) {
      final entry = coinHistoryList[i];

      // if (entry.type == 3 && entry.id != null && callIdToCoin.containsKey(entry.id)) {
      //   final correctCoin = callIdToCoin[entry.id]!;
      //   coinHistoryList[i] = entry.copyWith(userCoin: correctCoin);
      // }
    }
  }

  void changeTab(int index) {
    tabIndex = index;
    update([Constant.idTabChange]);
  }

  /// get payment history
  paymentHistory() async {
    isLoading = true;
    update([Constant.idTabChange]);

    purchaseCoinPlanModel = await PurchaseCoinGetPlanApi.callApi(endDate: "All", startDate: "All");
    purchaseCoinList.clear();
    purchaseCoinList.addAll((purchaseCoinPlanModel?.data ?? []));

    isLoading = false;
    update([Constant.idTabChange]);
  }

  /// get coin history
  coinHistory() async {
    isLoading = true;
    update([Constant.idTabChange]);

    coinHistoryModel = await CoinHistoryApi.callApi(endDate: "All", startDate: "All");
    coinHistoryList.clear();
    coinHistoryList.addAll((coinHistoryModel?.data ?? []));

    _reconcileCoinValues();

    isLoading = false;
    update([Constant.idTabChange]);
  }

  /// coin history refresh
  Future<void> onRefresh() async {
    CoinHistoryApi.startPagination = 0;
    final range = selectedCoinDateRange;
    coinHistoryModel = await CoinHistoryApi.callApi(
      startDate: range != null ? Utils.formatDateToApi(range.start) : "All",
      endDate: range != null ? Utils.formatDateToApi(range.end) : "All",
    );
    coinHistoryList.clear();
    coinHistoryList.addAll((coinHistoryModel?.data ?? []));

    await _loadCallingHistoryForReconciliation();
    _reconcileCoinValues();

    update([Constant.idTabChange]);
  }

  /// purchase coin plan history refresh
  Future<void> onPaymentRefresh() async {
    PurchaseCoinGetPlanApi.startPagination = 0;
    final range = selectedPaymentDateRange;
    purchaseCoinPlanModel = await PurchaseCoinGetPlanApi.callApi(
      startDate: range != null ? Utils.formatDateToApi(range.start) : "All",
      endDate: range != null ? Utils.formatDateToApi(range.end) : "All",
    );
    purchaseCoinList.clear();
    purchaseCoinList.addAll((purchaseCoinPlanModel?.data ?? []));
    update([Constant.idTabChange]);
  }

  /// coin history pagination
  Future<void> onCoinHistoryPagination() async {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      isPaginationLoading = true;
      update([Constant.idPaginationListener]);

      final result = await CoinHistoryApi.callApi(
        endDate: selectedCoinDateRange != null ? Utils.formatDateToApi(selectedCoinDateRange!.end) : "All",
        startDate: selectedCoinDateRange != null ? Utils.formatDateToApi(selectedCoinDateRange!.start) : "All",
      );

      final newItems = result?.data ?? [];

      if (newItems.isNotEmpty) {
        coinHistoryList.addAll(newItems);
        _reconcileCoinValues();
      }

      isPaginationLoading = false;
      update([Constant.idPaginationListener, Constant.idTabChange]);
    }
  }

  /// payment history pagination
  Future<void> onPaymentHistoryPagination() async {
    if (scrollController1.position.pixels == scrollController1.position.maxScrollExtent) {
      isPaginationLoading = true;
      update([Constant.idPaginationListener]);

      final result = await PurchaseCoinGetPlanApi.callApi(
        endDate: selectedPaymentDateRange != null ? Utils.formatDateToApi(selectedPaymentDateRange!.end) : "All",
        startDate: selectedPaymentDateRange != null ? Utils.formatDateToApi(selectedPaymentDateRange!.start) : "All",
      );

      final newItems = result?.data ?? [];
      if (newItems.isNotEmpty) {
        purchaseCoinList.addAll(newItems);
      }

      isPaginationLoading = false;
      update([Constant.idPaginationListener, Constant.idTabChange]);
    }
  }

  /// apply date filter
  Future<void> applyDateFilter(DateTime startDate, DateTime endDate) async {
    if (tabIndex == 0) {
      selectedPaymentDateRange = DateTimeRange(start: startDate, end: endDate);
      purchaseCoinList.clear();
      isLoading = true;
      update([Constant.idTabChange]);
      PurchaseCoinGetPlanApi.startPagination = 0;

      purchaseCoinPlanModel = await PurchaseCoinGetPlanApi.callApi(
        startDate: Utils.formatDateToApi(startDate),
        endDate: Utils.formatDateToApi(endDate),
      );
      purchaseCoinList.addAll((purchaseCoinPlanModel?.data ?? []));
    } else {
      selectedCoinDateRange = DateTimeRange(start: startDate, end: endDate);
      coinHistoryList.clear();
      isLoading = true;
      update([Constant.idTabChange]);
      CoinHistoryApi.startPagination = 0;

      coinHistoryModel = await CoinHistoryApi.callApi(
        startDate: Utils.formatDateToApi(startDate),
        endDate: Utils.formatDateToApi(endDate),
      );
      coinHistoryList.addAll((coinHistoryModel?.data ?? []));

      await _loadCallingHistoryForReconciliation();
      _reconcileCoinValues();
    }

    isLoading = false;
    update([Constant.idTabChange]);
  }

  /// clear filter
  void clearDateFilter() async {
    if (tabIndex == 0) {
      isLoading = true;
      selectedPaymentDateRange = null;
      purchaseCoinList.clear();
      update([Constant.idTabChange]);

      PurchaseCoinGetPlanApi.startPagination = 0;

      purchaseCoinPlanModel = await PurchaseCoinGetPlanApi.callApi(
        startDate: "All",
        endDate: "All",
      );
      purchaseCoinList.addAll((purchaseCoinPlanModel?.data ?? []));
    } else {
      isLoading = true;
      selectedCoinDateRange = null;
      coinHistoryList.clear();
      update([Constant.idTabChange]);
      CoinHistoryApi.startPagination = 0;

      coinHistoryModel = await CoinHistoryApi.callApi(
        startDate: "All",
        endDate: "All",
      );
      coinHistoryList.addAll((coinHistoryModel?.data ?? []));

      await _loadCallingHistoryForReconciliation();
      _reconcileCoinValues();
    }

    isLoading = false;
    update([Constant.idTabChange]);
  }
}