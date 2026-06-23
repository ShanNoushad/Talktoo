import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';

class HelpCenterAppBar extends StatelessWidget {
  const HelpCenterAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        title: EnumLocale.txtHelpCenter.name.tr,
        appBarColor: AppColors.lightPurple,
        textColor: AppColors.white,
        showLeadingIcon: true,
      ),
    );
  }
}
