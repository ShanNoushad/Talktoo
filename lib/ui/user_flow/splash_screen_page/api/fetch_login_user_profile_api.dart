import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../../../../utils/api.dart';
import '../../../../utils/utils.dart';
import '../model/fetch_login_user_profile_model.dart';

class FetchLoginUserProfileApi {
  static Future<FetchLoginUserProfileModel?> callApi({
    required String loginUserId,
    required String token,
  }) async {
    // Utils.showLog("Get Login User Profile Api Calling...");

    final uri = Uri.parse(Api.loginUserProfile);
    // Utils.showLog("Get Login User Profile uri => $uri");

    final headers = {
      "key": Api.secretKey,
      "x-auth-token": "Bearer ${Api.secretKey}",
      "x-auth-uid": loginUserId,  // ← MongoDB _id of the user
      "Content-Type": "application/json",
    };

    // ← ADD THESE TWO LINES


    try {
      final response = await http.get(uri, headers: headers);

      // // ← ADD THIS LINE
      // log("PROFILE API statusCode => ${response.statusCode}");
      // log("PROFILE API response => ${response.body}");

      // Utils.showLog("Get Login User Profile StatusCode => ${response.statusCode}");
      // Utils.showLog("Get Login User Profile Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return FetchLoginUserProfileModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Get Login User Profile StatusCode Error");
      }
    } catch (error) {
      Utils.showLog("Get Login User Profile Api Error => $error");
    }
    return null;
  }
}