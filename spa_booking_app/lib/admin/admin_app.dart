import 'package:flutter/material.dart';
import 'core/constants/admin_colors.dart';
import 'core/widgets/admin_bottom_nav.dart';

/// Entry point vào Admin App.
/// Gọi từ main.dart hoặc từ một nút "Admin" nào đó trong app.
class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lavender Spa Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AdminColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AdminColors.background,
        useMaterial3: true,
        fontFamily: 'BeVietnamPro',
        appBarTheme: const AppBarTheme(
          backgroundColor: AdminColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: AdminColors.onSurface,
        ),
      ),
      home: const AdminShell(),
    );
  }
}
