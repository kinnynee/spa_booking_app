// Thư viện Material cung cấp StatelessWidget cho cổng điều hướng.
import 'package:flutter/material.dart';
// Provider dùng để theo dõi trạng thái đăng nhập.
import 'package:provider/provider.dart';

// Import AuthProvider và hai màn hình đích sau/trước đăng nhập.
import '../../providers/auth_provider.dart';
import '../main_shell.dart';
import 'login_screen.dart';

// Widget quyết định hiển thị MainShell hay LoginScreen theo isAuthenticated.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  // build lắng nghe AuthProvider và chuyển UI theo trạng thái đăng nhập.
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
    return isAuthenticated ? const MainShell() : const LoginScreen();
  }
}
