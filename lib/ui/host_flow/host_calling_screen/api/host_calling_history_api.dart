// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:http/http.dart' as http;
// import 'package:talk_in/ui/host_flow/host_calling_screen/model/host_calling_history_model.dart';
// import 'package:talk_in/utils/api.dart';
// import 'package:talk_in/utils/api_params.dart';
// import 'package:talk_in/utils/database.dart';
// import 'package:talk_in/utils/utils.dart';
//
// class HostCallingHistoryApi {
//   static int startPagination = 1;
//   static int limitPagination = 20;
//
//   static Future<HostCallingHistoryModel?> callApi({
//     required String endDate,
//     required String startDate,
//     required String listenerId,
//   }) async {
//
//     Utils.showLog("Host Calling History Api Calling...");
//     startPagination += 1;
//
//     final Map<String, dynamic> queryParameters = {
//       ApiParams.startDate: startDate,
//       ApiParams.endDate: endDate,
//       ApiParams.listenerId: listenerId,
//       ApiParams.start: startPagination.toString(),
//       ApiParams.limit: limitPagination.toString(),
//     };
//
//     log("Host Calling History queryParameters ::$queryParameters");
//
//     String query = Uri(queryParameters: queryParameters).query;
//
//     final uri = Uri.parse(Api.listenerCallingHistory + (query.isNotEmpty ? query : ''));
//
//     final headers = {
//       ApiParams.key: Api.secretKey,
//       ApiParams.authToken: 'Bearer ${Api.secretKey}',
//       ApiParams.authUid: Database.loginUserId,
//       ApiParams.contentType: "application/json",
//     };
//     Utils.showLog("Host Calling History Api uri :: $uri");
//     Utils.showLog("Host Calling History Api headers :: $headers");
//
//     try {
//       final response = await http.get(uri, headers: headers);
//
//       log('Host Calling History API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         return HostCallingHistoryModel.fromJson(jsonResponse);
//       } else {
//         throw Exception('Status code is not 200');
//       }
//     } catch (e) {
//       log("Host Calling History :: $e");
//     }
//     return null;
//   }
// }
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/ui/host_flow/host_calling_screen/model/host_calling_history_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

class HostCallingHistoryApi {
  static int startPagination = 1;
  static int limitPagination = 20;

  static Future<HostCallingHistoryModel?> callApi({
    required String endDate,
    required String startDate,
    required String listenerId,
  }) async {

    Utils.showLog("Host Calling History Api Calling...");
    startPagination += 1;

    final Map<String, dynamic> queryParameters = {
      ApiParams.startDate: startDate,
      ApiParams.endDate: endDate,
      ApiParams.listenerId: listenerId,
      ApiParams.start: startPagination.toString(),
      ApiParams.limit: limitPagination.toString(),
    };

    log("Host Calling History queryParameters ::$queryParameters");

    String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse(Api.listenerCallingHistory + (query.isNotEmpty ? query : ''));

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: 'Bearer ${Api.secretKey}',
      ApiParams.authUid: Database.loginUserId,
      ApiParams.contentType: "application/json",
    };
    Utils.showLog("Host Calling History Api uri :: $uri");
    Utils.showLog("Host Calling History Api headers :: $headers");

    try {
      final response = await http.get(uri, headers: headers);

      log('Host Calling History API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return HostCallingHistoryModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("Host Calling History :: $e");
    }
    return null;
  }

  /// Fetches just the single most recent call (start=1, limit=1).
  ///
  /// This is a separate method (not reusing `callApi`) on purpose:
  /// `callApi` increments the shared `startPagination` counter for the
  /// history list's infinite scroll, so calling it from the home screen
  /// would silently break that list's pagination. This method has its
  /// own request and never touches `startPagination`/`limitPagination`.
  static Future<HostCallingHistoryModel?> getLastCall() async {
    Utils.showLog("Get Last Call Api Calling...");

    final Map<String, dynamic> queryParameters = {
      ApiParams.start: '1',
      ApiParams.limit: '1',
    };

    log("Get Last Call queryParameters ::$queryParameters");

    String query = Uri(queryParameters: queryParameters).query;

    final uri = Uri.parse(Api.listenerCallingHistory + (query.isNotEmpty ? query : ''));

    final headers = {
      ApiParams.key: Api.secretKey,
      ApiParams.authToken: 'Bearer ${Api.secretKey}',
      ApiParams.authUid: Database.loginUserId,
      ApiParams.contentType: "application/json",
    };
    Utils.showLog("Get Last Call Api uri :: $uri");

    try {
      final response = await http.get(uri, headers: headers);

      log('Get Last Call API STATUS CODE :: ${response.statusCode} \n RESPONSE :: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return HostCallingHistoryModel.fromJson(jsonResponse);
      } else {
        throw Exception('Status code is not 200');
      }
    } catch (e) {
      log("Get Last Call Api :: $e");
    }
    return null;
  }
}