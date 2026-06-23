import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/main_screen/api/login_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_listener_profile_api.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

import '../../../../utils/twillio_api.dart';

class OtpController extends GetxController {
  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes =
  List.generate(6, (_) => FocusNode());

  late final String phoneNumber;
  late final String dialCode;
  late final String fullPhoneNumber;

  // ✅ Bypass config (debug only)
  static const String _bypassNumber    = '2233344444';
  static const String _bypassOtp       = '123456';
  static const String _bypassUserId    = '6a2fc2e86413f46b43bcd69a';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as List?;
    phoneNumber     = args?[0] ?? '';
    dialCode        = args?[1] ?? '+91';
    fullPhoneNumber = args?[2] ?? '';

    if (fullPhoneNumber.isEmpty) {
      Utils.showToast(Get.context!, 'Session expired. Please try again.');
      Get.back();
    }
  }

  @override
  void onClose() {
    for (final c in otpControllers) c.dispose();
    for (final f in focusNodes) f.dispose();
    super.onClose();
  }

  void onAutofillPaste(String value) {
    if (value.length == 6) {
      for (int i = 0; i < 6; i++) {
        otpControllers[i].text = value[i];
      }
      focusNodes[5].requestFocus();
    }
  }

  void onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> onVerifyOtp() async {
    final otp = otpControllers.map((c) => c.text).join();
    Database.onSetIsNewUser(false);

    if (otp.length != 6) {
      Utils.showToast(Get.context!, 'Enter the 6-digit OTP');
      return;
    }

    // ✅ Bypass: skip Twilio verification & use hardcoded profile
    if (phoneNumber == _bypassNumber && otp == _bypassOtp) {
      log('🔧 Bypass OTP verified — loading dev profile');
      await _runBypassLogin();
      return;
    }

    Get.dialog(const LoadingWidget(), barrierDismissible: false);

    try {
      // Step 1 — verify OTP with Twilio
      final otpVerified = await TwilioApi.verifyOtp(
        phoneNumber: fullPhoneNumber,
        code: otp,
      );

      if (!otpVerified) {
        if (Get.isDialogOpen ?? false) Get.back();
        Utils.showToast(Get.context!, 'Invalid OTP. Please try again.');
        return;
      }

      // Step 2 — device identity + FCM token
      final identity = (await MobileDeviceIdentifier().getDeviceId()) ?? '';
      final fcmToken = (await FirebaseMessaging.instance.getToken()) ?? '';

      Database.onSetIdentity(identity);
      Database.onSetFcmToken(fcmToken);

      // Step 3 — call login API
      final loginModel = await LoginApi.callApi(
        countryCode: Database.selectedCountryCode,
        loginType: 3,
        identity: identity,
        fcmToken: fcmToken,
        mobileNumber: fullPhoneNumber,
      );

      if (loginModel?.status != true) {
        if (Get.isDialogOpen ?? false) Get.back();
        Utils.showToast(Get.context!, loginModel?.message ?? 'Login failed. Try again.');
        return;
      }

      // Step 4 — persist login state
      Database.onSetIsLogin(true);
      Database.onSetLoginType(loginModel?.user?.loginType ?? 0);
      Database.onSetSeenOnboarding(true);

      // Step 5 — fetch and store full profile
      await _fetchAndStoreProfile(
        loginModel?.user?.id ?? '',
        Api.secretKey,
      );

      // Step 6 — set profile fill flag
      if (loginModel?.signUp == true) {
        Database.onSetFillProfile(false);
      } else {
        Database.onSetFillProfile(true);
      }

      // Step 7 — navigate based on user type
      if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
        Get.offAllNamed(AppRoutes.hostBottomBar);
      } else {
        Get.offAllNamed(AppRoutes.bottomBar);
      }

    } catch (e) {
      Utils.showToast(Get.context!, 'Something went wrong. Try again.');
    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
    }
  }

  // ✅ Full bypass login — mirrors the commented Dev Login button exactly
  Future<void> _runBypassLogin() async {
    Get.dialog(const LoadingWidget(), barrierDismissible: false);

    try {
      final profile = await FetchLoginUserProfileApi.callApi(
        loginUserId: _bypassUserId,
        token: Api.secretKey,
      );

      Database.fetchLoginUserProfileModel = profile;

      if (profile?.user == null) {
        Utils.showToast(Get.context!, "Bypass profile not found in DB");
        return;
      }

      final user = profile!.user!;

      Database.onSetIsNewUser(false);
      Database.onSetUserCoin("100");
      Database.onSetIsLogin(true);
      Database.onSetFillProfile(true);
      Database.onSetSeenOnboarding(true);
      Database.onSetLoginType(user.loginType ?? 3);
      Database.onSetLoginUserId(user.id ?? '');
      Database.onSetLoginUserFirebaseId(user.firebaseId ?? '');
      Database.onSetLoginUserName(user.fullName ?? '');
      Database.onSetLoginUserNickName(user.nickName ?? '');
      Database.onSetLoginUserEmail(user.email ?? '');
      Database.onSetLoginUserProfilePic(user.profilePic ?? '');
      Database.onSetLoginUserCountry(user.country ?? '');
      Database.onSetLoginUserCountryFlag(user.countryFlag ?? '');
      Database.onSetLoginUserBirthDate(user.birthDate ?? '');
      Database.onSetLoginUserGender(user.gender ?? 'Male');
      Database.onSetLoginUserPhoneNumber(user.phoneNumber ?? '');
      Database.onSetUserCoin(user.coins?.toString() ?? '0');

      // FCM token sync
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        Utils.showLog("Bypass Login - FCM token: $fcmToken");
        if (fcmToken != null) {
          Database.onSetFcmToken(fcmToken);
        }
      } catch (e) {
        Utils.showLog("Bypass Login - FCM sync failed: $e");
      }

      // Navigate based on user type
      if (user.isListener == true) {
        Get.offAllNamed(AppRoutes.hostBottomBar);
      } else {
        Get.offAllNamed(AppRoutes.bottomBar);
      }

    } catch (e) {
      log('_runBypassLogin error: $e');
      Utils.showToast(Get.context!, "Bypass failed: $e");
    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
    }
  }

  Future<void> _fetchAndStoreProfile(String userId, String token) async {
    final profile = await FetchLoginUserProfileApi.callApi(
      loginUserId: userId,
      token: token,
    );

    Database.fetchLoginUserProfileModel = profile;
    log("profile response => ${profile?.user?.id}");
    if (profile?.user == null) return;

    final user = profile!.user!;
    Database.onSetLoginUserId(user.id ?? '');
    Database.onSetLoginUserFirebaseId(user.firebaseId ?? '');
    Database.onSetLoginUserName(user.fullName ?? '');
    Database.onSetLoginUserNickName(user.nickName ?? '');
    Database.onSetLoginUserEmail(user.email ?? '');
    Database.onSetLoginUserProfilePic(user.profilePic ?? '');
    Database.onSetLoginUserCountry(user.country ?? '');
    Database.onSetLoginUserCountryFlag(user.countryFlag ?? '');
    Database.onSetLoginUserBirthDate(user.birthDate ?? '');
    Database.onSetLoginUserGender(user.gender ?? 'Male');
    Database.onSetLoginUserPhoneNumber(user.phoneNumber ?? '');
    Database.onSetIsNewUser(false);

    if (user.isListener == true) {
      final listenerProfile = await FetchListenerProfileAPi.callApi(
        loginListenerId: profile.user?.listenerId ?? '',
      );
      Database.fetchListenerProfileModel = listenerProfile;

      if (listenerProfile?.data?.id != null) {
        Database.onSetLoginListenerId(listenerProfile!.data!.id!);
      }
    }
  }

  Future<void> onResendOtp() async {
    try {
      Get.dialog(const LoadingWidget(), barrierDismissible: false);

      final success = await TwilioApi.sendOtp(phoneNumber: fullPhoneNumber);

      if (Get.isDialogOpen ?? false) Get.back();

      if (success) {
        Utils.showToast(Get.context!, 'OTP resent successfully');
      } else {
        Utils.showToast(Get.context!, 'Failed to resend OTP. Please try again.');
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Utils.showToast(Get.context!, 'Resend failed. Try again.');
    }
  }
}