import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/my_profile_screen/widget/my_profile_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/utils.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Column(
        children: [
          MyProfileTopView(),
          Expanded(
            child: ProfileOptionsView(),
          ),
        ],
      ),
    );
  }
}
