import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/main_screen/model/get_firebase_custom_token_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/utils.dart';

class GetFirebaseCustomTokenApi {
  static Future<GetFirebaseCustomTokenModel?> callApi({
    required String firebaseUid,
  }) async {
    try {
      final uri = Uri.parse(
        '${Api.getFirebaseCustomToken}?firebaseId=$firebaseUid',
      );

      final headers = {
        ApiParams.key: Api.secretKey, // same as Postman header
        'Content-Type': 'application/json',
      };

      Utils.showLog("GetFirebaseCustomToken Api Uri => $uri");
      Utils.showLog("GetFirebaseCustomToken Api Headers => $headers");

      final response = await http.get(uri, headers: headers);

      Utils.showLog(
        "GetFirebaseCustomToken Api Response => ${response.body}",
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return GetFirebaseCustomTokenModel.fromJson(jsonResponse);
      } else {
        Utils.showLog(
          "GetFirebaseCustomToken Api Failed => ${response.statusCode}",
        );
      }
    } catch (e) {
      Utils.showLog("GetFirebaseCustomToken Api Error => $e");
      Utils.showToast(Get.context!, "Something went wrong");
    }
    return null;
  }
}
