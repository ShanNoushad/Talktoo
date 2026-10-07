 import 'package:get/get.dart';
import 'package:incodes_payment/incodes_payment_services.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

import '../custom/progress_indicator/progress_dialog.dart';



/// razor pay payment
Future<void> razorPay({
  required num amount,
  required Function() onPaymentSuccess,
}) async {
  Utils.showLog("Razorpay Payment (Incodes) starting...");
  Utils.showLog("Razorpay Payment (Incodes) starting...$amount");
  Utils.showLog("CURRENCY FROM SETTINGS: ${Database.settingApiModel?.data?.currency?.currencyCode}");
  Utils.showLog("FULL CURRENCY OBJECT: ${Database.settingApiModel?.data?.currency}");
  try {
    final razorKey =
        Database.settingApiModel?.data?.razorpayKeySecret ?? '';
    final email = Database.fetchLoginUserProfileModel?.user?.email ;
///edit 2026
    final currency = "INR";
    // Utils.showLog("customerName>>>>>>>>>>>>>>>>>>>>>>$customerName");
    Utils.showLog("email>>>>>>>>>>>>>>>>>>>>>>$email");
    Utils.showLog("Database.email>>>>>>>>>>>>>>>>>>>>>>${email}");


    // final contact = (Database.getUserProfileResponseModel?.user?.phoneNumber ??
    //     Database.getUserProfileResponseModel?.user?.phoneNumber ??
    //     "+91-0000000000");

    String toHex6(int argb) {
      final hex8 = argb.toRadixString(16).padLeft(8, '0');
      return '#${hex8.substring(2)}';
    }


    Utils.showLog("amount.toDouble()${amount.toDouble()}");
    final appName = EnumLocale.txtAppName.name.tr;
    final hexColor = toHex6(AppColors.primary.hashCode);

    await IncodesPaymentServices.razorPayPayment(
      currency: currency,
      razorpayKey: razorKey.isNotEmpty ? razorKey : "",
      contactNumber: "+91-0000000000",
      emailId: email.toString(),
      amount: amount.toDouble(),
      appName: appName,
      colorCode: hexColor,
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: () {
        Utils.showToast( Get.context!,EnumLocale.txtPaymentFailedPleaseTryAgain.name.tr);
      },
      onExternalWallet: () {
        Utils.showLog("RazorPay External Wallet selected");
      },
    );
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("RazorPay Payment Failed => $e");
  }
}

/// stripe payment
Future<void> stripe({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  try {
    Utils.showLog("Stripe Payment (Incodes) starting...");

    final publishableKey =
        Database.settingApiModel?.data?.stripePublicKey ?? "";

    final secretKey =
        Database.settingApiModel?.data?.stripeSecretKey ?? "";

    final currency =
        Database.settingApiModel?.data?.currency?.currencyCode ??

            "INR";

    final merchantDisplayName = EnumLocale.txtAppName.name.tr;

    final merchantCountryCode = "IN";
    final merchantCountryCode1 = Database.settingApiModel?.data?.currency?.currencyCode ?? "IN";

    final int minorAmount = (amount * 100).toInt();

    await IncodesPaymentServices.stripePayment(
      amount: minorAmount,
      currency: currency,
      isTest: true,
      merchantCountryCode: merchantCountryCode,
      merchantDisplayName: merchantDisplayName,
      publishableKey: publishableKey,
      secretKey: secretKey,
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: () {
        Utils.showToast( Get.context!,EnumLocale.txtPaymentFailedPleaseTryAgain.name.tr);
      },
    );

    Utils.showLog("Stripe payment flow finished (returned).");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("Stripe Payment Failed !! => $e");
  }
}

/// flutter wave payment
Future<void> flutterWave({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  Utils.showLog("Flutterwave Payment (Incodes) starting...");
  try {
    Get.dialog(const LoadingWidget(), barrierDismissible: false);
    await 400.milliseconds.delay();
    if (Get.isDialogOpen == true) Get.back();

    final settingsKey =
        Database.settingApiModel?.data?.flutterwavePublicKey;
    final publicKey =
        (settingsKey != null && settingsKey.isNotEmpty) ? settingsKey : "";

    // final currency =  "NGN";
    final currency = Database.settingApiModel?.data?.currency?.currencyCode ?? "NGN";
    final customerName = Database.fetchLoginUserProfileModel?.user?.fullName ?? "User";
    final customerEmail = Database.fetchLoginUserProfileModel?.user?.email ?? "email";

    Utils.showLog("customerName>>>>>>>>>>>>>>>>>>>>>>$customerName");
    Utils.showLog("customerEmail>>>>>>>>>>>>>>>>>>>>>>$customerEmail");
    Utils.showLog("currency>>>>>>>>>>>>>>>>>>>>>>$currency");
    Utils.showLog("publicKey>>>>>>>>>>>>>>>>>>>>>>$publicKey");

    await IncodesPaymentServices.flutterWavePayment(
      context: Get.context!,
      publicKey: publicKey,
      currency: currency,
      amount: amount.toString(),
      customerName: customerName,
      customerEmail: customerEmail.toString(),
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: () {
        Utils.showToast( Get.context!,EnumLocale.txtPaymentFailedPleaseTryAgain.name.tr);
      },
    );

    Utils.showLog("Flutterwave payment flow finished.");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("Flutterwave Payment Failed => $e");
  }
}

///pay stack payment
Future<void> payStack({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  Utils.showLog("Paystack Payment (Incodes) starting...");
  try {
    Get.dialog(const LoadingWidget(), barrierDismissible: false);
    await 400.milliseconds.delay();
    if (Get.isDialogOpen == true) Get.back();

    // final settingsSecret =
    //     GetSettingApi.getSettingModel?.data?.flutterwaveId;
    // final secretKey = (settingsSecret != null && settingsSecret.isNotEmpty)
    //     ? settingsSecret
    //     : "";
    final settingsSecret =
        Database.settingApiModel?.data?.paystackSecretKey;

    final customerEmail = Database.fetchLoginUserProfileModel?.user?.email ?? "test@gmail.com";

    final currency =
        Database.settingApiModel?.data?.currency?.currencyCode ?? "NGN";

    // final currency =
    //      "NGN";

    final int majorAmount = amount.toInt();

    await IncodesPaymentServices.payStackPayment(
      context: Get.context!,
      secretKey: settingsSecret.toString(),
      customerEmail: customerEmail.toString(),
      amount: majorAmount,
      currency: currency,
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: () {
        Utils.showToast( Get.context!,EnumLocale.txtPaymentFailedPleaseTryAgain.name.tr);

      },
    );

    Utils.showLog("Paystack payment flow finished.");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("Paystack Payment Failed => $e");
  }
}

///pay pal payment
Future<void> payPal({
  required num amount,

  required Function()? onPaymentSuccess,
}) async {
  Utils.showLog("PayPal Payment (Incodes) starting...");
  try {
    Get.dialog(const LoadingWidget(), barrierDismissible: false);
    await 400.milliseconds.delay();
    if (Get.isDialogOpen == true) Get.back();

    final currency = Database.settingApiModel?.data?.currency?.currencyCode ??"USD";
    // final currency = "USD";


    final paypalClientId = Database.settingApiModel?.data?.paypalClientId;
    final secretKey = Database.settingApiModel?.data?.paypalSecretKey;


    await IncodesPaymentServices.paypalPayment(
      context: Get.context!,
      clientId: paypalClientId.toString(),
      secretKey: secretKey.toString(),
      transactions: [
        {
          "amount": {
            "total": amount.toString(),
            "currency": currency,
            "details": {
              "subtotal": amount.toString(),
              "shipping": '0',
              "shipping_discount": 0
            },
          },
          "description": "Subscription purchase via PayPal",
          "item_list": {
            "items": [
              {
                "name": "Subscription Plan",
                "quantity": 1,
                "price": amount.toString(),
                "currency": currency,
              },
            ],
          },
        },
      ],
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: () {
        Utils.showToast( Get.context!,EnumLocale.txtPaymentFailedPleaseTryAgain.name.tr);

      },
    );

    Utils.showLog("PayPal payment flow finished.");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("PayPal Payment Failed => $e");
  }
}

///in app purchase payment
Future<void> inAppPurchase({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  Utils.showLog("InAppPurchase Payment (Incodes) starting...");
  try {
    Get.dialog(const LoadingWidget(), barrierDismissible: false);
    await 400.milliseconds.delay();
    if (Get.isDialogOpen == true) Get.back();

    final productId = "com.android.coin100";
    final userId =
        Database.fetchLoginUserProfileModel?.user?.id.toString() ?? "123456";

    await IncodesPaymentServices.inAppPurchasePayment(
      userId: userId,
      productIds: [productId],
      amount: amount.toDouble(),
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: () {
        Utils.showToast( Get.context!,EnumLocale.txtPaymentFailedPleaseTryAgain.name.tr);

      },
    );

    Utils.showLog("InAppPurchase payment flow finished.");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("InAppPurchase Payment Failed => $e");
  }
}

///cash free payment
Future<void> cashFree({
  required num amount,
  required Function()? onPaymentSuccess,
}) async {
  Utils.showLog("CashFree Payment (Incodes) starting...");
  try {
    Get.dialog(const LoadingWidget(), barrierDismissible: false);
    await 400.milliseconds.delay();
    if (Get.isDialogOpen == true) Get.back();

    final customerName =
        Database.fetchLoginUserProfileModel?.user?.fullName ?? "John";
    final customerEmail =
    Database.fetchLoginUserProfileModel?.user?.email ?? "test@gmail.com" ;
    // final customerPhone =
    //     Database.fetchLoginUserProfileModel?.user?.phoneNumber ?? "9876543210";

    Utils.showLog("Database.getUserProfileResponseModel?.user?.phoneNumber${9876543210}");

    final cashfreeClientId =Database.settingApiModel?.data?.cashfreeClientId;
    final cashfreeSecretKey = Database.settingApiModel?.data?.cashfreeClientSecret;

// final currency ="INR";
final currency =Database.settingApiModel?.data?.currency?.currencyCode ??"INR";

    await IncodesPaymentServices.cashFreePayment(
      context: Get.context!,
      clientId: cashfreeClientId.toString(),
      clientSecret: cashfreeSecretKey.toString(),
      amount: amount.toDouble(),
      currency: currency,
      customerName: customerName,
      customerEmail: customerEmail.toString(),
      customerPhone: "9876543210",
      paymentGatewayName: "Cashfree",
      onPaymentSuccess: onPaymentSuccess,
      onPaymentFailure: () {
        Utils.showToast( Get.context!,EnumLocale.txtPaymentFailedPleaseTryAgain.name.tr);

      },
    );

    Utils.showLog("CashFree payment flow finished.");
  } catch (e) {
    if (Get.isDialogOpen == true) Get.back();
    Utils.showLog("CashFree Payment Failed => $e");
  }
}
