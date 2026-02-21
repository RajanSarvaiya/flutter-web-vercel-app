import 'package:flutter/material.dart';

typedef PendingAuthAction = VoidCallback;

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';
  bool _isLoading = false;
  PendingAuthAction? _pendingAction;

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  bool get isLoading => _isLoading;

  void setPendingAction(PendingAuthAction action) {
    _pendingAction = action;
  }

  void executePendingAction() {
    if (_pendingAction != null) {
      _pendingAction!();
      _pendingAction = null;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.isNotEmpty && password.length >= 6) {
      _isLoggedIn = true;
      _userEmail = email;
      _userName = email.split('@').first;
      _isLoading = false;
      notifyListeners();
      executePendingAction();
      return true;
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      _isLoggedIn = true;
      _userName = name;
      _userEmail = email;
      _isLoading = false;
      notifyListeners();
      executePendingAction();
      return true;
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    _pendingAction = null;
    notifyListeners();
  }
}
