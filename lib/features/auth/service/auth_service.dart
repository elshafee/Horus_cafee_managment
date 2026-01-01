import 'package:dio/dio.dart';
import 'package:horus_cafee/core/constants/api_constants.dart';
import 'package:horus_cafee/core/network/dio_client.dart';
import 'package:horus_cafee/features/auth/models/user_model.dart';

class AuthService {
  /// Login: Checks only staff_id (No auto-register)
  Future<UserModel?> login(String employeeCode) async {
    final DioClient _dioClient = await DioClient.create();

    try {
      final response = await _dioClient.post(
        ApiConstants.login,
        data: {'staff_id': employeeCode},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        return UserModel.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception(
          "User not found. Please Contact Dr Mohamed Kamal to register your user.",
        );
      }
      throw Exception("Connection Error: Check your Flask server.");
    }
  }

  /// NEW: Update Profile API call
  Future<bool> updateProfile(Map<String, dynamic> updateData) async {
    final DioClient _dioClient = await DioClient.create();
    try {
      final response = await _dioClient.post(
        '/auth/update_profile', // Ensure this matches your Flask route
        data: updateData,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
