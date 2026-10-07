import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

class RazorPayService {
  static late Razorpay razorPay;
  static late String razorKeys;
  Callback onComplete = () {};
  Function(String message) onError = (_) {}; // NEW

  void init({
    required String razorKey,
    required Callback callback,
    required Function(String message) onError, // NEW
  }) {
    razorPay = Razorpay();
    razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
    razorKeys = razorKey;
    onComplete = () => callback.call();
    this.onError = onError; // NEW
  }

  void razorPayCheckout(int amount) async {
    debugPrint("Payment Amount => $amount");

    var options = {
      'key': Database.settingApiModel?.data?.razorpayKeyId,
      'amount': amount,
      'name': EnumLocale.txtAppName.name.tr,
      'theme.color': AppColors.primary.value.toRadixString(16),
      'description': EnumLocale.txtAppName.name,
      'currency': "INR",
      'prefill': {
        'contact': "",
        'email': Database.fetchLoginUserProfileModel?.user?.email ?? ""
      },
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      razorPay.open(options);
    } catch (e) {
      debugPrint("Razor Payment Error => ${e.toString()}");
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) async {
    Utils.showLog("Payment Success");
    onComplete.call();
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Utils.showLog("RazorPay Payment Failed !! => ${response.message}");
    onError.call(response.message ?? "Payment failed"); // NEW
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    Utils.showLog(
        "RazorPay Payment External Wallet !! => ${response.walletName}");
    onError.call(
        "Payment cancelled"); // NEW — treat external wallet selection as needing to close the dialog too, adjust if you actually want to handle wallets differently
  }

// }
// void handlePaymentSuccess(PaymentSuccessResponse response) async {
//   Utils.showLog("Payment Success");
//   Utils.showLog("PaymentId : ${response.paymentId}");
//   Utils.showLog("OrderId   : ${response.orderId}");
//   Utils.showLog("Signature : ${response.signature}");
//
//   onComplete.call();
// }
//
// void handlePaymentError(PaymentFailureResponse response) {
//   Utils.showLog("RazorPay Payment Failed !! => ${response.message}");
// }
//
// void handleExternalWallet(ExternalWalletResponse response) {
//   Utils.showLog("RazorPay Payment External Wallet !! => ${response.walletName}");
// }
}
