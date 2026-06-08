import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/mobile_number_screen/widget/mobile_number_widget.dart';

class MobileNumberScreen extends StatelessWidget {
  const MobileNumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MobileNumberAppBarView(),      // back arrow (now inline, not CustomAppBar)
            MobileNumberDescriptionView(), // title + subtitle
            MobileNumberOTPView(),         // phone field
            Spacer(),
            MobileNumberButtonView(),      // send OTP button
          ],
        ).paddingOnly(left: 24, right: 24, top: 0),
      ),
    );
  }
}