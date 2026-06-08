import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:talk_in/custom/custom_web_view/web_view_screen.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/custom/random_name/random_name.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/main_screen/api/get_firebase_custom_token_api.dart';
import 'package:talk_in/ui/user_flow/main_screen/api/get_firebase_uid_by_device_u_uid_api.dart';
import 'package:talk_in/ui/user_flow/main_screen/api/login_api.dart';
import 'package:talk_in/ui/user_flow/main_screen/model/check_user_exist_model.dart';
import 'package:talk_in/ui/user_flow/main_screen/model/get_firebase_custom_token_model.dart';
import 'package:talk_in/ui/user_flow/main_screen/model/get_firebase_uid_by_device_u_uid_model.dart';
import 'package:talk_in/ui/user_flow/main_screen/model/login_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_listener_profile_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_listener_profile_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class MainScreenController extends GetxController {
  int? selectedValue;
  final formKey = GlobalKey<FormState>();
  bool isObscure = true;
  bool isLoading = false;
  String randomName = '';
  String randomImage = '';
  GoogleSignInAccount? googleSignInAccountUser;
  LoginModel? loginModel;
  FetchLoginUserProfileModel? fetchLoginUserProfileModel;
  FetchListenerProfileModel? fetchListenerProfileModel;
  CheckUserExistModel? checkUserExistModel;

  // Kept for backward-compat (email/password/quick-login flows still use these)
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void onInit() {
    passwordController.clear();
    emailController.clear();
    randomName = CustomFetchRandomName.onGet();
    randomImage = CustomFetchRandomImage.onGet();
    super.onInit();
  }

  // ── Privacy policy toggle ──────────────────────────────────────────────────
  void toggleValue(int value) {
    if (selectedValue == value) {
      selectedValue = null;
    } else {
      selectedValue = value;
    }
    update([Constant.radioButton]);
  }

  Future<void> onClickPrivacyPolicy() async {
    final String privacyPolicyUrl =
        Database.appConfigurationModel?.data?.userPrivacyPolicyUrl ?? '';
    if (privacyPolicyUrl.isNotEmpty) {
      Get.to(() =>
          WebViewScreen(url: privacyPolicyUrl, screen: "Privacy Policy"));
    } else {
      log('Invalid privacy policy URL');
    }
  }

  // ── Shared: fetch & store full user profile ────────────────────────────────
  Future<void> onGetProfile(
      {required String loginUserId, required int loginType}) async {
    final token = await FirebaseAccessToken.onGet();

    fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(
        loginUserId: loginUserId, token: token ?? '');
    Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;

    log("fetchLoginUserProfileModel?.user?.id${fetchLoginUserProfileModel?.user?.id}");
    if (loginUserId.trim().isNotEmpty && token!.trim().isNotEmpty) {
      if (fetchLoginUserProfileModel?.user?.loginType != null) {
        Database.onSetIsNewUser(false);
        log("fetchLoginUserProfileModel?.user?.Email${fetchLoginUserProfileModel?.user?.email}");

        Database.onSetLoginUserId(fetchLoginUserProfileModel!.user!.id!);
        Database.onSetLoginUserFirebaseId(
            fetchLoginUserProfileModel!.user!.firebaseId!);
        Database.onSetLoginUserProfilePic(
            fetchLoginUserProfileModel?.user?.profilePic ?? "");
        Database.onSetLoginUserName(fetchLoginUserProfileModel!.user!.fullName!);
        Database.onSetLoginUserNickName(
            fetchLoginUserProfileModel?.user?.nickName ?? "");
        Database.onSetLoginUserEmail(fetchLoginUserProfileModel!.user!.email!);
        Database.onSetLoginUserCountry(
            fetchLoginUserProfileModel!.user!.country!);
        Database.onSetLoginUserCountryFlag(
            fetchLoginUserProfileModel!.user!.countryFlag!);
        Database.onSetLoginUserBirthDate(
            fetchLoginUserProfileModel?.user?.birthDate ?? "");
        Database.onSetLoginUserGender(
            fetchLoginUserProfileModel?.user?.gender ?? "Male");
        Database.onSetLoginUserPhoneNumber(
            fetchLoginUserProfileModel?.user?.phoneNumber ?? "");
        Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;
        log("Database.loginUserId  ${Database.loginUserId}");
        log("Database.loginUserEmail  ${Database.loginUserEmail}");
        log("Database.loginUserFirebaseId  ${Database.loginUserFirebaseId}");
        log("Database.image  ${Database.loginUserProfilePic}");

        if (fetchLoginUserProfileModel?.user?.isListener == true) {
          fetchListenerProfileModel = await FetchListenerProfileAPi.callApi(
            loginListenerId:
            Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
          );
          Database.onSetLoginUserId(fetchListenerProfileModel!.data!.id!);
          if (fetchListenerProfileModel?.status == false) {
            Utils.showLog(fetchListenerProfileModel?.message ?? "");
          }
          Database.fetchListenerProfileModel = fetchListenerProfileModel;
        }
      } else {
        Utils.showToast(
            Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
        Utils.showLog("Get Profile Api Calling Failed !!");
      }
    } else {
      Database.onLogOut();
    }
  }

  // ── Quick Login (device-based anonymous) ──────────────────────────────────
  GetFirebaseUidByDeviceUUidModel? getFirebaseUidByDeviceUUidModel;
  GetFirebaseCustomTokenModel? getFirebaseCustomTokenModel;

  void onQuickLogin1() async {
    final identity =
        (await MobileDeviceIdentifier().getDeviceId()) ?? "";
    Database.onSetIdentity(identity);

    final fcmToken = await FirebaseMessaging.instance.getToken();
    Database.onSetFcmToken(fcmToken ?? "");
    Database.onSetDemoListener(false);

    if (selectedValue != 1) {
      Utils.showToast(Get.context!,
          "Please agree to the Privacy Policy to proceed.");
      return;
    }

    Get.dialog(const LoadingWidget(), barrierDismissible: false);

    print("Database.identity>>>>>>>>>>>>>>>>>>${Database.identity}");
    try {
      getFirebaseUidByDeviceUUidModel =
      await GetFirebaseUidByDeviceApi.callApi(
        loginType: 2,
        deviceUuid: Database.identity,
      );

      if (getFirebaseUidByDeviceUUidModel?.status == true) {
        Utils.showLog("Existing device found!");
        Utils.showLog(
            "Firebase UID => ${getFirebaseUidByDeviceUUidModel?.firebaseId}");

        final getFirebaseCustomTokenModel =
        await GetFirebaseCustomTokenApi.callApi(
          firebaseUid:
          getFirebaseUidByDeviceUUidModel?.firebaseId ?? "",
        );

        if (getFirebaseCustomTokenModel?.status == true) {
          final String customToken =
              getFirebaseCustomTokenModel?.customToken ?? "";
          Utils.showLog("Firebase Custom Token => $customToken");

          final UserCredential userCredential = await FirebaseAuth.instance
              .signInWithCustomToken(customToken);

          Utils.showLog(
              "Signed in with existing Firebase user: ${userCredential.user?.uid}");

          String? fcmToken =
          await FirebaseMessaging.instance.getToken();

          final uid = userCredential.user?.uid ?? "";
          final token = await FirebaseAccessToken.onGet();

          await _completeLoginFlow(uid, token, fcmToken,
              isNewUser: false);
        } else {
          Get.back();
          Utils.showToast(
              Get.context!, "Failed to get custom token");
        }
      } else {
        Utils.showLog(
            "New device detected - creating new anonymous user");

        final UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();

        final String firebaseUid = userCredential.user?.uid ?? "";
        Utils.showLog("New Firebase UID created => $firebaseUid");

        String? fcmToken =
        await FirebaseMessaging.instance.getToken();
        final token = await FirebaseAccessToken.onGet();

        await _completeLoginFlow(firebaseUid, token, fcmToken,
            isNewUser: true);
      }
    } catch (e) {
      Get.back();
      Utils.showLog("Login error: $e");
      Utils.showToast(
          Get.context!, "Login failed. Please try again.");
    }
  }

  Future<void> _completeLoginFlow(
      String uid, String? token, String? fcmToken,
      {required bool isNewUser}) async {
    loginModel = await LoginApi.callApi(
      countryCode: Database.selectedCountryCode,
      loginType: 2,
      email: Database.identity,
      identity: Database.identity,
      fcmToken: Database.fcmToken,
      userName: isNewUser ? randomName : "",
      profilePic: isNewUser ? randomImage : "",
    );

    if (loginModel?.status == true) {
      Database.onSetIsLogin(true);
      Database.onSetLoginType(loginModel?.user?.loginType ?? 0);
      Database.onSetSeenOnboarding(true);
      Database.onSetFillProfile(true);

      await onGetProfile(loginUserId: uid, loginType: 2);

      if (loginModel?.signUp == true) {
        Database.onSetFillProfile(false);

        log("Database.loginUserName  ${Database.loginUserName}");
        log("Database.loginUserProfilePic  ${Database.loginUserProfilePic}");
        log("Database.loginUserEmail  ${Database.loginUserEmail}");

        Get.offAllNamed(AppRoutes.fillProfileScreen, arguments: [
          Database.loginUserName,
          Database.loginUserProfilePic,
          Database.loginUserEmail
        ]);
      } else {
        Database.onSetFillProfile(true);
        await onGetProfile(
            loginUserId: Database.loginUserFirebaseId, loginType: 2);
        if (Database.fetchLoginUserProfileModel?.user?.isListener ==
            true) {
          Get.toNamed(AppRoutes.hostBottomBar);
        } else {
          Get.toNamed(AppRoutes.bottomBar);
        }
      }
    } else {
      Utils.showLog(loginModel?.message ?? "");
      Utils.showLog(" login Api Calling Failed !!");
    }
  }

  // ── Email / Password sign-in (kept, not shown in UI) ──────────────────────
  onClickObscure() {
    log("isObscure :: $isObscure");
    isObscure = !isObscure;
    update();
  }

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool validateLogin() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      Utils.showToast(Get.context!, "Please enter your email");
      return false;
    }
    if (!isEmailValid(email)) {
      Utils.showToast(Get.context!, "Please enter a valid email address");
      return false;
    }
    if (password.isEmpty) {
      Utils.showToast(Get.context!, "Please enter your password");
      return false;
    }
    return true;
  }

  Future<void> onClickSignIn() async {
    if (selectedValue != 1) {
      Utils.showToast(Get.context!,
          "Please agree to the Privacy Policy to proceed.");
      return;
    }
    try {
      Get.dialog(const LoadingWidget(), barrierDismissible: false);
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Database.onSetIsLogin(true);
      Database.onSetSeenOnboarding(true);
      Database.onSetFillProfile(true);
      Database.onSetLoginUserFirebaseId(
          userCredential.user?.uid ?? "");
      if (Get.isDialogOpen ?? false) Get.back();
      log("API BYPASSED: Moving to Home Screen");
      Get.offAllNamed(AppRoutes.bottomBar);
    } on FirebaseAuthException catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Utils.showToast(Get.context!, e.message ?? "Firebase Error");
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.offAllNamed(AppRoutes.bottomBar);
    }
  }

  // ── Google Login (kept, not shown in UI) ──────────────────────────────────
  Future<void> onGoogleLogin() async {
    try {
      if (selectedValue != 1) {
        Utils.showToast(Get.context!,
            "Please agree to the Privacy Policy to proceed.");
        return;
      }

      final identity =
      (await MobileDeviceIdentifier().getDeviceId())!;
      final fcmToken =
      await FirebaseMessaging.instance.getToken();
      Database.onSetFcmToken(fcmToken ?? "");
      Database.onSetIdentity(identity);

      UserCredential? userCredential = await signInWithGoogle();

      String? email = userCredential?.user?.email ??
          (userCredential?.additionalUserInfo?.profile?['email']
          as String?);
      String? displayName = userCredential?.user?.displayName ??
          (userCredential?.additionalUserInfo?.profile?['name']
          as String?);
      String? photoUrl = userCredential?.user?.photoURL ??
          (userCredential?.additionalUserInfo?.profile?['picture']
          as String?);

      if (email != null) {
        Get.dialog(LoadingWidget(), barrierDismissible: false);

        loginModel = await LoginApi.callApi(
          countryCode: Database.selectedCountryCode,
          loginType: 1,
          email: email,
          identity: Database.identity,
          fcmToken: Database.fcmToken,
          userName: displayName ?? "",
          profilePic: Database.loginUserProfilePic.isEmpty
              ? photoUrl
              : Database.loginUserProfilePic,
        );

        if (loginModel?.status == true) {
          Database.onSetIsLogin(true);
          Database.onSetLoginType(loginModel?.user?.loginType ?? 0);
          Database.onSetSeenOnboarding(true);
          Database.onSetFillProfile(true);

          await onGetProfile(
              loginUserId: userCredential!.user!.uid,
              loginType: 1);

          if (loginModel?.signUp == true) {
            Database.onSetFillProfile(false);
            Get.offAllNamed(AppRoutes.fillProfileScreen, arguments: [
              Database.loginUserName,
              Database.loginUserProfilePic,
              Database.loginUserEmail,
            ]);
          } else {
            Database.onSetFillProfile(true);
            await onGetProfile(
                loginUserId: userCredential.user!.uid,
                loginType: 1);
            if (Database.fetchLoginUserProfileModel?.user
                ?.isListener ==
                true) {
              Get.toNamed(AppRoutes.hostBottomBar);
            } else {
              Get.toNamed(AppRoutes.bottomBar);
            }
          }
        } else {
          Utils.showToast(
              Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
        }
      } else {
        Utils.showToast(Get.context!,
            "Google Login Failed: No email found.");
      }
    } catch (e) {
      Utils.showToast(
          Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
      Utils.showLog("Google Login Failed !! Error => $e");
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    Get.dialog(LoadingWidget(), barrierDismissible: false);
    try {
      final GoogleSignInAccount? googleUser =
      await GoogleSignIn().signIn();
      if (googleUser == null) {
        Utils.showToast(
            Get.context!, "Google sign-in was canceled.");
        return null;
      }
      final googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null ||
          googleAuth.idToken == null) {
        Utils.showToast(Get.context!,
            "Google sign-in failed: missing tokens.");
        return null;
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      try {
        final result = await FirebaseAuth.instance
            .signInWithCredential(credential);
        return result;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-credential') {
          Utils.showToast(Get.context!,
              "Sign-in failed: invalid or expired credential.");
        } else if (e.code ==
            'account-exists-with-different-credential') {
          Utils.showToast(Get.context!,
              "This email is linked with a different sign-in method.");
        } else if (e.code == 'network-request-failed') {
          Utils.showToast(Get.context!,
              "Network error. Please check your internet connection.");
        } else {
          Utils.showToast(
              Get.context!, "Sign-in failed: ${e.message}");
        }
        return null;
      }
    } catch (e) {
      Utils.showToast(Get.context!, "Google sign-in error: $e");
      return null;
    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
    }
  }

  // ── Apple Login (kept, not shown in UI) ───────────────────────────────────
  Future<void> onAppleLogin() async {
    if (selectedValue != 1) {
      Utils.showToast(Get.context!,
          "Please agree to the Privacy Policy to proceed.");
      return;
    }

    Get.dialog(const LoadingWidget(), barrierDismissible: false);

    UserCredential? userCredential =
    await AppleAuthentication.signInWithApple();

    bool isNewUser =
        userCredential?.additionalUserInfo?.isNewUser ?? true;

    if (userCredential?.additionalUserInfo?.profile?["email"] !=
        null) {
      String displayName = userCredential?.additionalUserInfo
          ?.profile?["email"]
          ?.split('@')
          .first ??
          randomName;

      Get.dialog(LoadingWidget(), barrierDismissible: false);

      loginModel = await LoginApi.callApi(
        countryCode: Database.selectedCountryCode,
        loginType: 5,
        email: userCredential?.additionalUserInfo?.profile?["email"] ??
            "",
        identity: Database.identity,
        fcmToken: Database.fcmToken,
        userName: isNewUser ? displayName : null,
        profilePic: isNewUser
            ? Database.loginUserProfilePic.isEmpty
            ? randomImage
            : Database.loginUserProfilePic
            : null,
      );

      if (loginModel?.status == true) {
        Database.onSetIsLogin(true);
        Database.onSetLoginType(loginModel?.user?.loginType ?? 0);
        Database.onSetSeenOnboarding(true);
        Database.onSetFillProfile(true);

        await onGetProfile(
            loginUserId: userCredential!.user!.uid, loginType: 5);

        if (loginModel?.signUp == true) {
          Database.onSetFillProfile(false);
          Get.offAllNamed(AppRoutes.fillProfileScreen, arguments: [
            Database.loginUserName,
            Database.loginUserProfilePic,
            Database.loginUserEmail,
          ]);
        } else {
          Database.onSetFillProfile(true);
          await onGetProfile(
              loginUserId: userCredential.user!.uid, loginType: 5);
          if (Database.fetchLoginUserProfileModel?.user?.isListener ==
              true) {
            Get.toNamed(AppRoutes.hostBottomBar);
          } else {
            Get.toNamed(AppRoutes.bottomBar);
          }
        }
      } else {
        Utils.showToast(
            Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
      }
    } else {
      Utils.showToast(
          Get.context!, "Apple Login Failed: No email found.");
    }
  }
}

// ── Apple auth helper (unchanged) ─────────────────────────────────────────────
class AppleAuthentication {
  static Future<UserCredential?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName
          ]);
      final oauthCredential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode);
      final response = await FirebaseAuth.instance
          .signInWithCredential(oauthCredential);
      Utils.showLog(
          "✅ Apple Login isNewUser => ${response.additionalUserInfo?.isNewUser} Email => ${response.additionalUserInfo?.profile?["email"] ?? ""}");
      return response;
    } catch (error) {
      Utils.showLog("❌ Apple Login Error => $error");
    }
    return null;
  }
}