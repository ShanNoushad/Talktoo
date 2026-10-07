import 'dart:developer';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CoinPurchaseScreenController extends GetxController {
  bool isLoading = true;

  String? date;
  String? amountPaid;
  String? paymentMode;
  String? transactionId;

  @override
  void onInit() {
    Map<String, dynamic> data = Get.arguments ?? {};

    log("purchase coin plan arguments :: $data");

    // If we were navigated here before the purchase API resolved,
    // arguments will just be {"isLoading": true} — stay in loading state
    // and wait for setLoaded() to be called once the payment succeeds.
    if (data['isLoading'] == true) {
      isLoading = true;
    } else {
      _applyData(data);
      isLoading = false;
    }

    super.onInit();
  }

  /// Called by MyWalletController once PurchaseCoinPlanApi resolves,
  /// to fill in the real receipt data and switch out of loading state.
  void setLoaded({
    String? date,
    String? amount,
    String? paymentMode,
    String? transactionId,
  }) {
    _applyData({
      'date': date,
      'amount': amount,
      'paymentMode': paymentMode,
      'transactionId': transactionId,
    });
    isLoading = false;
    update();
  }

  void _applyData(Map<String, dynamic> data) {
    date = formatToCustomDate("${data['date']?.toString()}");
    amountPaid = data['amount']?.toString();
    paymentMode = data['paymentMode']?.toString();
    transactionId = data['transactionId']?.toString();
  }

  String formatToCustomDate(String input) {
    try {
      final inputFormat = DateFormat("M/d/y, h:mm:ss a"); // your original format
      final dateTime = inputFormat.parse(input);

      final outputFormat = DateFormat("d MMM y"); // your desired format
      return outputFormat.format(dateTime); // e.g., 7 Jul 2025
    } catch (e) {
      return "Invalid date";
    }
  }
}