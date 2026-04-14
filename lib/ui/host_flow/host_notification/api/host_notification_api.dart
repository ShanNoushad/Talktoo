import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/host_flow/host_notification/model/host_notification_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/firebse_access_token.dart';
import 'package:talk_in/utils/utils.dart';

class HostNotificationApi {
  static int startPagination = 1;
  static int limitPagination = 20;

  static Future<HostNotificationModel?> callApi() async {
    final token = await FirebaseAccessToken.onGet() ?? "";

    Utils.showLog("Host Notification Api Calling...");

    final Map<String, dynamic> queryParameters = {
      ApiParams.listenerId: Database.fetchListenerProfileModel?.data?.id,
      ApiParams.start: startPagination.toString(),
      ApiParams.limit: limitPagination.toString(),
    };

    log("Host Notification Api queryParameters ::$queryParameters");
    startPagination += 1;

    // String query = Uri(queryParameters: queryParameters).query;

    // final uri = Uri.parse("${Api.notificationListener}${ApiParams.listenerId}=${Database.fetchListenerProfileModel?.data?.id}");

    String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse(Api.notificationListener + query);

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: "Bearer $token",
      ApiParams.authUid: Database.loginUserFirebaseId,
      ApiParams.contentType: "application/json",
    };
    log("Host Notification Api URL ::$uri");
    log("Host Notification Api URL ::$headers");

    try {
      final response = await http.get(uri, headers: headers);

      Utils.showLog("Host Notification Api Response => ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return HostNotificationModel.fromJson(jsonResponse);
      } else {
        Utils.showLog("Host Notification Api StateCode Error");
      }
    } catch (e) {
      Utils.showLog("Host Notification Api Response => ${e.toString()}");
    }
    return null;
  }
}
