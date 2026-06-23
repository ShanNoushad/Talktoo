import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height,
      width: Get.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          end: Alignment.bottomCenter,
          begin: Alignment.topCenter,
          colors: [
            Color(0xff1A0533), // 🔥 deep dark purple top
            Color(0xff120228), // 🔥 darker purple mid
            Color(0xff0D0118), // 🔥 near black mid
            Color(0xff0A0015), // 🔥 near black mid
            Color(0xff060010), // 🔥 almost black
            Color(0xff000000),
          ],
        ),
      ),
      child: child,
    );
  }
}
