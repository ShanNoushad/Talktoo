import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:talk_in/utils/app_asset.dart';
import '../controller/mobile_login_controller.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late final OtpController controller;
  int _secondsLeft = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OtpController>();
    _startTimer();
    _listenOtp();
  }

  Future<void> _listenOtp() async {
    await SmsAutoFill().unregisterListener();
    await SmsAutoFill().listenForCode();
    SmsAutoFill().code.listen((code) {
      final digits = code.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length == 6) {
        _fillOtp(digits);
        SmsAutoFill().unregisterListener();
      }
    });
  }

  void _fillOtp(String code) {
    for (int i = 0; i < 6; i++) {
      controller.otpControllers[i].text = code[i];
      controller.onOtpChanged(code[i], i);
    }
    setState(() {});
  }

  void _startTimer() {
    _secondsLeft = 60;
    _canResend = false;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _canResend = true;
        }
      });
      return _secondsLeft > 0;
    });
  }

  String get _timerText {
    final mins = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final secs = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Back button ──────────────────────────────────────────
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(
                      color: const Color(0xFF7C4DFF),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── "Talktoo" logo ───────────────────────────────────────
              Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Talk',
                        style: GoogleFonts.nunito(
                          fontSize: 46,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: 'too',
                        style: GoogleFonts.nunito(
                          fontSize: 46,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Hero OTP image ───────────────────────────────────────
              Center(
                child: Image.asset(
                  AppAsset.otpImage,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              // ── "Verify your number" ─────────────────────────────────
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Verify your ',
                        style: GoogleFonts.nunito(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: 'number',
                        style: GoogleFonts.nunito(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ── Subtitle with phone number ───────────────────────────
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: Colors.white60,
                    ),
                    children: [
                      const TextSpan(text: 'Enter the 6-digit code sent to '),
                      TextSpan(
                        text: '${controller.dialCode} ${controller.phoneNumber}',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── OTP boxes ────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _buildOtpBox(i)),
              ),

              const SizedBox(height: 20),

              // ── Resend timer pill ────────────────────────────────────
              Center(
                child: _canResend
                    ? const SizedBox.shrink()
                    : Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFF7C4DFF),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.refresh_rounded,
                        color: Color(0xFF9C27B0),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Resend in $_timerText',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── "Didn't receive?" row ────────────────────────────────
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.white54,
                      ),
                    ),
                    GestureDetector(
                      onTap: _canResend
                          ? () async {
                        await controller.onResendOtp();
                        _startTimer();
                        _listenOtp();
                      }
                          : null,
                      child: Text(
                        'Resend',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _canResend
                              ? const Color(0xFF9C27B0)
                              : Colors.white24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Verify & Continue button ─────────────────────────────
              GestureDetector(
                onTap: () => controller.onVerifyOtp(),
                child: Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7B2FBE),
                        Color(0xFF9C27B0),
                        Color(0xFF6A0DAD),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9C27B0).withOpacity(0.5),
                        blurRadius: 22,
                        spreadRadius: 1,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Verify & Continue',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ── Wrong number? Change number ──────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.white54,
                      ),
                      children: [
                        const TextSpan(text: 'Wrong number? '),
                        TextSpan(
                          text: 'Change number',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF9C27B0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    final bool hasValue =
        controller.otpControllers[index].text.isNotEmpty;

    return SizedBox(
      width: 46,
      height: 56,
      child: TextFormField(
        controller: controller.otpControllers[index],
        focusNode: controller.focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          counterText: '',
          isDense: false,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
          filled: true,
          fillColor: const Color(0xFF150D2E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: hasValue
                  ? const Color(0xFF9C27B0)
                  : const Color(0xFF7C4DFF),
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
            const BorderSide(color: Color(0xFF9C27B0), width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1.8),
          ),
        ),
        onChanged: (value) {
          controller.onOtpChanged(value, index);
          setState(() {});
        },
      ),
    );
  }
}