import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:talk_in/ui/user_flow/my_wallet_screen/model/fetch_coin_plan.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/api_params.dart';

class FetchCoinPlanApi {
  static Future<FetchCoinPlan?> callApi({
    required String uid,
    required String token,
  }) async {

    final uri = Uri.parse(Api.fetchCoinPlan);


    final headers = {ApiParams.key: Api.secretKey, ApiParams.authToken: ApiParams.tokenStartPoint + token, ApiParams.authUid: uid};

    try {
      final response = await http.get(uri, headers: headers);


      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        return FetchCoinPlan.fromJson(jsonResponse);
      } else {
      }
    } catch (error) {
    }
    return null;
  }
}
