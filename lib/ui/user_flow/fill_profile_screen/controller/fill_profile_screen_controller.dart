import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk_in/custom/custom_country_picker/country_picker.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/api/edit_profile_api.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/model/edit_profile_model.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class FillProfileScreenController extends GetxController {
  final formKey = GlobalKey<FormState>();
  XFile? xFiles;
  String? name;
  String? email;
  String? photo;
  String? pickImage;
  TextEditingController dateController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController nickNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController flagController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  EditProfileModel? editProfileModel;
  FetchLoginUserProfileModel? fetchLoginUserProfileModel;
  int selectedIndex = 0;
  String? dialCode;

  final ImagePicker imagePicker = ImagePicker();
  dynamic args = Get.arguments;

  @override
  void onInit() async {
    if (Database.loginUserGender.isEmpty) {
      selectedIndex = 0;
      final defaultGender = EnumLocale.txtMale.name.tr;
      genderController.text = defaultGender;
      Database.onSetLoginUserGender(defaultGender);
    } else {
      genderController.text = Database.loginUserGender;
      selectedIndex = Database.loginUserGender.toLowerCase() ==
          EnumLocale.txtFemale.name.tr.toLowerCase()
          ? 1
          : 0;
    }
    nameController.text =
        Database.fetchLoginUserProfileModel?.user?.fullName ?? '';
    emailController.text =
        Database.fetchLoginUserProfileModel?.user?.email ?? '';
    numberController.text =
        Database.fetchLoginUserProfileModel?.user?.phoneNumber ?? '';
    photo = Database.fetchLoginUserProfileModel?.user?.profilePic ?? '';
    dialCode = Database.dialCode;

    super.onInit();
  }

  List<Map<String, dynamic>> gender = [
    {"txt": EnumLocale.txtMale.name.tr, "image": AppAsset.maleImage},
    {"txt": EnumLocale.txtFemale.name.tr, "image": AppAsset.femaleImage},
  ];

  /// select gender
  void selectGender(int index) {
    selectedIndex = index;
    final selectedGenderText = gender[selectedIndex]['txt'] ?? 'Male';
    genderController.text = selectedGenderText;
    Database.onSetLoginUserGender(selectedGenderText ?? 'Male');
    log("Database.loginUserGender :: ${Database.loginUserGender}");
    update([Constant.idGenderSelect]);
  }

  /// select date
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
      DateTime.now().subtract(const Duration(days: 3650)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            colorScheme: ColorScheme.light(
              primary: AppColors.appColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.appColor,
                textStyle: AppFontStyle.fontStyleW600(
                  fontSize: 14,
                  fontColor: AppColors.appColor,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      dateController.text =
      "${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}";
      update();
    }
  }

  /// Get image from gallery
  getImageFromGallery() async {
    xFiles = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 100);
    if (xFiles != null) {
      pickImage = xFiles!.path;
      log("Gallery Image Path ::: $pickImage");
    }
    update();
  }

  /// Get image from camera
  takePhoto() async {
    xFiles = await imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 100);
    if (xFiles != null) {
      pickImage = xFiles!.path;
      log("Camera Image Path ::: $pickImage");
    }
    update();
  }

  /// save profile button on tap
  Future<void> onSaveProfile() async {
    Utils.showLog(
        "Click On Save Profile => ${Database.loginUserId}");

    if (photo == "" && pickImage == null) {
      Utils.showToast(Get.context!,
          EnumLocale.txtPleaseSelectProfileImage.name.tr);
    } else if (nickNameController.text.trim().isEmpty) {
      Utils.showToast(
          Get.context!, EnumLocale.txtPleaseEnterNickName.name.tr);
    } else if (dateController.text.trim().isEmpty) {
      Utils.showToast(Get.context!,
          EnumLocale.txtPleaseSelectBirthDate.name.tr);
    } else if (numberController.text.trim().isEmpty) {
      Utils.showToast(Get.context!,
          EnumLocale.txtPleaseEnterMobileNumber.name.tr);
    } else {
      Get.dialog(const LoadingWidget(),
          barrierDismissible: false);

      await callEditApi();

      // Mark profile as complete
      Database.onSetFillProfile(true);
    }
  }

  /// fill profile api
  Future<void> callEditApi({String? image}) async {
    final token = await FirebaseAccessToken.onGet();

    log('Database.countryCode  ::::  ${Database.selectedCountryCode}');
    editProfileModel = await EditProfileApi.callApi(
      country: countryController.text,
      countryFlag: flagController.text,
      countryCode: Database.selectedCountryCode,
      uid: Database.loginUserFirebaseId,
      birthDate: dateController.text,
      image: pickImage == "" ? photo : pickImage,
      nickName: nickNameController.text,
      gender: Database.loginUserGender,
      phoneNumber: numberController.text,
      fullName: nameController.text,
      email: emailController.text,
    );

    if (editProfileModel?.status == true) {
      // Re-fetch updated profile
      fetchLoginUserProfileModel =
      await FetchLoginUserProfileApi.callApi(
        loginUserId: Database.loginUserFirebaseId,
        token: token ?? '',
      );
      Database.fetchLoginUserProfileModel =
          fetchLoginUserProfileModel;

      // Update all local database fields
      Database.onSetLoginUserProfilePic(
          fetchLoginUserProfileModel?.user?.profilePic ?? "");
      Database.onSetLoginUserName(
          fetchLoginUserProfileModel!.user!.fullName!);
      Database.onSetLoginUserNickName(
          fetchLoginUserProfileModel?.user?.nickName ?? "");
      Database.onSetLoginUserEmail(
          fetchLoginUserProfileModel!.user!.email!);
      Database.onSetLoginUserCountry(
          fetchLoginUserProfileModel!.user!.country!);
      Database.onSetLoginUserCountryFlag(
          fetchLoginUserProfileModel!.user!.countryFlag!);
      Database.onSetLoginUserBirthDate(
          fetchLoginUserProfileModel?.user?.birthDate ?? "");
      Database.onSetLoginUserGender(
          fetchLoginUserProfileModel?.user?.gender ?? "Male");
      Database.onSetLoginUserPhoneNumber(
          fetchLoginUserProfileModel?.user?.phoneNumber ?? "");

      // Mark profile complete so banner disappears on home
      Database.onSetFillProfile(true);

      log(" loginUserProfilePic ::: ${Database.loginUserProfilePic}");
      log("${Database.fetchLoginUserProfileModel?.user}");

      update([Constant.idProfile]);
      update();

      if (Get.isDialogOpen ?? false) Get.back(); // close loader

      // ── Routing ──────────────────────────────────────────────────────
      // If the user came here from the home banner (stack still has home),
      // just pop back so home refreshes via the .then() callback.
      // If they were pushed here from OTP (no home in stack), go to home.
      if (Get.previousRoute == AppRoutes.bottomBar ||
          Get.previousRoute == AppRoutes.hostBottomBar) {
        Get.back(); // return to home; the .then() in HomeScreen triggers update
      } else {
        if (Database.fetchLoginUserProfileModel?.user?.isListener ==
            true) {
          Get.offAllNamed(AppRoutes.hostBottomBar);
        } else {
          Get.offAllNamed(AppRoutes.bottomBar);
        }
      }
    } else {
      if (Get.isDialogOpen ?? false) Get.back();
      Utils.showToast(
          Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
    }
  }

  /// Country select
  Future<void> onChangeCountry(BuildContext context) async {
    debugPrint("onChangeCountry Called");

    CustomCountryPicker.pickCountry(
      context,
      false,
          (country) {
        flagController.text = country.flagEmoji;
        countryController.text = country.name;
        update([Constant.idChangeCountry]);
        debugPrint(
            "Country selected: ${country.name}, Flag: ${country.flagEmoji}");
        Utils.showLog(
            "Selected Country => Flag: ${flagController.text}, Name: ${countryController.text}");
      },
    );

    update([Constant.idChangeCountry]);
  }
}