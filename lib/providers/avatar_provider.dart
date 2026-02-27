import 'package:flutter/material.dart';

class AvatarProvider with ChangeNotifier {
  int? _selectedAvatar;
  // Getters
  int? get selectedAvatar => _selectedAvatar;


  // Setters that save values to SharedPreferences
  void setAvatar(int? value) async {
    _selectedAvatar = value;
    notifyListeners();
  }
}
