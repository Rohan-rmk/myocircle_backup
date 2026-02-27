import 'package:flutter/material.dart';

class FirstTimeUserProvider with ChangeNotifier {
  bool _isFirstTime = false;
  String _age = "";

  // Getter to access null fields and age
  bool get isFirstTime => _isFirstTime;
  String get age => _age;


  // Save null fields to SharedPreferences
  Future<void> setFirstTime(bool value) async {
    _isFirstTime = value;
    notifyListeners();
  }
  // Save age to SharedPreferences
  Future<void> setAge(String value) async {
    _age = value;
    notifyListeners();
  }
}
