import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/main_screen/controller/main_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';



class MainScreenView extends StatelessWidget {
  const MainScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainScreenController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // ── Bottom wave decoration ─────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(Get.width, 160),
                  painter: _WavePainter(),
                ),
              ),

              // ── Main content ───────────────────────────────────────────
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: Get.height * 0.06),

                      // ── App title "Talk" white + "too" purple ──────────
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Talk',
                                style: GoogleFonts.nunito(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: 'too',
                                style: GoogleFonts.nunito(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF9C27B0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: Get.height * 0.02),

                      // ── Hero image ─────────────────────────────────────
                      Image.asset(
                        AppAsset.mainScreenImage,
                        height: Get.height * 0.36,
                        fit: BoxFit.contain,
                      ),

                      SizedBox(height: Get.height * 0.03),

                      // ── "Welcome back" ─────────────────────────────────
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Welcome ',
                              style: GoogleFonts.nunito(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: 'back',
                              style: GoogleFonts.nunito(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF9C27B0),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ── Subtitle ───────────────────────────────────────
                      Text(
                        'Sign in with your mobile number\nto continue.',
                        textAlign: TextAlign.center,
                        style: AppFontStyle.fontStyleW400(
                          fontSize: 14,
                          fontColor: const Color(0xFF9E9E9E),
                        ),
                      ),

                      SizedBox(height: Get.height * 0.045),

                      // ── Mobile Login button ────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: GestureDetector(
                          onTap: () {
                            if (controller.selectedValue != 1) {
                              Utils.showToast(Get.context!,
                                  "Please agree to the Privacy Policy to proceed.");
                              return;
                            }
                            Get.toNamed(AppRoutes.mobileLogIn);
                          },
                          child: Container(
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF7B2FBE),
                                  Color(0xFF9C27B0),
                                  Color(0xFF6A0DAD),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 6),
                                // Phone icon circle
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.15),
                                  ),
                                  child: const Icon(
                                    Icons.smartphone_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Mobile Login',
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                // Arrow icon
                                Container(
                                  width: 36,
                                  height: 36,
                                  margin: const EdgeInsets.only(right: 10),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: Get.height * 0.03),

                      // ── Privacy policy checkbox ────────────────────────
                      GetBuilder<MainScreenController>(
                        id: Constant.radioButton,
                        builder: (controller) {
                          final isSelected = controller.selectedValue == 1;
                          return GestureDetector(
                            onTap: () => controller.toggleValue(1),
                            child: Container(
                              color: Colors.transparent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Custom circle checkbox
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF9C27B0)
                                            : Colors.white54,
                                        width: 1.5,
                                      ),
                                      color: isSelected
                                          ? const Color(0xFF9C27B0)
                                          : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.check,
                                        color: Colors.white, size: 14)
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'I agree to the ',
                                    style: AppFontStyle.fontStyleW400(
                                      fontSize: 13,
                                      fontColor: Colors.white70,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        controller.onClickPrivacyPolicy(),
                                    child: Text(
                                      'Privacy Policy',
                                      style: AppFontStyle.fontStyleW500(
                                        fontSize: 13,
                                        fontColor: const Color(0xFF9C27B0),
                                        textDecoration:
                                        TextDecoration.underline,
                                        decorationColor:
                                        const Color(0xFF9C27B0),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '.',
                                    style: AppFontStyle.fontStyleW400(
                                      fontSize: 13,
                                      fontColor: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: Get.height * 0.12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Bottom wavy decoration painter ────────────────────────────────────────────
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7B2FBE).withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Wave 1
    final path1 = Path();
    path1.moveTo(0, size.height * 0.6);
    path1.cubicTo(
      size.width * 0.25, size.height * 0.3,
      size.width * 0.55, size.height * 0.85,
      size.width, size.height * 0.5,
    );
    canvas.drawPath(path1, paint);

    // Wave 2
    final paint2 = Paint()
      ..color = const Color(0xFF9C27B0).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.75);
    path2.cubicTo(
      size.width * 0.3, size.height * 0.45,
      size.width * 0.6, size.height * 0.95,
      size.width, size.height * 0.65,
    );
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => false;
}