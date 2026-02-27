import 'package:flutter/material.dart';

class IndexProvider with ChangeNotifier {
  int _selectedIndex = 0;
  // Getters
  int get selectedIndex => _selectedIndex;


  // Setters that save values to SharedPreferences
  void setIndex(int value) async {
    _selectedIndex = value;
    notifyListeners();
  }
}
