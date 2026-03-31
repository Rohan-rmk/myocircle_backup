import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class AppUpdateService {
  static bool _isDialogShown = false;

  static Future<bool> checkForUpdate(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();

    String currentVersion = packageInfo.version;
    String packageName = packageInfo.packageName;
    String buildNumber = packageInfo.buildNumber;

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("📱 APP UPDATE CHECK");
    print("📱 Current Version : $currentVersion");
    print("🔢 Build Number   : $buildNumber");
    print("📦 Package Name   : $packageName");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━");

    /// 🤖 ANDROID
    if (Platform.isAndroid) {
      if (Platform.isAndroid) {
        try {
          final updateInfo = await InAppUpdate.checkForUpdate();

          print("📦 Update Availability: ${updateInfo.updateAvailability}");

          if (updateInfo.updateAvailability ==
              UpdateAvailability.updateAvailable) {

            // 🔥 ONLY SHOW IF INSTALLED FROM PLAY STORE
            if (updateInfo.installStatus != null) {
              _showForceDialog(
                context,
                "https://play.google.com/store/apps/details?id=$packageName",
              );
              return false;
            }
          }
        } catch (e) {
          print("Android error: $e");

          // 🔥 DO NOT FORCE UPDATE ON ERROR (important for debug builds)
          return true;
        }
      }
    }

    /// 🍏 IOS
    if (Platform.isIOS) {
      String? latestVersion = await _fetchIOSVersion(packageName);

      print("🌍 Latest Version (App Store): $latestVersion");

      if (latestVersion != null &&
          _isUpdateRequired(currentVersion, latestVersion)) {

        _showForceDialog(
          context,
          "https://apps.apple.com/app/id6758389834",
        );

        return false;
      }
    }

    return true;
  }

  /// 🍏 FETCH VERSION FROM APP STORE
  static Future<String?> _fetchIOSVersion(String bundleId) async {
    try {
      final res = await http.get(
        Uri.parse("https://itunes.apple.com/lookup?bundleId=$bundleId"),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['resultCount'] > 0) {
          return data['results'][0]['version'];
        }
      }
    } catch (e) {
      print("iOS fetch error: $e");
    }
    return null;
  }

  /// 🔍 VERSION COMPARISON
  static bool _isUpdateRequired(String current, String latest) {
    current = _cleanVersion(current);
    latest = _cleanVersion(latest);

    List<int> c = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> l = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < l.length; i++) {
      if (i >= c.length) return true;
      if (l[i] > c[i]) return true;
      if (l[i] < c[i]) return false;
    }
    return false;
  }

  static String _cleanVersion(String version) {
    version = version.trim();

    if (version.contains('+')) {
      version = version.split('+')[0];
    }

    return version;
  }

  /// 🔥 FORCE UPDATE DIALOG (COMMON FOR BOTH)
  static void _showForceDialog(BuildContext context, String url) {
    if (_isDialogShown) return;
    _isDialogShown = true;

    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Update Required"),
        content: const Text("Please update the app to continue"),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              await launchUrl(Uri.parse(url));
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}