import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/splash_screen_page/model/setting_api_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

class SettingApi {
  static Future<SettingApiModel?> callApi() async {
    Utils.showLog("Setting Api Calling...");

    final uri = Uri.parse(Api.settingAPi);
    Utils.showLog("Setting uri => $uri");

    final headers = {
      "key": Api.secretKey,
      "Content-Type": "application/json",
      "x-auth-token": "Bearer ${Api.secretKey}",
      "x-auth-uid": Database.loginUserId,  // ← MongoDB _id, not Firebase
    };

    log("Setting api headers $headers");

    try {
      final response = await http.get(uri, headers: headers);
      Utils.showLog("Setting Response.status code => ${response.statusCode}");
      Utils.showLog("Setting Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return SettingApiModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Setting StateCode Error");
      }
    } catch (error) {
      Utils.showLog("Setting Api Error => $error");
    }
    return null;
  }
}