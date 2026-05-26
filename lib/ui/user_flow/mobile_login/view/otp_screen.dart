import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/font_style.dart';
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
    // SMS autofill paste listener
    controller.otpControllers[0].addListener(_onFirstBoxChanged);
    _startTimer();
  }

  void _onFirstBoxChanged() {
    final text = controller.otpControllers[0].text;
    if (text.length == 6) {
      controller.onAutofillPaste(text);
      setState(() {});
    }
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
    controller.otpControllers[0].removeListener(_onFirstBoxChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightGrey,
                  ),
                  child: const Icon(Icons.arrow_back, size: 18),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text("TalkToo",
                    style: AppFontStyle.fontStyleKaushanW400(
                        fontSize: 62, fontColor: AppColors.black)),
              ),
              const SizedBox(height: 24),
              Text("Verify your number",
                  style: AppFontStyle.fontStyleW600(
                      fontSize: 20, fontColor: AppColors.black)),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  style: AppFontStyle.fontStyleW400(
                      fontSize: 13, fontColor: AppColors.onBoardingTxt),
                  children: [
                    const TextSpan(text: 'Enter the 6-digit code sent to '),
                    TextSpan(
                      text: '${controller.dialCode} ${controller.phoneNumber}',
                      style: AppFontStyle.fontStyleW600(
                          fontSize: 13, fontColor: AppColors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _buildOtpBox(i)),
              ),
              const SizedBox(height: 20),
              Center(
                child: _canResend
                    ? const SizedBox.shrink()
                    : Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEDFE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Resend in $_timerText",
                    style: AppFontStyle.fontStyleW500(
                        fontSize: 12, fontColor: AppColors.purple),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: AppFontStyle.fontStyleW400(
                          fontSize: 13, fontColor: AppColors.onBoardingTxt),
                    ),
                    GestureDetector(
                      onTap: _canResend
                          ? () async {
                        await controller.onResendOtp();
                        _startTimer();
                      }
                          : null,
                      child: Text(
                        "Resend",
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 13,
                          fontColor: _canResend
                              ? AppColors.purple
                              : AppColors.onBoardingTxt,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => controller.onVerifyOtp(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    "Verify & Continue",
                    style: AppFontStyle.fontStyleW600(
                        fontSize: 16, fontColor: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: RichText(
                    text: TextSpan(
                      style: AppFontStyle.fontStyleW400(
                          fontSize: 13, fontColor: AppColors.onBoardingTxt),
                      children: [
                        const TextSpan(text: 'Wrong number? '),
                        TextSpan(
                          text: 'Change number',
                          style: AppFontStyle.fontStyleW600(
                              fontSize: 13, fontColor: AppColors.purple),
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
    return SizedBox(
      width: 46,
      height: 54,
      child: TextFormField(
        controller: controller.otpControllers[index],
        focusNode: controller.focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        autofillHints: index == 0 ? [AutofillHints.oneTimeCode] : null,
        style: AppFontStyle.fontStyleW600(
            fontSize: 22, fontColor: AppColors.purple),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFFEEEDFE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF534AB7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF534AB7), width: 1.5),
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