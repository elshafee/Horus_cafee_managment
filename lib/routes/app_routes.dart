import 'package:flutter/material.dart';
import 'package:horus_cafee/features/auth/screen/login_screen.dart';
import 'package:horus_cafee/features/auth/screen/splash_screen.dart';
import 'package:horus_cafee/features/chat/screen/chat_screen.dart';
import 'package:horus_cafee/features/order/models/order_model.dart';
import 'package:horus_cafee/features/orders/screens/order_details_screen.dart';
import 'package:horus_cafee/features/orders/screens/orders_screen.dart';
import 'package:horus_cafee/features/profile/screens/profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String orders = '/orders';
  static const String orderDetails = '/order-details';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const ChatScreen());

      case orders:
        return MaterialPageRoute(builder: (_) => const OrdersScreen());

      case orderDetails:
        // CHANGED: We now receive the full OrderModel object as an argument
        // This prevents the details screen from needing to make a second API call
        final order = settings.arguments as OrderModel;
        return MaterialPageRoute(
          builder: (_) => OrderDetailsScreen(order: order),
        );

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: const Color(0xFF121212),
            body: Center(
              child: Text(
                'No route defined for ${settings.name}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
    }
  }
}
