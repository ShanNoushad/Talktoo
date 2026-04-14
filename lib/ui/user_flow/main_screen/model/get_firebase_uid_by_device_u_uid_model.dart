// To parse this JSON data, do
//
//     final getFirebaseUidByDeviceUUidModel = getFirebaseUidByDeviceUUidModelFromJson(jsonString);

import 'dart:convert';

GetFirebaseUidByDeviceUUidModel getFirebaseUidByDeviceUUidModelFromJson(String str) => GetFirebaseUidByDeviceUUidModel.fromJson(json.decode(str));

String getFirebaseUidByDeviceUUidModelToJson(GetFirebaseUidByDeviceUUidModel data) => json.encode(data.toJson());

class GetFirebaseUidByDeviceUUidModel {
  bool? status;
  String? message;
  String? firebaseId;

  GetFirebaseUidByDeviceUUidModel({
    this.status,
    this.message,
    this.firebaseId,
  });

  factory GetFirebaseUidByDeviceUUidModel.fromJson(Map<String, dynamic> json) => GetFirebaseUidByDeviceUUidModel(
        status: json["status"],
        message: json["message"],
        firebaseId: json["firebaseId"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "firebaseId": firebaseId,
      };
}
