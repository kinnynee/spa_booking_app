// Thư viện Material dùng để cấu hình theme và MaterialApp.
import 'package:flutter/material.dart';
// Provider giúp đăng ký các ChangeNotifier dùng chung toàn app.
import 'package:provider/provider.dart';

// Import màu sắc thương hiệu và các provider/màn hình khởi động.
import 'core/constants/app_colors.dart';
import 'providers/admin_booking_provider.dart';
import 'providers/admin_category_provider.dart';
import 'providers/admin_spa_service_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/catalog_provider.dart';
import 'screens/auth/auth_gate.dart';

// Widget gốc chịu trách nhiệm cấu hình provider, theme và màn hình đầu tiên.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  // build dựng cây widget cấp cao nhất của ứng dụng.
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminBookingProvider()),
        ChangeNotifierProvider(create: (_) => AdminCategoryProvider()),
        ChangeNotifierProvider(create: (_) => AdminSpaServiceProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
      ],
      child: MaterialApp(
        title: 'Lavender Spa Booking',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.primary,
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.input,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}
