import 'package:flutter/material.dart';
import 'package:horus_cafee/core/storage/local_storage.dart';
import 'package:horus_cafee/features/auth/models/user_model.dart';
import 'package:horus_cafee/features/auth/service/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final LocalStorage localStorage;
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isAuthenticated = false;

  AuthProvider({required this.localStorage});

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;

  /// Check if user is already logged in via Local Storage
  Future<bool> checkLoginStatus() async {
    final userData = localStorage.getUser();
    if (userData != null) {
      _user = UserModel.fromJson(userData);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Perform login against the local Flask API
  Future<bool> login(String name, String employeeCode) async {
    try {
      final userResponse = await _authService.login(name, employeeCode);

      if (userResponse != null) {
        _user = userResponse;
        _isAuthenticated = true;

        // Persist user locally
        await localStorage.saveUser(_user!.toJson());

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Auth Error: $e");
      return false;
    }
  }

  /// Log out user and clear local cache
  Future<void> logout() async {
    await localStorage.clearUser();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Update user profile (e.g. room change)
  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    localStorage.saveUser(_user!.toJson());
    notifyListeners();
  }
}
