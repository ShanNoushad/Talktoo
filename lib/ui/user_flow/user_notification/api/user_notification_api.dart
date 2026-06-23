import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/user_notification/model/user_notification_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class UserNotificationApi {
  static int startPagination = 1;
  static int limitPagination = 20;

  static Future<UserNotificationModel?> callApi() async {

    Utils.showLog("User Notification Api Calling...");
    final Map<String, dynamic> queryParameters = {
      ApiParams.start: startPagination.toString(),
      ApiParams.limit: limitPagination.toString(),
    };

    log("user Notification Api queryParameters ::$queryParameters");
    startPagination += 1;

    // final uri = Uri.parse(Api.userNotification);

    String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse(Api.userNotification + query);

    Utils.showLog("User Notification Api url => $uri");

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer ${Api.secretKey}",
      ApiParams.authUid: Database.loginUserId,
      ApiParams.contentType: "application/json",
    };

    try {
      final response = await http.get(uri, headers: headers);

      Utils.showLog("User Notification Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return UserNotificationModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("User Notification Api StateCode Error");
      }
    } catch (e) {
      Utils.showLog("User Notification Api Response => ${e.toString()}");
    }
    return null;
  }
}
