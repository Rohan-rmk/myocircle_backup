import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';


String _client_key = "VKpWmI2vQQ5laYXZjR4DgKBPcxvj0q5Bnty8";

class ForgotPinProvider extends ChangeNotifier {
  List familyMembers = [];
  int? selectedProfileId;
  String? selectedUserType;
  bool loading = false;
  String? message;
  int? userId;
  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'client_key': _client_key,
  };
  Future<bool> sendOtp(String email) async {

    loading = true;
    notifyListeners();

    try {

      // final url = "https://api.myocircle.com/api/app/forgotPasswordPatient";
      final url = "${ApiService.baseUrl}/forgotPasswordPatient";

      final body = {
        "email": email
      };

      print("Forgot PIN API REQUEST: $body");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print("Forgot PIN API RESPONSE: ${response.body}");

      final data = jsonDecode(response.body);

      /// Save API message
      message = data["message"] ?? data["data"]?["message"];

      /// Success case
      if (data["status"] == "success") {

        userId = data["data"]["userId"];

        loading = false;
        notifyListeners();

        return true;
      }

    } catch (e) {
      print("Forgot PIN API ERROR: $e");
      message = "Something went wrong";
    }

    loading = false;
    notifyListeners();

    return false;
  }
  ///
  Future<bool> verifyOtp(String email, String otp) async {

    loading = true;
    notifyListeners();

    try {

      // final url = "https://api.myocircle.com/api/app/verifyOtpPatient";
      final url = "${ApiService.baseUrl}/verifyOtpPatient";
      final body = {
        "email": email,
        "otp": int.parse(otp)
      };

      print("VERIFY OTP BODY: $body");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print("VERIFY OTP RESPONSE: ${response.body}");

      final data = jsonDecode(response.body);

      if (data["code"] == 200) {

        message = data["data"]["message"];
        userId = data["data"]["userId"];
        familyMembers = data["data"]["familyMembers"];

        /// reset previous selection
        selectedProfileId = null;
        selectedUserType = null;

        if (familyMembers.length == 1) {
          selectedProfileId = familyMembers[0]["profileId"];
          selectedUserType = familyMembers[0]["role"];
        }

        loading = false;
        notifyListeners();

        return true;
      }

    } catch (e) {
      print(e);
    }

    loading = false;
    notifyListeners();

    return false;
  }
///
  Future<bool> resetPin(int newPin) async {

    loading = true;
    notifyListeners();

    try {

      // final url = "https://api.myocircle.com/api/app/resetPatientPin";
      final url = "${ApiService.baseUrl}/resetPatientPin";

      final body = {
        "profileId": selectedProfileId,
        "userId": userId,
        "userType": selectedUserType,
        "newPin": newPin
      };

      print("RESET PIN BODY: $body");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print("RESET PIN RESPONSE: ${response.body}");

      final data = jsonDecode(response.body);

      /// SAVE MESSAGE FROM API
      message = data["message"];

      if (data["success"] == true || data["status"] == 200) {

        loading = false;
        notifyListeners();

        return true;
      }

    } catch (e) {
      print(e);
    }

    loading = false;
    notifyListeners();

    return false;
  }
}