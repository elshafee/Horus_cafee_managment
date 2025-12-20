import 'package:dio/dio.dart';
import 'package:horus_cafee/core/constants/api_constants.dart';
import 'package:horus_cafee/core/network/dio_client.dart';
import 'package:horus_cafee/features/auth/models/user_model.dart';

class AuthService {
  final DioClient _dioClient = DioClient();

  Future<UserModel?> login(String name, String employeeCode) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.login,
        data: {
          'staff_name': name, // Matched to your Flask key
          'staff_id': employeeCode, // Matched to your Flask key
          'room': '', // Optional room
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        // Map Flask response to our UserModel
        final data = response.data;
        return UserModel(
          id: data['staff_id'],
          name: data['staff_name'],
          employeeCode: data['staff_id'],
          officeRoom: data['room'],
        );
      }
      return null;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          "Cannot reach server at ${ApiConstants.baseUrl}. Check IP/Firewall.",
        );
      }
      rethrow;
    }
  }
}
