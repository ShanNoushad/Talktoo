// To parse this JSON data, do
//
//     final getFirebaseCustomTokenModel = getFirebaseCustomTokenModelFromJson(jsonString);

import 'dart:convert';

GetFirebaseCustomTokenModel getFirebaseCustomTokenModelFromJson(String str) => GetFirebaseCustomTokenModel.fromJson(json.decode(str));

String getFirebaseCustomTokenModelToJson(GetFirebaseCustomTokenModel data) => json.encode(data.toJson());

class GetFirebaseCustomTokenModel {
  final bool? status;
  final String? message;
  final String? customToken;

  GetFirebaseCustomTokenModel({
    this.status,
    this.message,
    this.customToken,
  });

  factory GetFirebaseCustomTokenModel.fromJson(Map<String, dynamic> json) => GetFirebaseCustomTokenModel(
    status: json["status"],
    message: json["message"],
    customToken: json["customToken"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "customToken": customToken,
  };
}
