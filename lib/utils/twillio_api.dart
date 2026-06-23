import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:talk_in/utils/api.dart';

class TwilioApi {
  // Example:
  // static const String otpUrl = "http://168.144.85.67:3000/api/otp";
  static const String _baseUrl = Api.otpUrl;

  /// Send OTP
  static Future<bool> sendOtp({
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/send"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "phoneNumber": phoneNumber,
        }),
      );

      log("Send OTP Status Code: ${response.statusCode}");
      log("Send OTP Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["success"] == true;
      }

      return false;
    } catch (e) {
      log("TwilioApi sendOtp Error: $e");
      return false;
    }
  }

  /// Verify OTP
  static Future<bool> verifyOtp({
    required String phoneNumber,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/verify"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "phoneNumber": phoneNumber,
          "code": code,
        }),
      );

      log("Verify OTP Status Code: ${response.statusCode}");
      log("Verify OTP Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["success"] == true;
      }

      return false;
    } catch (e) {
      log("TwilioApi verifyOtp Error: $e");
      return false;
    }
  }
}