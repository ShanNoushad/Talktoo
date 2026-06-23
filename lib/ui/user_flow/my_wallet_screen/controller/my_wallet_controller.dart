import 'dart:developer';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/payment/api/purchase_coin_plan_api.dart';
import 'package:talk_in/payment/in_app_purchase/iap_callback.dart';
import 'package:talk_in/payment/in_app_purchase/in_app_purchase_helper.dart';
import 'package:talk_in/payment/razor_pay/razor_pay_service.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/home_screen/api/user_coin_api.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/user_coin_model.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/api/fetch_coin_plan_api.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/model/fetch_coin_plan.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/model/purchase_coin_plan.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/controller/random_call_controller.dart';
import 'package:talk_in/utils/common_payment.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';
import '../../../../utils/api.dart';

class MyWalletController extends GetxController implements IAPCallback {
  FetchCoinPlan? fetchCoinPlan;
  List<CoinPlan> coinPlan = [];
  bool isLoading = false;
  int selectedPaymentMethod = -1;
  PurchaseCoinPlan? purchaseCoinPlan;
  UserCoinModel? userCoinModel;
  Map<String, PurchaseDetails>? purchases;
  CoinPlan? selectedCoinPlan;

  @override
  void onInit() {
    fetchCoinPlanList();
    super.onInit();
  }

  /// fetch coin plan
  Future<void> fetchCoinPlanList() async {

    isLoading = true;
    update([Constant.idGetCoinPlan]);

    fetchCoinPlan = await FetchCoinPlanApi.callApi(
      uid: Database.loginUserId,
      token: Api.secretKey,
    );
    coinPlan.clear();
    coinPlan.addAll(fetchCoinPlan?.data ?? []);

    isLoading = false;
    update([Constant.idGetCoinPlan]);
  }

  /// change payment method
  void onChangePaymentMethod(int index) async {
    selectedPaymentMethod = index;
    update([Constant.onChangePaymentMethod]);
  }

  /// payment method condition
  Future<void> onClickPayNow(
      {required String id,
      required num amount,
      required String productKey}) async {
    if (selectedPaymentMethod == -1) {
      Utils.showToast(Get.context!, EnumLocale.txtSelectPaymentMethod.name.tr);
    }
    if (selectedPaymentMethod == 0) {
      await onClickRazorPay(amount, id);
    }

    if (selectedPaymentMethod == 1) {
      await onClickStripe(amount, id);
    }

    if (selectedPaymentMethod == 2) {
      onClickFlutterWave(amount, id);
    }

    if (selectedPaymentMethod == 3) {
      onClickInAppPurchase(amount, id, productKey);
    }

    if (selectedPaymentMethod == 4) {
      onClickCashFree(amount, id);
    }

    if (selectedPaymentMethod == 5) {
      onClickPayStack(amount, id);
    }

    if (selectedPaymentMethod == 6) {
      onClickPayPal(amount, id);
    }
  }

  /// flutter wave
  Future<void> onClickFlutterWave(num amount, String id) async {
    Utils.showLog("Flutter Wave Payment Working....");
    try {
      Get.dialog(const LoadingWidget(),
          barrierDismissible: false); // Start Loading...
      flutterWave(
        // context: Get.context!,
        amount: amount,
        onPaymentSuccess: () async {
          final uid = Database.loginUserId;

          Utils.showLog("Flutter Wave Payment Successfully");

          Get.dialog(const LoadingWidget(),
              barrierDismissible: false); // Start Loading...

          purchaseCoinPlan = await PurchaseCoinPlanApi.callApi(
              coinPlanId: id, paymentGateway: "Stripe", token: Api.secretKey, uid: uid);

          Get.back(); // Stop Loading...

          if (purchaseCoinPlan?.status == true) {
            fetchCoinPlanList();
            userCoinModel = await UserCoinApi.callApi();
            Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");
            Get.find<HomeScreenController>().update([Constant.idCoinUpdate]);
            Get.find<RandomCallController>().update([Constant.idCoinUpdate]);
            log("Database.userCoin  ${Database.userCoin}");

            Utils.showToast(
                Get.context!, EnumLocale.txtCoinRechargeSuccess.name.tr);
            Get.back(); // Close Bottom Sheet...
          } else {
            Utils.showToast(
                Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
          }
        },
      );
      update();
      Get.back(); // Stop Loading...
    } catch (e) {
      Get.back(); // Stop Loading...
      Utils.showLog("Flutter Wave Payment Failed => $e");
    }
  }

  /// stripe
  Future<void> onClickStripe(num amount, String id) async {
    try {
      Utils.showLog("Stripe Payment Working...");

      Get.dialog(const LoadingWidget(),
          barrierDismissible: false); // Start Loading...
      // await StripeService().init(isTest: true);
      await 1.seconds.delay();

      stripe(
        amount: amount,
        onPaymentSuccess: () async {
          final uid = Database.loginUserId;

          Utils.showLog("Stripe Payment Success Method Called....");

          Get.dialog(const LoadingWidget(),
              barrierDismissible: false); // Start Loading...

          purchaseCoinPlan = await PurchaseCoinPlanApi.callApi(
              coinPlanId: id, paymentGateway: "Stripe", token: Api.secretKey, uid: uid);

          Get.back(); // Stop Loading...

          if (purchaseCoinPlan?.status == true) {
            fetchCoinPlanList();

            Utils.showToast(
                Get.context!, EnumLocale.txtCoinRechargeSuccess.name.tr);
            userCoinModel = await UserCoinApi.callApi();
            Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");
            Get.find<HomeScreenController>().update([Constant.idCoinUpdate]);
            log("Database.userCoin  ${Database.userCoin}");
            Get.back(); // Close Bottom Sheet...
          } else {
            Utils.showToast(
                Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
          }
        },
      ).then((value) async {
        Utils.showLog("Stripe Payment Successfully");
      }).catchError((e) {
        Utils.showLog("Stripe Payment Error !!!");
      });
      Get.back(); // Stop Loading...
    } catch (e) {
      Get.back(); // Stop Loading...
      Utils.showLog("Stripe Payment Failed !! => $e");
    }
  }

  /// razor pay
  Future<void> onClickRazorPay(num amount, String id) async {
    Utils.showLog("Razorpay Payment Working....");

    try {
      Get.dialog(const LoadingWidget(),
          barrierDismissible: false); // Start Loading...
      razorPay(
        amount: amount,
        // razorKey: Database.settingApiModel?.data?.razorpayKeySecret ?? '',
        // razorKey: "rzp_test_SjZz9HC7RGCfCb",
        onPaymentSuccess: () async {
          final uid = Database.loginUserId;

          Utils.showLog("RazorPay Payment Successfully");

          Get.dialog(const LoadingWidget(),
              barrierDismissible: false); // Start Loading...

          purchaseCoinPlan = await PurchaseCoinPlanApi.callApi(
              coinPlanId: id,
              paymentGateway: "RazorPay",
              token: Api.secretKey,
              uid: uid);

          Get.back(); // Stop Loading...

          if (purchaseCoinPlan?.status == true) {
            fetchCoinPlanList();
            userCoinModel = await UserCoinApi.callApi();
            Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");
            Get.find<HomeScreenController>().update([Constant.idCoinUpdate]);

            Utils.showToast(
                Get.context!, EnumLocale.txtCoinRechargeSuccess.name.tr);
            Get.back(); // Close Bottom Sheet...
            Get.toNamed(AppRoutes.coinPurchaseScreen, arguments: {
              "date": purchaseCoinPlan?.historyRecord?.date,
              "amount": purchaseCoinPlan?.historyRecord?.amountPaid,
              "paymentMode": purchaseCoinPlan?.historyRecord?.paymentMode,
              "transactionId": purchaseCoinPlan?.historyRecord?.transactionId,
            });
          } else {
            Utils.showToast(
                Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
          }
        },
      );
      await 1.seconds.delay();
      RazorPayService().razorPayCheckout((amount * 100).toInt());
      Get.back(); // Stop Loading...
    } catch (e) {
      Get.back(); // Stop Loading...
      Utils.showLog("RazorPay Payment Failed => $e");
    }
  }

  ///in app purchase
  Future<void> onClickInAppPurchase(
      num amount, String id, String productKey) async {
    List<String> kProductIds = <String>[productKey];

    Utils.showLog("Starting IAP with product: $productKey");



    inAppPurchase(
      amount: amount,
      onPaymentSuccess: () async {
        Utils.showLog("In App Purchase Payment Successfully");
      },
    );

    // Add debug logging
    await InAppPurchaseHelper().debugProductLoading();

    InAppPurchaseHelper().initStoreInfo();
    await Future.delayed(const Duration(seconds: 3)); // Increased delay

    ProductDetails? product =
        InAppPurchaseHelper().getProductDetail(productKey);

    if (product != null) {
      Utils.showLog("Product found: ${product.title} - ${product.price}");
      InAppPurchaseHelper().buySubscription(product, purchases!);
    } else {
      Utils.showToast(Get.context!, "Product not found: $productKey");
      Utils.showLog(
          "Available products: ${InAppPurchaseHelper().getAvailableProducts()}");
    }
  }

  ///cash free
  Future<void> onClickCashFree(num amount, String id) async {
    Utils.showLog("cash free Payment Working....");
    try {
      Get.dialog(const LoadingWidget(),
          barrierDismissible: false); // Start Loading...
      cashFree(
        // context: Get.context!,
        amount: amount,
        onPaymentSuccess: () async {
          final uid = Database.loginUserId;

          Utils.showLog("cash free Payment Successfully");

          Get.dialog(const LoadingWidget(),
              barrierDismissible: false); // Start Loading...

          purchaseCoinPlan = await PurchaseCoinPlanApi.callApi(
              coinPlanId: id,
              paymentGateway: "cash free",
              token: Api.secretKey,
              uid: uid);

          Get.back(); // Stop Loading...

          if (purchaseCoinPlan?.status == true) {
            fetchCoinPlanList();
            userCoinModel = await UserCoinApi.callApi();
            Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");
            Get.find<HomeScreenController>().update([Constant.idCoinUpdate]);
            Get.find<RandomCallController>().update([Constant.idCoinUpdate]);
            log("Database.userCoin  ${Database.userCoin}");

            Utils.showToast(
                Get.context!, EnumLocale.txtCoinRechargeSuccess.name.tr);
            Get.back(); // Close Bottom Sheet...
          } else {
            Utils.showToast(
                Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
          }
        },
      );
      update();
      Get.back(); // Stop Loading...
    } catch (e) {
      Get.back(); // Stop Loading...
      Utils.showLog("cash free Payment Failed => $e");
    }
  }

  ///pay pal
  Future<void> onClickPayPal(num amount, String id) async {
    Utils.showLog("pay pal Payment Working....");
    try {
      Get.dialog(const LoadingWidget(),
          barrierDismissible: false); // Start Loading...
      payPal(
        // context: Get.context!,
        amount: amount,
        onPaymentSuccess: () async {
          final uid = Database.loginUserId;

          Utils.showLog("pay pal Payment Successfully");

          Get.dialog(const LoadingWidget(),
              barrierDismissible: false); // Start Loading...

          purchaseCoinPlan = await PurchaseCoinPlanApi.callApi(
              coinPlanId: id,
              paymentGateway: "pay pal",
              token: Api.secretKey,
              uid: uid);

          Get.back(); // Stop Loading...

          if (purchaseCoinPlan?.status == true) {
            fetchCoinPlanList();
            userCoinModel = await UserCoinApi.callApi();
            Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");
            Get.find<HomeScreenController>().update([Constant.idCoinUpdate]);
            Get.find<RandomCallController>().update([Constant.idCoinUpdate]);
            log("Database.userCoin  ${Database.userCoin}");

            Utils.showToast(
                Get.context!, EnumLocale.txtCoinRechargeSuccess.name.tr);
            Get.back(); // Close Bottom Sheet...
          } else {
            Utils.showToast(
                Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
          }
        },
      );
      update();
      Get.back(); // Stop Loading...
    } catch (e) {
      Get.back(); // Stop Loading...
      Utils.showLog("pay pal Payment Failed => $e");
    }
  }

  ///pay stack
  Future<void> onClickPayStack(num amount, String id) async {
    Utils.showLog("pay stack Payment Working....");
    try {
      Get.dialog(const LoadingWidget(),
          barrierDismissible: false); // Start Loading...
      payStack(
        // context: Get.context!,
        amount: amount,
        onPaymentSuccess: () async {
          final uid = Database.loginUserId;

          Utils.showLog("pay stack Payment Successfully");

          Get.dialog(const LoadingWidget(),
              barrierDismissible: false); // Start Loading...

          purchaseCoinPlan = await PurchaseCoinPlanApi.callApi(
              coinPlanId: id,
              paymentGateway: "pay stack",
              token: Api.secretKey,
              uid: uid);

          Get.back(); // Stop Loading...

          if (purchaseCoinPlan?.status == true) {
            fetchCoinPlanList();
            userCoinModel = await UserCoinApi.callApi();
            Database.onSetUserCoin(userCoinModel?.coin.toString() ?? "0");
            Get.find<HomeScreenController>().update([Constant.idCoinUpdate]);
            Get.find<RandomCallController>().update([Constant.idCoinUpdate]);
            log("Database.userCoin  ${Database.userCoin}");

            Utils.showToast(
                Get.context!, EnumLocale.txtCoinRechargeSuccess.name.tr);
            Get.back(); // Close Bottom Sheet...
          } else {
            Utils.showToast(
                Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
          }
        },
      );
      update();
      Get.back(); // Stop Loading...
    } catch (e) {
      Get.back(); // Stop Loading...
      Utils.showLog("pay stack Payment Failed => $e");
    }
  }

  onRefresh() async {
    fetchCoinPlanList();
  }

  @override
  void onBillingError(error) {
    Utils.showLog("IAP Billing Error: $error");
    Utils.showToast(Get.context!, "Payment failed: $error");
  }

  @override
  void onLoaded(bool initialized) {
    Utils.showLog("IAP Loaded: $initialized");
  }

  @override
  void onPending(PurchaseDetails product) {
    Utils.showLog("IAP Pending: ${product.productID}");
    Utils.showToast(Get.context!, "Payment is pending...");
  }

  @override
  void onSuccessPurchase(PurchaseDetails product) async {
    Utils.showLog("IAP Success: ${product.productID}");

    try {
      // Show loading dialog
      Get.dialog(const LoadingWidget(), barrierDismissible: false);
      final uid = Database.loginUserId;

      // Call the API to record the purchase
      // final isSuccess =
      //     await CreateCoinPlanHistoryApi.callApi(loginUserId: Database.loginUserId, coinPlanId: coinPlanId, paymentType: "In App Purchase");

      final isSuccess = await PurchaseCoinPlanApi.callApi(
          coinPlanId: selectedCoinPlan?.id.toString() ?? '',
          paymentGateway: "In App Purchase",
          token: Api.secretKey,
          uid: uid);

      // Hide loading dialog
      Get.back();

      if (isSuccess?.status == true) {
        Utils.showToast(
            Get.context!, EnumLocale.txtCoinRechargeSuccess.name.tr);
        Get.close(2); // Close payment screens
      } else {
        Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
      }
    } catch (e) {
      // Hide loading dialog if there's an error
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Utils.showLog("API call failed: $e");
      Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
    }
  }
}
