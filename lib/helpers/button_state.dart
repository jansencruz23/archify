import 'package:flutter/material.dart';

class ButtonState with ChangeNotifier {
  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;

  void setEnabled(bool value) {
    _isEnabled = value;
    notifyListeners();
  }
}
