import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:horus_cafee/app.dart';
import 'package:horus_cafee/core/storage/local_storage.dart';
import 'package:horus_cafee/features/auth/provider/auth_provider.dart';
import 'package:horus_cafee/features/chat/provider/chat_provider.dart';
import 'package:horus_cafee/features/orders/provider/orders_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (Portrait only for mobile)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Local Storage (Hive)
  await Hive.initFlutter();
  final localStorage = LocalStorage();
  await localStorage.init();

  runApp(
    MultiProvider(
      providers: [
        // Core Storage Provider
        Provider<LocalStorage>.value(value: localStorage),

        // Feature Providers
        ChangeNotifierProvider(
          create: (_) => AuthProvider(localStorage: localStorage),
        ),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
      ],
      child: const OfficeOrderApp(),
    ),
  );
}
