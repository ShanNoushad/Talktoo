import 'package:flutter/material.dart';
import 'package:talk_in/ui/host_flow/host_setting_screen/widget/host_setting_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/utils.dart';

class HostSettingScreen extends StatelessWidget {
  const HostSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.dark);
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const HostSettingScreenAppBar(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            HostSettingView(),
          ],
        ),
      ),
    );
  }
}
