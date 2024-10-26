import 'package:archify/services/auth/auth_service.dart';
import 'package:flutter/foundation.dart';

class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
