import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/main_screen/api/login_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_listener_profile_api.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

import 'otp_controller.dart';

class OtpController extends GetxController {
  // 6 boxes
  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes =
  List.generate(6, (_) => FocusNode());

  // Read args passed from MobileLoginController.onSendOtp()
  late final String phoneNumber;
  late final String dialCode;
  late final String verificationId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as List?;
    phoneNumber   = args?[0] ?? '';
    dialCode      = args?[1] ?? '+91';
    verificationId = args?[2] ?? '';

    // Safety check — if verificationId is missing the flow is broken
    if (verificationId.isEmpty) {
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

  // Called by the first OTP box listener to handle SMS autofill paste
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

    if (otp.length != 6) {
      Utils.showToast(Get.context!, 'Enter the 6-digit OTP');
      return;
    }

    Get.dialog(const LoadingWidget(), barrierDismissible: false);

    try {
      // Step 1 — verify OTP with Firebase
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Step 2 — get device identity + FCM token
      final identity =
          (await MobileDeviceIdentifier().getDeviceId()) ?? '';
      final fcmToken =
          (await FirebaseMessaging.instance.getToken()) ?? '';

      Database.onSetIdentity(identity);
      Database.onSetFcmToken(fcmToken);

      // Step 3 — call your login API
      final loginModel = await LoginApi.callApi(
        countryCode: Database.selectedCountryCode,
        loginType: 3,
        identity: identity,
        fcmToken: fcmToken,
        mobileNumber: '$dialCode$phoneNumber',
      );

      if (loginModel?.status != true) {
        Utils.showToast(Get.context!, 'Login failed. Try again.');
        return;
      }

      // Step 4 — persist login state
      Database.onSetIsLogin(true);
      Database.onSetLoginType(loginModel?.user?.loginType ?? 0);
      Database.onSetSeenOnboarding(true);

      // Step 5 — fetch full profile
      await _fetchAndStoreProfile(userCredential.user!.uid);

      // Step 6 — route
      if (loginModel?.signUp == true) {
        // New user — fill profile first
        Database.onSetFillProfile(false);
        Get.offAllNamed(AppRoutes.fillProfileScreen, arguments: [
          Database.loginUserName,
          Database.loginUserProfilePic,
          Database.loginUserEmail,
        ]);
      } else {
        // Returning user — go to correct bottom bar
        Database.onSetFillProfile(true);
        if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
          Get.offAllNamed(AppRoutes.hostBottomBar);
        } else {
          Get.offAllNamed(AppRoutes.bottomBar);
        }
      }
    } on FirebaseAuthException catch (e) {
      Utils.showToast(Get.context!, e.message ?? 'Invalid OTP');
    } catch (e) {
      Utils.showToast(Get.context!, 'Something went wrong. Try again.');
    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
    }
  }

  Future<void> _fetchAndStoreProfile(String firebaseUid) async {
    final token = await FirebaseAccessToken.onGet() ?? '';

    final profile = await FetchLoginUserProfileApi.callApi(
      loginUserId: firebaseUid,
      token: token,
    );

    Database.fetchLoginUserProfileModel = profile;

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

    // If listener, also fetch listener profile
    if (user.isListener == true) {
      final listenerProfile = await FetchListenerProfileAPi.callApi(
        loginListenerId: profile.user?.listenerId ?? '',
      );
      Database.fetchListenerProfileModel = listenerProfile;
      if (listenerProfile?.data?.id != null) {
        Database.onSetLoginUserId(listenerProfile!.data!.id!);
      }
    }
  }

  // Called by the Resend button on OTP screen
  Future<void> onResendOtp() async {
    // Delegate back to MobileLoginController which owns the phone number
    await Get.find<MobileLoginController>().onSendOtp();
  }
}