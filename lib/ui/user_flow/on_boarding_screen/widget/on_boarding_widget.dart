import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/on_boarding_screen/controller/on_boarding_controller.dart';
import 'package:talk_in/utils/constant.dart';

class OnBoardingView extends StatelessWidget {
  const OnBoardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnBoardingController>(
      id: Constant.idOnBoarding,
      builder: (logic) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: logic.pageController,
                  onPageChanged: (int page) {
                    logic.onPageChanged(page: page);
                  },
                  itemCount: logic.title.length,
                  itemBuilder: (context, index) {
                    return OnboardingItemView(
                      title: logic.title[index],
                      image: logic.image[index],
                      subTitle: logic.subTitle[index],
                      pageIndex: index,
                    );
                  },
                ),
              ),
              _buildBottomBar(logic),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(OnBoardingController logic) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 16, bottom: 48, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Page indicator dots
          Row(
            children: List.generate(logic.title.length, (index) {
              bool isSelected = index == logic.currentPage;
              return AnimatedContainer(
                margin: const EdgeInsets.only(right: 5),
                width: isSelected ? 28 : 14,
                height: 5,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                    colors: [Color(0xFFE040FB), Color(0xFF7C4DFF)],
                  )
                      : null,
                  color: isSelected ? null : const Color(0xFF3A2A5A),
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(milliseconds: 300),
              );
            }),
          ),

          // Next arrow button
          GestureDetector(
            onTap: () {
              logic.onPageScroll(currentPage: logic.currentPage);
            },
            child: Container(
              width: 120,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color(0xFFAA00FF),
                  width: 1.5,
                ),
                gradient: const LinearGradient(
                  colors: [Color(0x33AA00FF), Color(0x1100BFFF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItemView extends StatelessWidget {
  final String title;
  final String image;
  final String subTitle;
  final int pageIndex;

  const OnboardingItemView({
    super.key,
    required this.title,
    required this.image,
    required this.subTitle,
    required this.pageIndex,
  });

  // Per-page config matching the screenshots
  List<Color> get _titleGradient {
    switch (pageIndex) {
      case 0: // CHAT
        return [const Color(0xFFAA00FF), const Color(0xFF00E5FF)];
      case 1: // FIND YOUR PEOPLE
        return [const Color(0xFFE040FB), const Color(0xFF00E5FF)];
      case 2: // VIDEO CALL
        return [const Color(0xFFE040FB), const Color(0xFF00E5FF)];
      default:
        return [const Color(0xFFAA00FF), const Color(0xFF00E5FF)];
    }
  }



  String get _tagLine {
    switch (pageIndex) {
      case 0:
        return 'Your Conversation Heal.';
      case 1:
        return 'Real conversations. Real support.\nMeaningful connections that heal.';
      case 2:
        return '';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),

        // Hero image
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          child: Image.asset(
            image,
            height: 320,
            fit: BoxFit.contain,
          ),
        ),

        // Title with gradient
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: _titleGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Underline accent
        Container(
          margin: const EdgeInsets.only(top: 6, bottom: 16),
          width: 80,
          height: 2.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _titleGradient,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _buildSubtitle(),
        ),

        // Tag line
        if (_tagLine.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 28, right: 28),
            child: _buildTagLine(),
          ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSubtitle() {
    if (pageIndex == 0) {
      // "Mind matters. We are here for you."
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          children: [
            TextSpan(
              text: 'Mind ',
              style: TextStyle(
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [Color(0xFFE040FB), Color(0xFF7C4DFF)],
                  ).createShader(const Rect.fromLTWH(0, 0, 60, 30)),
              ),
            ),
            const TextSpan(
                text: 'matters.\nWe are here for you.',
                style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    } else if (pageIndex == 1) {
      // "FIND YOUR" small + "PEOPLE" big gradient + "YOU'RE NOT ALONE."
      return Column(
        children: [
          const Text(
            'FIND YOUR',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9C27B0),
              letterSpacing: 3,
            ),
            textAlign: TextAlign.center,
          ),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFE040FB), Color(0xFF00E5FF)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds),
            child: const Text(
              'PEOPLE',
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2),
              children: [
                TextSpan(text: "YOU'RE "),
                TextSpan(
                    text: 'NOT',
                    style: TextStyle(
                        color: Color(0xFFE040FB),
                        fontStyle: FontStyle.italic)),
                TextSpan(text: ' ALONE.'),
              ],
            ),
          ),
        ],
      );
    } else {
      // VIDEO CALL subtitle
      return RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.w400),
          children: [
            TextSpan(text: 'Connect '),
            TextSpan(
                text: 'Face-to-Face,\n',
                style: TextStyle(color: Color(0xFFCE93D8))),
            TextSpan(
                text: 'Share',
                style: TextStyle(color: Color(0xFFCE93D8))),
            TextSpan(text: ' & '),
            TextSpan(
                text: 'Validate',
                style: TextStyle(color: Color(0xFFCE93D8))),
            TextSpan(text: ',\n'),
            TextSpan(
                text: 'Feel Real',
                style: TextStyle(color: Color(0xFFCE93D8))),
            TextSpan(text: ' Emotional Support.'),
          ],
        ),
      );
    }
  }

  Widget _buildTagLine() {
    if (pageIndex == 0) {
      return Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: const Color(0xFF7C4DFF).withOpacity(0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.white70),
                children: [
                  TextSpan(
                      text: 'Your ',
                      style: TextStyle(color: Color(0xFFCE93D8))),
                  TextSpan(text: 'Conversation '),
                  TextSpan(
                      text: 'Heal.',
                      style: TextStyle(color: Color(0xFF00E5FF))),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: const Color(0xFF7C4DFF).withOpacity(0.5),
            ),
          ),
        ],
      );
    } else if (pageIndex == 1) {
      return Column(
        children: [
          Container(
            width: 30,
            height: 1,
            color: const Color(0xFF7C4DFF).withOpacity(0.6),
            margin: const EdgeInsets.only(bottom: 10),
          ),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(fontSize: 14, color: Colors.white60),
              children: [
                TextSpan(text: 'Real conversations. Real support.\nMeaningful connections that '),
                TextSpan(
                    text: 'heal.',
                    style: TextStyle(
                        color: Color(0xFFE040FB),
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}