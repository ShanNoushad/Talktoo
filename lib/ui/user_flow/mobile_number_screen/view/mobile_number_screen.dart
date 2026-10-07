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
                          SizedBox(
                            height: 8,
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
