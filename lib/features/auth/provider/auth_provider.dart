import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:horus_cafee/core/storage/local_storage.dart';
import 'package:horus_cafee/features/auth/models/user_model.dart';
import 'package:horus_cafee/features/auth/service/auth_service.dart';
import 'package:image_picker/image_picker.dart';

class AuthProvider extends ChangeNotifier {
  final LocalStorage localStorage;
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  AuthProvider({required this.localStorage});

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

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

  /// Perform login (Modified to handle only staff_id)
  Future<bool> login(String employeeCode) async {
    _isLoading = true;
    notifyListeners();
    try {
      final userResponse = await _authService.login(employeeCode);

      if (userResponse != null) {
        _user = userResponse;
        _isAuthenticated = true;
        await localStorage.saveUser(_user!.toJson());
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow; // Pass error to UI for snackbar
    }
  }

  /// NEW: Update Profile Method (Required by ProfileScreen)
  Future<bool> updateProfile({
    required String dept,
    required String room,
    String? imageBase64,
  }) async {
    if (_user == null) return false;

    final updateData = {
      "staff_id": _user!.employeeCode,
      "department": dept,
      "room": room,
      "profile_image": imageBase64 ?? _user!.profileImage,
    };

    final success = await _authService.updateProfile(updateData);

    if (success) {
      // Update local state and cache
      _user = UserModel(
        name: _user!.name,
        employeeCode: _user!.employeeCode,
        department: dept,
        primaryRoom: room,
        profileImage: imageBase64 ?? _user!.profileImage,
      );
      await localStorage.saveUser(_user!.toJson());
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Log out and reset CACHE
  Future<void> logout() async {
    await localStorage.clearUser(); // Clears User Info
    // If you have other local storage for orders, clear them here too
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Triggered from the UI to show Camera/Gallery options
  // Inside AuthProvider
  Future<void> pickAndUploadImage(BuildContext context) async {
    final source = await _showPickOptions(context);
    if (source == null) return;

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 50,
    );

    if (image != null) {
      _isLoading = true;
      notifyListeners();

      try {
        final bytes = await File(image.path).readAsBytes();
        String base64Image = base64Encode(bytes);

        // AWAIT the update so the user object is fully updated before we finish
        await updateProfile(
          dept: _user?.department ?? "",
          room: _user?.primaryRoom ?? "",
          imageBase64: base64Image,
        );
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Helper to show the Bottom Sheet with Dark Theme styling
  Future<ImageSource?> _showPickOptions(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFBB86FC)),
              title: const Text(
                'Take a Photo',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFFBB86FC),
              ),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
