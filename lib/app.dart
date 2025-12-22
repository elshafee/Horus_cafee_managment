import 'package:flutter/material.dart';
import 'package:horus_cafee/core/theme/app_theme.dart';
import 'package:horus_cafee/routes/app_routes.dart';

class OfficeOrderApp extends StatelessWidget {
  const OfficeOrderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Office Order',
      debugShowCheckedModeBanner: false,

      // Theme Configuration (Material 3)
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Routing Configuration
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
