import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool _isBeepEnabled = true;
  String? _selectedSearchEngine;

  bool get isBeepEnabled => _isBeepEnabled;
  String? get selectedSearchEngine => _selectedSearchEngine;

  void toggleBeep(bool value) {
    _isBeepEnabled = value;
    notifyListeners();
  }

  void setSelectedSearchEngine(String? engine) {
    _selectedSearchEngine = engine;
    notifyListeners();
  }
}
