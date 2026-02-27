import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import '../components/loading_animation.dart';
import 'applife_cycle_manager.dart';
import 'notification_service.dart';


void logApi({
  required String apiName,
  Map<String, dynamic>? request,
  dynamic response,
}) {
  print("══════════════════════════════════════");
  print("API CALL : $apiName");

  if (request != null) {
    print("REQUEST :");
    request.forEach((key, value) {
      print("  $key : $value");
    });
  }

  print("RESPONSE :");
  print(response);

  print("══════════════════════════════════════");
}

class ApiService {
  static OverlayEntry? _loaderOverlay;
  static Future<void> _showPopup(BuildContext context, String message,
      {String? title, PopupType type = PopupType.info}) async {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    // Define default titles and colors
    title ??= {
      PopupType.success: 'Success',
      PopupType.error: 'Error',
      PopupType.warning: 'Warning',
      PopupType.info: 'Info',
    }[type]!;

    final icon = {
      PopupType.success: Icons.check_circle,
      PopupType.error: Icons.error,
      PopupType.warning: Icons.warning,
      PopupType.info: Icons.info,
    }[type]!;

    final color = {
      PopupType.success: Colors.green,
      PopupType.error: Colors.red,
      PopupType.warning: Colors.orange,
      PopupType.info: Colors.blue,
    }[type]!;

    if (isIOS) {
      return showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text(title!),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } else {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(title!),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  static void _showFullScreenLoader(BuildContext context) {
    if (_loaderOverlay != null) return;

    _loaderOverlay = OverlayEntry(
      builder: (_) => const FullScreenLoader(),
    );

    final overlay = Overlay.of(context);
    if (overlay != null && _loaderOverlay != null) {
      if (context.mounted) {
        overlay.insert(_loaderOverlay!);
      }
    }
  }

  static void _hideFullScreenLoader() {
    _loaderOverlay?.remove();
    _loaderOverlay = null;
  }

  // static const String baseUrl = 'https://apps.healthfax.ai/MyoCirclev2/app';
  // static const String baseUrl = 'https://apps.healthfax.ai/MyoCirclev4/app';
  static const String baseUrl = 'https://api.myocircle.com/api/app';
  static const String _client_key = "VKpWmI2vQQ5laYXZjR4DgKBPcxvj0q5Bnty8";
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'client_key': _client_key, // Replace with actual client key
  };

  /// POST call with loading banner and error handling
  static Future<Map<String, dynamic>> postWithBanner({
    required BuildContext context,
    required String text,
    required bool value,
    required bool loadLoader,
    required String endpoint,
    required Map<String, dynamic> body,
    Map<String, String>? customHeaders,
    // String baseURL = 'https://apps.healthfax.ai/MyoCirclev2/app',
    String baseURL = 'https://api.myocircle.com/api/app',
  }) async {
    if (loadLoader == true) {
      _showFullScreenLoader(context);
    }
    ActivityMonitor.start();
    final uri = Uri.parse('$baseURL/$endpoint');
    final requestHeaders = customHeaders ?? headers;
    try {

      debugPrint("══════════════════════════════════════");
      debugPrint("API CALL : POST");
      debugPrint("URL      : $uri");
      debugPrint("HEADERS  : $requestHeaders");
      debugPrint("PAYLOAD  : $body");
      debugPrint("══════════════════════════════════════");

      final response = await http.post(
        Uri.parse('$baseURL/$endpoint'),
        headers: customHeaders ?? headers,
        body: jsonEncode(body),
      );

      if (loadLoader == true) {
        _hideFullScreenLoader();
      }



      return _processResponse(response, value, context);
    } on SocketException catch (_) {
      if (loadLoader == true) {
        _hideFullScreenLoader();
      }
      if (context.mounted)
        await _showPopup(context,
            "Connection refused. Please check your internet or try again later.",
            type: PopupType.error);
      return {"status": 500, "message": "Connection refused"};
    } catch (e) {
      if (loadLoader == true) {
        _hideFullScreenLoader();
      }
      if (context.mounted)
        await _showPopup(context, "Something went wrong: $e",
            type: PopupType.error);
      print(e);
      return {"status": 500, "message": "Unexpected error"};
    } finally {
      ActivityMonitor.end();
    }
  }

  static void _showLoadingBanner(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$text... Please wait',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 10,
            ),
            SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeCap: StrokeCap.round,
                  strokeWidth: 2,
                )),
          ],
        ),
        backgroundColor: Colors.black54,
        actions: [SizedBox.shrink()],
      ),
    );
  }

  /// Authenticate user with unique ID and verification code
  static Future<Map<String, dynamic>> authenticateUser(
      BuildContext context, String uniqueId, int verificationCode) async {
    //
    // final response = await http.post(
    //   Uri.parse('$baseUrl/authenticateUser'),
    //   headers: headers,
    //   body: jsonEncode({
    //     'uniqueId': uniqueId,
    //     'verificationCode': verificationCode
    //   }),
    // );
    //
    // return _processResponse(response);
    return await postWithBanner(
      text: "Registering",
      value: true,
      loadLoader: true,
      context: context,
      endpoint: 'authenticateUser',
      body: {'uniqueId': uniqueId, 'verificationCode': verificationCode},
    );
  }

  /// Set PIN for the user
  static Future<Map<String, dynamic>> setPin(
      BuildContext context, int profileId, int userId, int pin) async {
    // final response = await http.post(
    //   Uri.parse('$baseUrl/setPin'),
    //   headers: headers,
    //   body: jsonEncode({
    //     'profileId': profileId,
    //     'userId': userId,
    //     'pin': pin
    //   }),
    // );
    //
    // return _processResponse(response);

    return await postWithBanner(
      text: "Setting Pin",
      value: true,
      loadLoader: true,
      context: context,
      endpoint: 'setPin',
      body: {'profileId': profileId, 'userId': userId, 'pin': pin},
    );
  }

  /// Login user using PIN and unique ID
  static Future<Map<String, dynamic>> login(
      BuildContext context, String uniqueId, int pin, bool showPopup) async {
    // final response = await http.post(
    //   Uri.parse('$baseUrl/login'),
    //   headers: headers,
    //   body: jsonEncode({
    //     'pin': pin,
    //     'uniqueId': uniqueId
    //   }),
    // );
    //
    // return _processResponse(response);

    return await postWithBanner(
      text: "Logging in",
      value: showPopup,
      loadLoader: true,
      context: context,
      endpoint: 'login',
      // body: {'pin': pin, 'uniqueId': uniqueId,'fcmtoken':fcmToken},
      body: {'pin': pin, 'uniqueId': uniqueId},
    );
  }

  /// Logout user
  static Future<Map<String, dynamic>> logout(
    BuildContext context,
    String userToken,
    int profileId,
    String sessionId,
    int userId,
  ) async {
    return await postWithBanner(
      text: "Logging out",
      value: true,
      loadLoader: true,
      context: context,
      customHeaders: {
        ...headers,
        'user_token': userToken,
      },
      endpoint: 'logout',
      body: {
        "profileId": profileId,
        "sessionId": sessionId,
        "userId": userId,
      },
    );
  }

  /// Get consent text
  static Future<Map<String, dynamic>> getConsentText(
      String userToken, BuildContext context) async {
    ActivityMonitor.start();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getConsentText'),
        headers: {
          ...headers,
          'user_token': userToken,
        },
      );

      return _processResponse(response, false, context);
    } finally {
      ActivityMonitor.end();
    }
  }

  /// Record consent
  static Future<Map<String, dynamic>> recordConsent(BuildContext context,
      String userToken, int profileId, int userId, String selfieCamera) async {
    // final response = await http.post(
    //   Uri.parse('$baseUrl/recordConsent'),
    //   headers: {
    //     ...headers,
    //     'user_token': userToken,
    //   },
    //   body: jsonEncode({
    //     'profileId': profileId,
    //     'userId': userId,
    //     "termsAccepted": "Agree",
    //     "selfieCamera": selfieCamera,
    //   }),
    // );

    // return _processResponse(response);

    return await postWithBanner(
      text: "Recording consent",
      value: true,
      loadLoader: true,
      context: context,
      customHeaders: {
        ...headers,
        'user_token': userToken,
      },
      endpoint: 'recordConsent',
      body: {
        'profileId': profileId,
        'userId': userId,
        "termsAccepted": "Agree",
        "selfieCamera": selfieCamera,
      },
    );
  }

  /// Record consent for appliance
  static Future<Map<String, dynamic>> recordConsentAppliance({
    required BuildContext context,
    required String userToken,
    required int userId,
    required int profileId,
    required String termsAccepted,
  }) async {
    return await postWithBanner(
      text: "Recording appliance consent",
      value: true, // show success popup if message available
      loadLoader: true,
      context: context,
      customHeaders: {
        ...headers,
        'user_token': userToken,
      },
      endpoint: 'recordConsentAppliance',
      body: {
        "userId": userId,
        "profileId": profileId,
        "termsAccepted": termsAccepted,
      },
    );
  }

  /// get Performance Data
  static Future<Map<String, dynamic>> getPerformanceData(
      BuildContext context, String userToken, int profileId, int userId) async {
    return await postWithBanner(
      text: "Getting performance data",
      value: true,
      loadLoader: true,
      context: context,
      customHeaders: {
        ...headers,
        'user_token': userToken,
      },
      endpoint: 'getPerformanceData',
      body: {
        "profileId": profileId,
        "userId": userId,
      },
    );
  }

  /// Save patient feedback
  static Future<Map<String, dynamic>> saveFeedback({
    required BuildContext context,
    required String userToken,
    required int patientId,
    required String feedbackType,
    required List<Map<String, dynamic>> feedbacks,
  }) async {
    return await postWithBanner(
      text: "Submitting feedback",
      value: true, // show success popup
      loadLoader: true,
      context: context,
      customHeaders: {
        ...headers,
        'user_token': userToken,
      },
      endpoint: 'savefeedback',
      body: {
        "patient_id": patientId,
        "feedback_type": feedbackType,
        "feedbacks": feedbacks,
      },
    );
  }

  /// get landing page info
  static Future<Map<String, dynamic>> landingPage(
      BuildContext context, String userToken, int profileId, int userId) async {
    return await postWithBanner(
        text: "getting landing page info",
        value: true,
        loadLoader: true,
        context: context,
        customHeaders: {
          ...headers,
          'user_token': userToken,
        },
        endpoint: 'landingPagev1',
        body: {
          "profileId": profileId,
          "userId": userId,
        },
        baseURL: "https://api.myocircle.com/api/app");
  }

  /// get leaderboard data
  static Future<Map<String, dynamic>> getLeaderboardData(BuildContext context,
      String userToken, int profileId, int userId, int therapistId) async {
    return await postWithBanner(
      text: "getting therapist data",
      value: true,
      loadLoader: true,
      context: context,
      customHeaders: {
        ...headers,
        'user_token': userToken,
      },
      endpoint: 'getLeaderBoardData',
      body: {
        "profileId": profileId,
        "userId": userId,
        "therapistId": therapistId,
      },
    );
  }

  /// get exercise by date
  static Future<Map<String, dynamic>> getExerciseByDate(
      BuildContext context,
      String userToken,
      int profileId,
      int userId,
      String date,
      String currentDate) async {
    return await postWithBanner(
      text: "getting exercise data",
      value: true,
      loadLoader: true,
      context: context,
      customHeaders: {
        ...headers,
        'user_token': userToken,
      },
      endpoint: 'getExercisebydate',
      body: {
        "profileId": profileId,
        "userId": userId,
        "date": date,
        "currentDate": currentDate,
      },
    );
    //   _showFullScreenLoader(context);
    //
    // ActivityMonitor.start();
    // try {
    //   final response = await http.post(
    //     Uri.parse('$baseUrl/getExercisebydate'),
    //     headers: {
    //       ...headers,
    //       'user_token': userToken,
    //     },
    //     body: jsonEncode({
    //       "profileId": profileId,
    //       "userId": userId,
    //       "date": date,
    //       "currentDate": currentDate,
    //     }),
    //   );
    //   _hideFullScreenLoader();
    //
    //   return jsonDecode(response.body);
    //
    // } on SocketException catch (_) {
    //
    //     _hideFullScreenLoader();
    //   if(context.mounted)
    //     await _showPopup(context, "Connection refused. Please check your internet or try again later.",
    //         type: PopupType.error);
    //   return {"status": 500, "message": "Connection refused"};
    // } catch (e) {
    //     _hideFullScreenLoader();
    //
    //   if(context.mounted)
    //     await _showPopup(context, "Something went wrong: $e",
    //         type: PopupType.error);
    //   print(e);
    //   return {"status": 500, "message": "Unexpected error"};
    // }
    // finally
    // {
    //   ActivityMonitor.end();
    // }
  }

  /// Get app content
  static Future<Map<String, dynamic>> getAppContent(
      String userToken, BuildContext context) async {
    ActivityMonitor.start();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getAppContent'),
        headers: {
          ...headers,
          'user_token': userToken,
        },
      );

      return _processResponse(response, false, context);
    } finally {
      ActivityMonitor.end();
    }
  }


  /// Get ref videos
  static Future<Map<String, dynamic>> getRefVideos(String userToken,
      int videoId, int profileId, int userId, BuildContext context) async {
    return await postWithBanner(
      text: "Getting ref. videos",
      value: false,
      loadLoader: false,
      context: context,
      customHeaders: {
        ...headers,
        'user_token': userToken,
      },
      endpoint: 'getReferenceVideoUrl',
      body: {
        "videoId": videoId,
        "profileId": profileId,
        "userId": userId,
      },
    );
  }

  /// Get default profile avatars
  static Future<Map<String, dynamic>> getDefaultProfileAvatars(
      String userToken, BuildContext context) async {
    ActivityMonitor.start();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getDefaultProfileAvatars'),
        headers: {
          ...headers,
          'user_token': userToken,
        },
      );

      return _processResponse(response, false, context);
    } finally {
      ActivityMonitor.end();
    }
  }

  /// Update user profile avatar and name
  static Future<Map<String, dynamic>> updateUserProfileAvatarAndName({
    required BuildContext context,
    required String userToken,
    required int userId,
    required int profileId,
    required String profileName,
    required String base64Image,
  }) async {
    // Prepare headers
    final headers = {
      'client_key': _client_key, // replace with your actual client key
      'user_token': userToken,
      'Content-Type': 'application/json',
    };

    // // Prepare body
    // final body = jsonEncode({
    //   'userId': userId,
    //   'profilId': profileId,
    //   'profileName': profileName,
    //   'avatarImg': base64Image,
    // });

    // // Make POST request
    // final response = await http.post(
    //   Uri.parse('https://test.genefax.ai/MyoCircle/app/updateUserProfileAvatarAndName'),
    //   headers: headers,
    //   body: body,
    // );

    // Handle response
    // return _processResponse(response);

    return await postWithBanner(
      text: "Updating Info",
      value: true,
      loadLoader: true,
      context: context,
      customHeaders: headers,
      endpoint: 'updateUserProfileAvatarAndName',
      body: {
        'userId': userId,
        'profilId': profileId,
        'profileName': profileName,
        'avatarImg': base64Image,
      },
    );
  }

  /// Update user profile avatar and name
  // static Future<Map<String, dynamic>> updateExerciseResponse({
  //   required BuildContext context,
  //   required int userId,
  //   required int profileId,
  //   required int scheduleId,
  //   required String reason, required userToken,
  // }) async {
  //   // Prepare headers
  //   final headers = {
  //     'client_key': _client_key,
  //     'Content-Type': 'application/json',
  //   };
  //   return await postWithBanner(
  //     text: "Updating Info",
  //     value: true,
  //     loadLoader: true,
  //     context: context,
  //     customHeaders: headers,
  //     endpoint: 'updateExerciseResponse',
  //     body: {
  //       'scheduleId': scheduleId,
  //       'userId': userId,
  //       'profileId': profileId,
  //       'status': "completed",
  //       'reason': reason,
  //     },
  //
  //   );
  //
  // }

  static Future<Map<String, dynamic>> updateExerciseResponse({
    required BuildContext context,
    required int userId,
    required int profileId,
    required int scheduleId,
    required String reason,
    required userToken,
  }) async {
    // Prepare headers
    final headers = {
      'client_key': _client_key,
      'user_token': userToken.toString(),
      'Content-Type': 'application/json',
    };

    final body = {
      'scheduleId': scheduleId,
      'userId': userId,
      'profileId': profileId,
      'status': "completed",
      'reason': reason,
    };

    // 🔥 Debug prints
    debugPrint("======= API REQUEST =======");
    debugPrint("Endpoint: updateExerciseResponse");
    debugPrint("Headers: $headers");
    debugPrint("Body: $body");
    debugPrint("===========================");

    return await postWithBanner(
      text: "Updating Info",
      value: true,
      loadLoader: true,
      context: context,
      customHeaders: headers,
      endpoint: 'updateExerciseResponse',
      body: body,
    );
  }


  /// Update user profile photo with loading banner and error handling
  static Future<Map<String, dynamic>> updateUserProfilePhotoAndName({
    required BuildContext context,
    required String userToken,
    required int userId,
    required int profileId,
    required String profileName,
    required File imageFile,
  }) async {
    _showFullScreenLoader(context);
    ActivityMonitor.start();
    try {
      var url = Uri.parse(
          "https://api.myocircle.com/api/app/updateUserProfilePhoto");

      var request = http.MultipartRequest("POST", url)
        ..headers.addAll({
          "client_key": _client_key,
          "user_token": userToken,
          "content-Type": "multipart/form-data",
        })
        ..fields["userId"] = userId.toString()
        ..fields["profileName"] = profileName.toString()
        ..fields["profileId"] = profileId.toString()
        ..files.add(await http.MultipartFile.fromPath(
          "file",
          imageFile.path,
          filename: basename(imageFile.path),
        ));

      var httpResponse = await request.send();
      var responseData = await httpResponse.stream.bytesToString();
      final response = http.Response(responseData, httpResponse.statusCode);

      _hideFullScreenLoader();

      return await _processResponse(response, true, context);
    } on SocketException catch (_) {
      _hideFullScreenLoader();
      if (context.mounted)
        await _showPopup(context,
            "Connection refused. Please check your internet or try again later.",
            type: PopupType.error);

      return {"status": 500, "message": "Connection refused"};
    } catch (e) {
      _hideFullScreenLoader();
      // SnackbarHelper.showSnackbar("Something went wrong: $e");
      return {"status": 500, "message": "$e"};
    } finally {
      ActivityMonitor.end();
    }
  }

  /// Get messages conversation
  static Future<Map<String, dynamic>> getMessage(
    BuildContext context,
    String userToken,
    int profileId,
    int userId,
  ) async {
    return await postWithBanner(
      text: "Fetching messages",
      value: true,
      loadLoader: true,
      context: context,
      customHeaders: {
        ...headers,
        'user_token': userToken,
      },
      endpoint: 'getMessage',
      body: {
        "profileId": profileId,
        "userId": userId,
      },
    );
  }

  /// Send a new message
  static Future<Map<String, dynamic>> sendMessage(
    BuildContext context,
    String userToken,
    int profileId,
    int userId,
    String message,
  ) async {
    return await postWithBanner(
      text: "Sending message",
      value: true,
      loadLoader: true,
      context: context,
      customHeaders: {
        ...headers,
        'user_token': userToken,
      },
      endpoint: 'sendMessage',
      body: {
        "profileId": profileId,
        "userId": userId,
        "message": message,
      },
    );
  }

  /// Get report data by type
  // static Future<dynamic> getReportDataByType(
  //   BuildContext context,
  //   String userToken,
  //   String fromDate,
  //   String toDate,
  //   String reportType,
  //   int patientId,
  //   int userId,
  // ) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse("$baseUrl/getReportDataByType"),
  //       headers: {
  //         ...headers,
  //         'user_token': userToken,
  //       },
  //       body: jsonEncode({
  //         "fromDate": fromDate,
  //         "toDate": toDate,
  //         "reportType": reportType,
  //         "patientId": patientId,
  //         "userId": userId,
  //       }),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //
  //       // ✅ Handle both cases
  //       if (data is List) {
  //         // Response is a list
  //         return data.cast<Map<String, dynamic>>();
  //       } else if (data is Map<String, dynamic>) {
  //         // Response is a map
  //         return data;
  //       } else {
  //         throw Exception("Unexpected response format");
  //       }
  //     } else {
  //       throw Exception("Failed with status: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     debugPrint("Error in getReportDataByType: $e");
  //     rethrow;
  //   }
  // }



  ///
  static Future<dynamic> getReportDataByTypeCompliance(
      BuildContext context,
      String userToken,
      String fromDate,
      String toDate,
      int patientId,
      int userId,
      ) async {
    final uri = Uri.parse("$baseUrl/getReportDataByType");

    final payload = {
      "fromDate": fromDate,
      "toDate": toDate,
      "reportType": "Compliance",
      "patientId": patientId,
      "userId": userId,
    };

    try {
      debugPrint("══════════════════════════════════════");
      debugPrint("API : getReportDataByTypeCompliance (POST)");
      debugPrint("URL : $uri");
      debugPrint("PAYLOAD : $payload");

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "user_token": userToken, // ✅ REQUIRED
        },
        body: jsonEncode(payload),
      );

      debugPrint("STATUS : ${response.statusCode}");
      debugPrint("RESPONSE : ${response.body}");
      debugPrint("══════════════════════════════════════");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed with status ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ API ERROR : $e");
      rethrow;
    }
  }
  ///
  static Future<dynamic> getReportDataByType(
      BuildContext context,
      String userToken,
      String fromDate,
      String toDate,
      String reportType,
      int patientId,
      int userId,
      ) async {
    try {
      final uri = Uri.parse("$baseUrl/getReportDataByType");

      final payload = {
        "fromDate": fromDate,
        "toDate": toDate,
        "reportType": reportType,
        "patientId": patientId,
        "userId": userId,
      };

      final requestHeaders = {
        ...headers, // must include Content-Type: application/json
        'user_token': userToken, // ✅ backend expects this
      };

      // 🔍 DEBUG LOGS
      debugPrint("══════════════════════════════════════");
      debugPrint("API : getReportDataByType (POST)");
      debugPrint("URL : $uri");
      debugPrint("HEADERS : $requestHeaders");
      debugPrint("PAYLOAD : $payload");

      final response = await http.post(
        uri,
        headers: requestHeaders,
        body: jsonEncode(payload),
      );

      debugPrint("STATUS CODE : ${response.statusCode}");
      debugPrint("RAW RESPONSE : ${response.body}");
      debugPrint("══════════════════════════════════════");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Handle both API response formats
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map<String, dynamic>) {
          return data;
        } else {
          throw Exception("Unexpected response format");
        }
      } else {
        throw Exception("Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error in getReportDataByType: $e");
      rethrow;
    }
  }


  /// Get daily exercise list
  static Future<Map<String, dynamic>> getDailyExerciseList({
    required BuildContext context,
    required int patientId,
    required int mode,
  }) async {
    return await postWithBanner(
      text: "Getting daily exercises",
      value: true,
      loadLoader: true,
      context: context,
      endpoint: 'GetExerciseListV2',
      body: {
        "PatientID": patientId,
        "Mode": mode,
      },
      baseURL: "https://myocircleexerciseengine.azurewebsites.net/api",
    );
  }

  /// Get dashboard exercise data (V2)
  static Future<Map<String, dynamic>> getDashboardData({
    required BuildContext context,
    required int patientId,
    required int mode,
  }) async {
    return await postWithBanner(
      text: "Getting dashboard data",
      value: true,
      loadLoader: false,
      context: context,
      endpoint: 'GetExerciseListV2',
      body: {
        "PatientID": patientId,
        "Mode": mode,
      },
      baseURL: "https://myocircleexerciseengine.azurewebsites.net/api",
    );
  }

  /// Helper function to process HTTP responses
  static Future<Map<String, dynamic>> _processResponse(
      http.Response response, bool value, BuildContext context) async {
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      // if(value==true)
      //   {
      //     if(context.mounted)
      //     await _showPopup(context, responseData['message'],
      //     type: PopupType.success);
      //
      //   }
      return responseData;
    } else {
      String errorMessage = 'API request failed';

      if (context.mounted)
        await _showPopup(context, errorMessage, type: PopupType.error);
      throw Exception(errorMessage);
    }
  }
}

class SnackbarHelper {
  static final GlobalKey<ScaffoldMessengerState> snackbarKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSnackbar(String message, {Color? color}) {
    snackbarKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? Colors.red, // Default color is red for errors
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class FullScreenLoader extends StatelessWidget {
  const FullScreenLoader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Center(
          child: InfinityRibbonLoader(
            size: 70,
            duration: Duration(milliseconds: 2800),
            borderThickness: 2,
            gap: 6,
            lineThickness: 6,
          ),
        ),
      ),
    );
  }
}

enum PopupType { success, error, warning, info }
