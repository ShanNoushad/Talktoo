import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/main_screen/model/get_firebase_uid_by_device_u_uid_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/utils.dart';

class GetFirebaseUidByDeviceApi {
  static Future<GetFirebaseUidByDeviceUUidModel?> callApi({
    required String deviceUuid,
    required int loginType,
  }) async {
    try {
      final uri = Uri.parse(
        '${Api.getFirebaseUidByDeviceUuid}'
        '?deviceUuid=$deviceUuid'
        '&loginType=$loginType',
      );

      final headers = {
        ApiParams.key: Api.secretKey,
      };

      Utils.showLog("GetFirebaseUid Api Uri => $uri");
      Utils.showLog("Login Type => $loginType");

      final response = await http.get(uri, headers: headers);

      Utils.showLog("GetFirebaseUid Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return GetFirebaseUidByDeviceUUidModel.fromJson(jsonResponse);
      } else {
        Utils.showLog(
          "GetFirebaseUid Api Failed => ${response.statusCode}",
        );
      }
    } catch (e) {
      Utils.showLog("GetFirebaseUid Api Error => $e");
      Utils.showToast(Get.context!, "Something went wrong");
    }
    return null;
  }
}
