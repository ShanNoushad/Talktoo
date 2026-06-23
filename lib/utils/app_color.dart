import 'package:flutter/material.dart';

class AppColors {
  // --- Core Brand / Primary ---
  static Color primary = const Color(0xff7C4DFF);         // violet accent
  static Color onBoardingTxt = const Color(0xffA89EC9);   // muted lavender text
  static Color appTextColor = const Color(0xffA0A3B1);    // secondary text
  static Color unSelected = const Color(0xff3A3C52);      // unselected indicators
  static Color lightPurple = const Color(0xff1E2030);     // card surface
  static Color lightPurple1 = const Color(0xff252740);    // slightly elevated surface
  static Color purple200 = const Color(0xff2A2D45);       // elevated card
  static Color backGroundColor = const Color(0xff12131A); // main background
  static Color profileOptionColor = const Color(0xff1A1C2A); // profile tile bg
  static Color grey = const Color(0xff6B6E82);            // muted grey
  static Color darkGrey = const Color(0xffC2C4D0);        // light on dark
  static Color profileText = const Color(0xffB0B3C6);     // profile secondary text
  static Color listenersDetail = const Color(0xff7A7D94); // listener meta text
  static Color otpScreenGrey = const Color(0xff8A8CA0);   // OTP hint
  static Color profileLanguage = const Color(0xff9096B0); // language label
  static Color indicatorColor = const Color(0xff2E3148);  // page indicator
  static Color lightGrey = const Color(0xff1E2030);       // divider / subtle bg
  static Color lightGrey1 = const Color(0xff252638);      // alt subtle bg
  static Color lightGrey200 = const Color(0xff2C2E42);    // border-like bg

  // --- Purple / Accent palette ---
  static Color purple = const Color(0xff7C4DFF);          // primary purple
  static Color purple400 = const Color(0xff9C6FFF);       // lighter purple
  static Color purpleBorder = const Color(0xff3D2E6B);    // purple border
  static Color purple100 = const Color(0xff2D2250);       // deep purple tint
  static Color historyBorder = const Color(0xff252840);   // history card border
  static Color appColor = const Color(0xffEDEEF5);        // primary text (near white)
  static Color appDarkColor = const Color(0xffF5F6FF);    // brightest text

  // --- Semantic colors ---
  static Color green = const Color(0xff00C853);           // online / success green
  static Color orange = const Color(0xffFFAB40);          // warning / coin orange
  static Color lightYellow = const Color(0xff2A2510);     // yellow tint bg
  static Color yellow = const Color(0xffFFD740);          // star / rating yellow
  static Color yellow200 = const Color(0xff2E2A18);       // muted yellow bg
  static Color yellowDark = const Color(0xffB8860B);      // dark gold
  static Color lightYellow100 = const Color(0xff272318);  // very muted yellow bg
  static Color darkOrange = const Color(0xffFF6D00);      // strong orange
  static Color orange200 = const Color(0xffE68A00);       // medium orange
  static Color getCoinText = const Color(0xffFFAB00);     // coin label
  static Color orangeText = const Color(0xffFFB74D);      // soft orange text
  static Color orangeButton = const Color(0xffFFAB40);    // orange CTA
  static Color orangeBorder = const Color(0xff3D2A10);    // orange border
  static Color lightOrange100 = const Color(0xff1E1A10);  // faint orange bg
  static Color yellowDark800 = const Color(0xff6D4200);   // very dark gold
  static Color lightOrange = const Color(0xffFF7043);     // bright light orange
  static Color lightOrange1 = const Color(0xff251C0A);    // ultra-muted orange bg

  // --- Blue ---
  static Color blue = const Color(0xff40C4FF);            // info blue
  static Color lightBlue = const Color(0xff37395A);       // muted blue-grey

  // --- Chat / Special ---
  static Color chatPurple = const Color(0xff7C4DFF);      // chat bubble accent
  static Color darkPurple = const Color(0xff5C5E8A);      // dark muted purple
  static Color profileMail = const Color(0xff8A8C9E);     // mail icon text
  static Color borderColor = const Color(0xff252840);     // general border
  static Color optionColor = const Color(0xff1E2030);     // option tile bg
  static Color border = const Color(0xff1E2038);          // subtle border
  static Color chatCallColor = const Color(0xff1A1C2E);   // chat call bg
  static Color profileOption = const Color(0xff1E2038);   // profile option bg
  static Color chatPink = const Color(0xffFF4081);        // live / hot pink
  static Color yellowBorder = const Color(0xff2A2610);    // yellow border
  static Color setting = const Color(0xff1A1C2E);         // settings bg
  static Color lightRed = const Color(0xff2A1010);        // error bg tint
  static Color historyViewMore = const Color(0xff1E2030); // history load more bg
  static Color historyViewMoreTxt = const Color(0xff7A7C90); // load more text
  static Color historyReasonTxt = const Color(0xff9A8EC8);   // reason text
  static Color notificationTxt = const Color(0xffA0A3B1);    // notification text
  static Color historyCallType = const Color(0xffCCCEDE);    // call type label
  static Color historyDivider = const Color(0xff1E2030);     // list divider

  // --- Random Call ---
  static Color randomCallCoin = const Color(0xffFFAB00);
  static Color randomCallBg = const Color(0xff1E2030);
  static Color randomCallGrey = const Color(0xff3A3C52);
  static Color randomCallPurple = const Color(0xff252240);
  static Color randomCallBorder = const Color(0xff2E2B50);

  // --- ID Container ---
  static Color idContainerColor = const Color(0xff221A38);
  static Color idContainerColor2 = const Color(0xff2A1F45);
  static Color idTxtColor = const Color(0xff9A8CC0);
  static Color idTxtColor2 = const Color(0xffAA8ED0);

  // --- Misc ---
  static Color pink = const Color(0xffFF80AB);
  static Color reviewBackground = const Color(0xff1A1C2A);
  static Color reviewBorder = const Color(0xff252840);
  static Color rateStarColor = const Color(0xffFFD740);
  static Color languageContainer = const Color(0xff1E1C30);
  static Color coinTileColor = const Color(0xff201E08);
  static Color transparent = Colors.transparent;
  static Color white = const Color(0xffEDEEF5);   // "white" softened for dark theme
  static Color black = const Color(0xff12131A);   // "black" = main bg
  static Color red = const Color(0xffFF5252);

  // --- Color list (category chips / avatars bg) ---
  static List<Color> colorList = [
    Color(int.parse('7C4DFF', radix: 16)).withValues(alpha: 0.15),
    Color(int.parse('FFAB40', radix: 16)).withValues(alpha: 0.15),
    Color(int.parse('40C4FF', radix: 16)).withValues(alpha: 0.15),
    Color(int.parse('FF4081', radix: 16)).withValues(alpha: 0.15),
    Color(int.parse('FF5252', radix: 16)).withValues(alpha: 0.15),
    Color(int.parse('00BCD4', radix: 16)).withValues(alpha: 0.15),
  ];

  static LinearGradient primaryLinearGradient = LinearGradient(
    colors: [AppColors.chatPurple, const Color(0xff3D1FA3)],
  );

  static List<Color> textColorList = [
    Color(0xff2A2D45),
    Color(0xff1E2030),
    Color(0xff181A28),
    Color(0xff12131A),
  ];
}