import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/home_screen/model/top_listeners_model.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/controller/random_call_controller.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/widget/random_call_widget.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class RandomCallScreen extends StatefulWidget {
  const RandomCallScreen({super.key});

  @override
  State<RandomCallScreen> createState() => _RandomCallScreenState();
}

class _RandomCallScreenState extends State<RandomCallScreen> {
  final Random _random = Random();
  RandomCallController randomCallController = Get.put(RandomCallController());

  @override
  void initState() {
    super.initState();
    _initializeRandomListeners();
  }

  void _initializeRandomListeners() {
    final shuffled = List<TopListeners>.from(randomCallController.allListener)..shuffle();
    randomCallController.randomDisplayList = shuffled.take(4).toList();

    randomCallController.fadeDurations = List.generate(4, (_) => Duration(seconds: 2 + _random.nextInt(2)));
    randomCallController.delays = List.generate(4, (_) => Duration(milliseconds: 200 + _random.nextInt(1000)));
  }

  void replaceListenerAt(int index) {
    final usedIds = randomCallController.randomDisplayList.map((e) => e.id).toSet();
    final available = randomCallController.allListener.where((e) => !usedIds.contains(e.id)).toList();
    if (available.isEmpty) return;

    final newListener = available[_random.nextInt(available.length)];

    randomCallController.randomDisplayList[index] = newListener;
    randomCallController.fadeDurations[index] = Duration(seconds: 2 + _random.nextInt(2));
    randomCallController.delays[index] = Duration(milliseconds: 200 + _random.nextInt(1000));

    randomCallController.update([Constant.idGetListener]);
  }

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.dark);

    return Scaffold(
      // ── Transparent so the gradient Container underneath shows through ──
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // ── GRADIENT BACKGROUND ──────────────────────────────────────────
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff0D0D1A), // very dark navy — top
              Color(0xff12102B), // deep indigo-black — mid
              Color(0xff1A1040), // dark purple-navy — bottom
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: GetBuilder<RandomCallController>(
          builder: (controller) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Top view ────────────────────────────────────────────
                Column(
                  children: [
                    RandomCallTopView(),
                  ],
                ),

                // ── Ripple animation — tinted to match gradient ─────────
                Positioned(
                  right: -170,
                  top: Get.height * 0.2,
                  child: RippleAnimation(
                    color: Colors.white.withValues(alpha: 0.12),
                    delay: const Duration(milliseconds: 100),
                    repeat: true,
                    minRadius: 200,
                    maxRadius: 170,
                    ripplesCount: 5,
                    duration: const Duration(seconds: 3),
                    child: const SizedBox(
                      height: 310,
                      width: 310,
                    ),
                  ),
                ),

                // ── Dot background (kept, blended with white tint) ──────

                // ── Earth bg (blended) ───────────────────────────────────
                Positioned(
                  right: -140,
                  top: Get.height * 0.2,
                  child: Container(
                    padding: EdgeInsets.zero,
                    height: 270,
                    width: 270,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(AppAsset.randomBg),
                        opacity: 0.18,
                      ),
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),

                // ── Bottom dot bg ────────────────────────────────────────

                // ── Bottom buttons ───────────────────────────────────────
                GetBuilder<RandomCallController>(
                  id: Constant.idGetListener,
                  builder: (context) {
                    return Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: BottomButtonsView(),
                    );
                  },
                ),

                // ── Listener cards list ──────────────────────────────────
                GetBuilder<RandomCallController>(
                  id: Constant.idGetListener,
                  builder: (context) {
                    return Positioned(
                      top: Get.height * 0.18,
                      bottom: Get.height * 0.17,
                      left: (Get.width - 340) / 2,
                      child: SizedBox(
                        width: Get.width * 0.55,
                        child: GetBuilder<RandomCallController>(
                          id: Constant.idGetListener,
                          builder: (controller) {
                            return Column(
                              children: List.generate(
                                controller.allListener.take(4).length,
                                    (index) {
                                  final item = controller.randomDisplayList[index];
                                  bool isLeft = index % 2 == 0;

                                  return Align(
                                    alignment: isLeft
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        Get.toNamed(
                                          AppRoutes.profileDetailScreenView,
                                          arguments: item.id,
                                        );
                                      },
                                      child: SmoothNameTransition(
                                        fadeDuration: randomCallController.fadeDurations[index],
                                        delay: randomCallController.delays[index],
                                        onAnimationComplete: () => replaceListenerAt(index),
                                        key: ValueKey('name-${item.id}-${item.name}'),
                                        childWidget: Stack(
                                          alignment: Alignment.center,
                                          clipBehavior: Clip.none,
                                          children: [
                                            // ── Card bubble ─────────────
                                            Container(
                                              padding: EdgeInsets.only(
                                                left: index == 3 ? 32 : 20,
                                                right: index == 3 ? 14 : 32,
                                                bottom: 7,
                                                top: 7,
                                              ),
                                              decoration: BoxDecoration(
                                                // Semi-transparent white card
                                                color: Colors.white.withValues(alpha: 0.18),
                                                borderRadius: index == 3
                                                    ? const BorderRadius.only(
                                                  bottomRight: Radius.circular(42),
                                                  topRight: Radius.circular(42),
                                                )
                                                    : const BorderRadius.only(
                                                  bottomLeft: Radius.circular(42),
                                                  topLeft: Radius.circular(42),
                                                ),
                                                border: Border.all(
                                                  color: Colors.white.withValues(alpha: 0.55),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    item.name ?? '',
                                                    style: AppFontStyle.fontStyleW700(
                                                      fontSize: 12,
                                                      fontColor: AppColors.white,
                                                    ),
                                                  ).paddingOnly(bottom: 3),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 6, vertical: 1),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(46),
                                                      gradient: const LinearGradient(
                                                        colors: [
                                                          Color(0xffCF00FD),
                                                          Color(0xff8400FF),
                                                        ],
                                                      ),
                                                    ),
                                                    child: Text(
                                                      " ${item.talkTopics?[0] ?? ''}  ",
                                                      style: AppFontStyle.fontStyleW600(
                                                        fontSize: 10,
                                                        fontColor: AppColors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // ── Avatar circle ────────────
                                            Positioned(
                                              left: index == 3 ? -36 : null,
                                              right: index == 3 ? null : -36,
                                              child: Container(
                                                width: 62,
                                                height: 62,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    width: 4,
                                                    color: Colors.white.withValues(alpha: 0.8),
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(0xffCF00FD)
                                                          .withValues(alpha: 0.3),
                                                      blurRadius: 8,
                                                      offset: const Offset(1, 1),
                                                      spreadRadius: 2.5,
                                                    ),
                                                  ],
                                                  shape: BoxShape.circle,
                                                ),
                                                child: ClipOval(
                                                  child: CustomProfileImage(
                                                    image: item.image ?? '',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ).paddingOnly(bottom: Get.height * 0.045);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),

                // ── Loading overlay ──────────────────────────────────────
                if (controller.isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Center(
                        child: LoadingAnimationWidget.threeArchedCircle(
                          color: AppColors.appColor,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// SmoothNameTransition — unchanged
// ────────────────────────────────────────────────────────────────────────────

class SmoothNameTransition extends StatefulWidget {
  final String? name;
  final VoidCallback onAnimationComplete;
  final Duration fadeDuration;
  final Duration delay;
  final Widget childWidget;

  const SmoothNameTransition({
    super.key,
    this.name,
    required this.onAnimationComplete,
    required this.fadeDuration,
    required this.delay,
    required this.childWidget,
  });

  @override
  SmoothNameTransitionState createState() => SmoothNameTransitionState();
}

class SmoothNameTransitionState extends State<SmoothNameTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isReversing = false;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.fadeDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart),
    );

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isReversing) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            _isReversing = true;
            _controller.reverse();
          }
        });
      } else if (status == AnimationStatus.dismissed && _isReversing) {
        widget.onAnimationComplete();
        _isReversing = false;
        _controller.forward();
      }
    });

    Future.delayed(widget.delay, () {
      if (mounted && !_hasStarted) {
        _hasStarted = true;
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final fadeValue = _fadeAnimation.value.clamp(0.0, 1.0);
        final scaleValue = _scaleAnimation.value.clamp(0.95, 1.05);

        return Transform.scale(
          scale: scaleValue,
          child: Opacity(
            opacity: fadeValue,
            child: widget.childWidget,
          ),
        );
      },
    );
  }
}