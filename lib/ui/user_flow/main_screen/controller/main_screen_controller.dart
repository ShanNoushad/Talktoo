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
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
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
      Get.to(() => WebViewScreen(url: privacyPolicyUrl, screen: "Privacy Policy"));
    } else {
      log('Invalid privacy policy URL');
    }
  }

  // ── Fetch & store full user profile ───────────────────────────────────────
  Future<void> onGetProfile({
    required String loginUserId,
    required int loginType,
  }) async {
    fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(
      loginUserId: loginUserId,
      token: Api.secretKey,
    );
    Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;

    if (loginUserId.trim().isNotEmpty && Api.secretKey.trim().isNotEmpty) {
      if (fetchLoginUserProfileModel?.user?.loginType != null) {
        Database.onSetIsNewUser(false);

        Database.onSetLoginUserId(fetchLoginUserProfileModel!.user!.id!);
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
        Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
      }
    } else {
      Database.onLogOut();
    }
  }

  // ── Quick Login ────────────────────────────────────────────────────────────
  GetFirebaseUidByDeviceUUidModel? getFirebaseUidByDeviceUUidModel;
  GetFirebaseCustomTokenModel? getFirebaseCustomTokenModel;

  void onQuickLogin1() async {
    final identity = (await MobileDeviceIdentifier().getDeviceId()) ?? "";
    Database.onSetIdentity(identity);

    final fcmToken = await FirebaseMessaging.instance.getToken();
    Database.onSetFcmToken(fcmToken ?? "");
    Database.onSetDemoListener(false);

    if (selectedValue != 1) {
      Utils.showToast(Get.context!, "Please agree to the Privacy Policy to proceed.");
      return;
    }

    Get.dialog(const LoadingWidget(), barrierDismissible: false);

    try {
      getFirebaseUidByDeviceUUidModel = await GetFirebaseUidByDeviceApi.callApi(
        loginType: 2,
        deviceUuid: Database.identity,
      );

      if (getFirebaseUidByDeviceUUidModel?.status == true) {
        final getFirebaseCustomTokenModel = await GetFirebaseCustomTokenApi.callApi(
          firebaseUid: getFirebaseUidByDeviceUUidModel?.firebaseId ?? "",
        );

        if (getFirebaseCustomTokenModel?.status == true) {
          final String customToken = getFirebaseCustomTokenModel?.customToken ?? "";
          final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCustomToken(customToken);
          final fcmToken = await FirebaseMessaging.instance.getToken();
          await _completeLoginFlow(
            userCredential.user?.uid ?? "",
            Api.secretKey,
            fcmToken,
            isNewUser: false,
          );
        } else {
          Get.back();
          Utils.showToast(Get.context!, "Failed to get custom token");
        }
      } else {
        final UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();
        final fcmToken = await FirebaseMessaging.instance.getToken();
        await _completeLoginFlow(
          userCredential.user?.uid ?? "",
          Api.secretKey,
          fcmToken,
          isNewUser: true,
        );
      }
    } catch (e) {
      Get.back();
      Utils.showLog("Login error: $e");
      Utils.showToast(Get.context!, "Login failed. Please try again.");
    }
  }

  Future<void> _completeLoginFlow(
      String uid,
      String? token,
      String? fcmToken, {
        required bool isNewUser,
      }) async {


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

      await onGetProfile(
        loginUserId: loginModel?.user?.id ?? '',
        loginType: 2,
      );

      if (loginModel?.signUp == true) {
        Database.onSetFillProfile(false);
        Get.offAllNamed(AppRoutes.fillProfileScreen, arguments: [
          Database.loginUserName,
          Database.loginUserProfilePic,
          Database.loginUserEmail,
        ]);
      } else {
        Database.onSetFillProfile(true);
        await onGetProfile(loginUserId: Database.loginUserId, loginType: 2);
        if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
          Get.toNamed(AppRoutes.hostBottomBar);
        } else {
          Get.toNamed(AppRoutes.bottomBar);
        }
      }
    } else {
      Utils.showLog(loginModel?.message ?? "");
    }
  }

  // ── Email / Password ───────────────────────────────────────────────────────
  onClickObscure() {
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
      Utils.showToast(Get.context!, "Please agree to the Privacy Policy to proceed.");
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
      if (Get.isDialogOpen ?? false) Get.back();
      Get.offAllNamed(AppRoutes.bottomBar);
    } on FirebaseAuthException catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Utils.showToast(Get.context!, e.message ?? "Firebase Error");
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.offAllNamed(AppRoutes.bottomBar);
    }
  }

  // ── Google Login ───────────────────────────────────────────────────────────
  Future<void> onGoogleLogin() async {
    try {
      if (selectedValue != 1) {
        Utils.showToast(Get.context!, "Please agree to the Privacy Policy to proceed.");
        return;
      }

      final identity = (await MobileDeviceIdentifier().getDeviceId())!;
      final fcmToken = await FirebaseMessaging.instance.getToken();
      Database.onSetFcmToken(fcmToken ?? "");
      Database.onSetIdentity(identity);

      UserCredential? userCredential = await signInWithGoogle();

      String? email = userCredential?.user?.email ??
          (userCredential?.additionalUserInfo?.profile?['email'] as String?);
      String? displayName = userCredential?.user?.displayName ??
          (userCredential?.additionalUserInfo?.profile?['name'] as String?);
      String? photoUrl = userCredential?.user?.photoURL ??
          (userCredential?.additionalUserInfo?.profile?['picture'] as String?);

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

          await onGetProfile(
            loginUserId: loginModel?.user?.id ?? '',
            loginType: 1,
          );

          if (loginModel?.signUp == true) {
            Database.onSetFillProfile(false);
            Get.offAllNamed(AppRoutes.fillProfileScreen, arguments: [
              Database.loginUserName,
              Database.loginUserProfilePic,
              Database.loginUserEmail,
            ]);
          } else {
            Database.onSetFillProfile(true);
            if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
              Get.toNamed(AppRoutes.hostBottomBar);
            } else {
              Get.toNamed(AppRoutes.bottomBar);
            }
          }
        } else {
          Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
        }
      } else {
        Utils.showToast(Get.context!, "Google Login Failed: No email found.");
      }
    } catch (e) {
      Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    Get.dialog(LoadingWidget(), barrierDismissible: false);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        Utils.showToast(Get.context!, "Google sign-in was canceled.");
        return null;
      }
      final googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        Utils.showToast(Get.context!, "Google sign-in failed: missing tokens.");
        return null;
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      Utils.showToast(Get.context!, "Sign-in failed: ${e.message}");
      return null;
    } catch (e) {
      Utils.showToast(Get.context!, "Google sign-in error: $e");
      return null;
    } finally {
      if (Get.isDialogOpen ?? false) Get.back();
    }
  }

  // ── Apple Login ────────────────────────────────────────────────────────────
  Future<void> onAppleLogin() async {
    if (selectedValue != 1) {
      Utils.showToast(Get.context!, "Please agree to the Privacy Policy to proceed.");
      return;
    }

    Get.dialog(const LoadingWidget(), barrierDismissible: false);
    UserCredential? userCredential = await AppleAuthentication.signInWithApple();
    bool isNewUser = userCredential?.additionalUserInfo?.isNewUser ?? true;

    if (userCredential?.additionalUserInfo?.profile?["email"] != null) {
      String displayName = userCredential?.additionalUserInfo
          ?.profile?["email"]
          ?.split('@')
          .first ??
          randomName;

      Get.dialog(LoadingWidget(), barrierDismissible: false);

      loginModel = await LoginApi.callApi(
        countryCode: Database.selectedCountryCode,
        loginType: 5,
        email: userCredential?.additionalUserInfo?.profile?["email"] ?? "",
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

        await onGetProfile(
          loginUserId: loginModel?.user?.id ?? '',
          loginType: 5,
        );

        if (loginModel?.signUp == true) {
          Database.onSetFillProfile(false);
          Get.offAllNamed(AppRoutes.fillProfileScreen, arguments: [
            Database.loginUserName,
            Database.loginUserProfilePic,
            Database.loginUserEmail,
          ]);
        } else {
          Database.onSetFillProfile(true);
          if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
            Get.toNamed(AppRoutes.hostBottomBar);
          } else {
            Get.toNamed(AppRoutes.bottomBar);
          }
        }
      } else {
        Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
      }
    } else {
      Utils.showToast(Get.context!, "Apple Login Failed: No email found.");
    }
  }
}

// ── Apple auth helper ──────────────────────────────────────────────────────────
class AppleAuthentication {
  static Future<UserCredential?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ]);
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    } catch (error) {
      Utils.showLog("❌ Apple Login Error => $error");
      return null;
    }
  }
}