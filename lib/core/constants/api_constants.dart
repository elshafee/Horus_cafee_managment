import 'package:shared_preferences/shared_preferences.dart';

class ApiConstants {
  // 1. UPDATE THIS to your computer's actual IP address
  // Use 10.0.2.2 if you are using the Android Emulator
  static const String baseUrl = 'http://127.0.0.1:5000';
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('base_url') ?? baseUrl;
  }

  static const int receiveTimeout = 15000;
  static const int connectionTimeout = 15000;

  // 2. Updated paths to match your Flask routes
  static const String login = '/auth/login';
  static const String getProducts = '/products';
  static const String createOrder = '/order';
  static const String getUserOrders =
      '/orders'; // We will append /<staff_id> in service
}
