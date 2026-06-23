import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/custom/dialog/force_update_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_listener_profile_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/ip_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/setting_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/aap_configuration_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_listener_profile_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/ip_api_response_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/setting_api_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

import '../api/aap_configuration_api.dart';

class SplashScreenController extends GetxController {
  SettingApiModel? settingApiModel;
  FetchLoginUserProfileModel? fetchLoginUserProfileModel;
  FetchListenerProfileModel? fetchListenerProfileModel;
  IpApiResponseModel? ipApiResponseModel;
  AppConfigurationModel? appConfigurationModel;

  @override
  void onInit() {
    log('Enter splash screen controller');
    init();
    super.onInit();
  }

  Future<void> init() async {
    /// for privacy policy link and app live key
    appConfigurationModel = await AppConfigurationApi.callApi();
    Database.appConfigurationModel = appConfigurationModel;

    settingApiModel = await SettingApi.callApi();
    Database.settingApiModel = settingApiModel;

    fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(
      loginUserId: Database.loginUserId,  // ← MongoDB _id
      token: Api.secretKey,               // ← static secret key
    );
    Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;

    /// version update dialog show in splash screen not go main screen
    final bool waitter = await checkForceUpdate();
    if (waitter) return;

    if (Database.settingApiModel?.data?.isApplicationLive == false) {
      log("Application is not live...");
      Get.dialog(
        barrierColor: AppColors.black.withValues(alpha: 0.8),
        Dialog(
          backgroundColor: AppColors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          child: const AppNotLiveDialog(),
        ),
      );
    }

    if (fetchLoginUserProfileModel?.user?.isListener == true) {
      fetchListenerProfileModel = await FetchListenerProfileAPi.callApi(
        loginListenerId: fetchLoginUserProfileModel?.user?.listenerId ?? '',
      );

      if (fetchListenerProfileModel?.status == false) {
        Utils.showLog(fetchListenerProfileModel?.message ?? "");
      } else if (fetchListenerProfileModel?.data?.id != null) {
        await Database.onSetLoginListenerId(fetchListenerProfileModel!.data!.id!); // ✅ separate key
      }

      Database.fetchListenerProfileModel = fetchListenerProfileModel;
    }

    ipApiResponseModel = await IpApi.callApi();
    Database.onSetSelectedCountryCode(ipApiResponseModel?.countryCode ?? '');
    log("Database.selectedCountryCode :: ${Database.selectedCountryCode}");
    Database.getDialCode();
  }

  Future<bool> checkForceUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    Utils.showLog("Current version ==> ${packageInfo.version}");

    final latestVersion = Platform.isIOS
        ? Database.settingApiModel?.data?.iosAppVersion ?? ""
        : Database.settingApiModel?.data?.androidAppVersion ?? "";
    Utils.showLog("Latest  version ==> $latestVersion");

    if (latestVersion.isEmpty) {
      Utils.showLog("⚠️ Latest version missing from API");
      splashScreen();
      return false;
    }
    if (isUpdateRequired(currentVersion, latestVersion)) {
      Get.dialog(
        const ForceUpdateDialog(),
        barrierDismissible: false,
      );
      return true;
    } else {
      splashScreen();
      return false;
    }
  }

  bool isUpdateRequired(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (currentParts[i] < latestParts[i]) return true;
      if (currentParts[i] > latestParts[i]) return false;
    }
    return false;
  }
}

Future<void> splashScreen() async {
  Timer(const Duration(seconds: 2), () async {
    log("isLogin :: ${Database.isLogin}");
    log("isFillProfile :: ${Database.isFillProfile}");
    log("isSeenOnBoarding :: ${Database.isSeenOnBoarding}");
    log("isListener :: ${Database.fetchLoginUserProfileModel?.user?.isListener}");

    if (Database.settingApiModel?.data?.isApplicationLive == false) {
      log("Application is not live...");
      Get.dialog(
        barrierColor: AppColors.black.withValues(alpha: 0.8),
        Dialog(
          backgroundColor: AppColors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          child: const AppNotLiveDialog(),
        ),
      );
    } else {
      if (Database.fetchLoginUserProfileModel?.status == false ||
          Database.fetchLoginUserProfileModel?.message ==
              "User not found in the database.") {

        if (Database.isSeenOnBoarding == true) {
          Get.offAllNamed(AppRoutes.main);
        } else {
          Get.offAllNamed(AppRoutes.onBoarding);
        }

      } else {
        if (Database.isSeenOnBoarding == true) {
          if (Database.isLogin == true) {
            if (Database.isFillProfile == true) {
              if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
                Get.toNamed(AppRoutes.hostBottomBar);
              } else {
                Get.toNamed(AppRoutes.bottomBar);
              }
            } else {
              Get.offAllNamed(AppRoutes.fillProfileScreen, arguments: [
                Database.loginUserName,
                Database.loginUserProfilePic,
                Database.loginUserEmail,
              ]);
            }
          } else {
            Get.offAllNamed(AppRoutes.mobileLogIn);
          }
        } else {
          Get.offAllNamed(AppRoutes.onBoarding);
        }
      }
    }
  });
}