import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionProvider with ChangeNotifier {
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _landingPageData;
  int? _selectedProfileId;
  String? _uniqueId;
  int? _pin;
  bool _isPatient = true;
  bool _showPopup = true;

  Map<String, dynamic>? get userData => _userData;
  Map<String, dynamic>? get landingPageData => _landingPageData;
  int? get selectedProfileId => _selectedProfileId;
  String? get uniqueId => _uniqueId;
  int? get pin => _pin;
  bool? get isPatient => _isPatient;
  bool get showPopup => _showPopup;

  void setUserData(Map<String, dynamic> data, String uniqueId, int pin) {
    _userData = data;
    _uniqueId = uniqueId;
    _pin = pin;
    notifyListeners();
  }

  void updatePin(int pin) {
    _pin = pin;
    notifyListeners();
  }

  void setLandingPageData(Map<String, dynamic> data) {
    _landingPageData = data;
    notifyListeners();
  }

  Future<void> setNotPatient(bool flag) async {
    _isPatient = flag;
    notifyListeners();
  }

  Future<void> setPopupShown(bool flag) async {
    _showPopup = flag;
    notifyListeners();
  }

  // Future<void> setSelectedProfileId(int value) async {
  //   _selectedProfileId = value;
  //   notifyListeners();
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setInt('selectedProfileId', value);
  // }
  Future<void> setSelectedProfileId(int value) async {
    debugPrint("➡️ setSelectedProfileId called with value: $value");

    _selectedProfileId = value;
    notifyListeners();

    debugPrint("✅ _selectedProfileId set in memory: $_selectedProfileId");

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedProfileId', value);

    debugPrint("💾 selectedProfileId saved to SharedPreferences: $value");
  }

  void resetAll() async {
    _userData = null;
    _selectedProfileId = null;
    _landingPageData = null;
    _pin = null;
    _uniqueId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedProfileId');

    notifyListeners();
  }

  String get persona {
    final age = _landingPageData?['age'];
    if (age is int && age < 18) return 'minor patient';
    if (age is int && age >= 18) return 'adult patient';
    return 'unknown';
  }

  bool get isViewingOwnProfile {
    if (_userData == null || _selectedProfileId == null) return true;
    return _userData!['profileId'] == _selectedProfileId;
  }

  bool get isGuardian {
    final family = _userData?['familyMembers'];
    return family != null && family is List && family.isNotEmpty;
  }

  Future<void> loadSelectedProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedProfileId = prefs.getInt('selectedProfileId');
    notifyListeners();
  }
}
