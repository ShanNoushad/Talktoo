// Replace your MobileLoginScreen / MobileNumberScreen scaffold with this:

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/mobile_number_screen/controller/mobile_number_controller.dart';

import '../../../../custom/progress_indicator/progress_dialog.dart';
import '../../../../main.dart';
import '../../../../routes/app_routes.dart';
import '../../../../socket/socket_service.dart';
import '../../../../utils/api.dart';
import '../../../../utils/database.dart';
import '../../../../utils/utils.dart';
import '../../splash_screen_page/api/fetch_login_user_profile_api.dart';
import '../widget/mobile_number_widget.dart';

class MobileNumberScreen extends StatelessWidget {
  const MobileNumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MobileNumberController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0818),
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  const MobileNumberAppBarView(),

                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const MobileNumberDescriptionView(),
                          const MobileNumberOTPView(),
SizedBox(height: 8,),
                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                Get.dialog(const LoadingWidget(), barrierDismissible: false);
                            
                                try {
                                  final profile = await FetchLoginUserProfileApi.callApi(
                                    loginUserId: "6a2fc2e86413f46b43bcd69a",
                                    token: Api.secretKey,
                                  );
                            
                                  Database.fetchLoginUserProfileModel = profile;
                            
                                  if (profile?.user == null) {
                                    Utils.showToast(Get.context!, "John's profile not found in DB");
                                    return;
                                  }
                            
                                  final user = profile!.user!;
                            
                                  await Database.onSetIsNewUser(false);
                                  await Database.onSetUserCoin("100");
                                  await Database.onSetIsLogin(true);
                                  await Database.onSetFillProfile(true);
                                  await Database.onSetSeenOnboarding(true);
                                  await Database.onSetLoginType(user.loginType ?? 3);
                                  await Database.onSetLoginUserId(user.id ?? '');
                                  await Database.onSetLoginUserFirebaseId(user.firebaseId ?? '');
                                  await Database.onSetLoginUserName(user.fullName ?? '');
                                  await Database.onSetLoginUserNickName(user.nickName ?? '');
                                  await Database.onSetLoginUserEmail(user.email ?? '');
                                  await Database.onSetLoginUserProfilePic(user.profilePic ?? '');
                                  await Database.onSetLoginUserCountry(user.country ?? '');
                                  await Database.onSetLoginUserCountryFlag(user.countryFlag ?? '');
                                  await Database.onSetLoginUserBirthDate(user.birthDate ?? '');
                                  await Database.onSetLoginUserGender(user.gender ?? 'Male');
                                  await Database.onSetLoginUserPhoneNumber(user.phoneNumber ?? '');
                                  await Database.onSetUserCoin(user.coins?.toString() ?? '0');
                            
                                  try {
                                    final fcmToken = await FirebaseMessaging.instance.getToken();
                                    Utils.showLog("Dev Login - FCM token: $fcmToken");
                                    if (fcmToken != null) {
                                      await syncFcmTokenToBackend(fcmToken);
                                    }
                                  } catch (e) {
                                    Utils.showLog("Dev Login - FCM sync failed: $e");
                                  }
                            
                                  try {
                                    await SocketService.socketConnect();
                                  } catch (e) {
                                    Utils.showLog("Dev Login - Socket connect failed: $e");
                                  }
                            
                                  if (user.isListener == true) {
                                    Get.offAllNamed(AppRoutes.hostBottomBar);
                                  } else {
                                    Get.offAllNamed(AppRoutes.bottomBar);
                                  }
                                } catch (e) {
                                  Utils.showToast(Get.context!, "Bypass failed: $e");
                                } finally {
                                  if (Get.isDialogOpen ?? false) Get.back();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                elevation: 1,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFB43DFF),
                                      Color(0xFF8A00D4),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF8A00D4),
                                      blurRadius: 15,
                                      offset: Offset(0, 5),
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 24,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Continue as Guest",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),

                  // Get OTP button pinned at bottom
                  const MobileNumberButtonView(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}